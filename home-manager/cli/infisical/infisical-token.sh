# Mint + cache a short-lived Infisical machine-identity access token for Claude's CLIs,
# so they can fetch secrets from the self-hosted Infisical without a per-call 1Password
# prompt.
#
# Model (see ../../CLAUDE.md / the "agent-vault" Anytype task): the machine-identity
# client-id/secret live in 1Password (item `$INFISICAL_OP_ITEM`, fields client_id /
# client_secret / project_id). We read them ONCE per boot (a single `op` unlock) and
# exchange id+secret for a scoped, read-only access token, cached in $XDG_RUNTIME_DIR
# (tmpfs -> wiped on reboot, never written to the disk store). The token is the ONLY
# persisted artifact -- transient, read-only, scoped to the `claude` project. Raw service
# secrets (e.g. the Anytype apikey) are never cached here; consumers fetch-and-discard
# them per call using this token.
#
# No proactive TTL: we don't try to guess when the token expires. The cached token is
# reused for every call until a consumer's API request is actually rejected; that consumer
# then re-mints via `infisical-token --refresh` and retries. This avoids both needless
# `op` unlocks and using a token we wrongly believed was still valid.
#
# Secrets never touch argv. We do NOT use `infisical login` -- it always persists the token
# to the OS keyring (`--plain` only changes output formatting), which would defeat the
# tmpfs-only design. Instead we hit the raw universal-auth API with curl: the client
# id/secret are built into the request body by jq from env vars (never a jq arg) and
# streamed to curl over stdin (never a curl arg), so no secret appears in any process
# command line. The access token likewise reaches consumers via the INFISICAL_TOKEN env
# var, not `--token`.
#
# Usage:
#   infisical-token                    # print the cached token (mint if absent)
#   infisical-token --field projectId  # print a cached field (projectId)
#   infisical-token --refresh          # force re-mint, then print the token
#
# `op` is intentionally NOT in runtimeInputs (same reason as anytype/default.nix): we
# inherit the platform-wrapped `op` from PATH so 1Password desktop integration keeps
# working. curl/jq/infisical are provided by writeShellApplication.

: "${INFISICAL_API_URL:=https://infisical.marnas.sh/api}"
OP_ITEM="${INFISICAL_OP_ITEM:-infisical-claude}"
OP_VAULT="${INFISICAL_OP_VAULT:-Private}"

cache_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/infisical"
cache="$cache_dir/claude.json"

field=""
force=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --field) field="$2"; shift 2 ;;
    --refresh) force=1; shift ;;
    *) echo "infisical-token: unknown arg $1" >&2; exit 2 ;;
  esac
done

mint() {
  local j cid csec pid tok
  j="$(op item get "$OP_ITEM" --vault "$OP_VAULT" --format json)"
  cid="$(jq -r '.fields[]|select(.label=="client_id")|.value' <<<"$j")"
  csec="$(jq -r '.fields[]|select(.label=="client_secret")|.value' <<<"$j")"
  pid="$(jq -r '.fields[]|select(.label=="project_id")|.value' <<<"$j")"
  [ -n "$cid" ] && [ -n "$csec" ] || {
    echo "infisical-token: missing client_id/client_secret in 1Password item '$OP_ITEM'" >&2
    return 1
  }
  # Build the body with jq from env vars (secret is never a jq arg) and stream it to curl
  # over stdin (--data @-, never a curl arg). Nothing secret reaches any command line.
  tok="$(CID="$cid" CSEC="$csec" jq -nc '{clientId:env.CID,clientSecret:env.CSEC}' \
    | curl -fsS -X POST -H 'Content-Type: application/json' --data @- \
        "$INFISICAL_API_URL/v1/auth/universal-auth/login" \
    | jq -r '.accessToken // empty')"
  [ -n "$tok" ] || {
    echo "infisical-token: universal-auth login returned no token (check creds / connectivity)" >&2
    return 1
  }
  mkdir -p "$cache_dir"
  chmod 700 "$cache_dir"
  (
    umask 077
    jq -nc --arg t "$tok" --arg p "$pid" '{token:$t,projectId:$p}' >"$cache"
  )
}

# Mint when forced (--refresh, e.g. a consumer just hit 401) or when no token is cached.
if [ "$force" = 1 ] || [ ! -s "$cache" ]; then
  mint || exit 1
fi

if [ -n "$field" ]; then
  jq -r --arg f "$field" '.[$f] // empty' "$cache"
else
  jq -r '.token' "$cache"
fi
