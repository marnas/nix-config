# Mint + cache a short-lived Infisical machine-identity access token for Claude's CLIs,
# so they can fetch secrets from the self-hosted Infisical without a per-call 1Password
# prompt.
#
# Model: the machine-identity client-id/secret live in 1Password (item `$INFISICAL_OP_ITEM`,
# fields client_id / client_secret / project_id). We read them from 1Password EXACTLY ONCE per
# boot (a single `op` unlock) and cache them in $XDG_RUNTIME_DIR (tmpfs -> wiped on reboot,
# never on the disk/Nix store). Every later token mint -- INCLUDING the re-mints triggered when
# the access token expires and a consumer hits 401 -- reads those cached creds, so it costs zero
# further 1Password prompts. From the cached creds we exchange id+secret for a scoped, read-only
# access token, cached separately and re-minted on demand.
#
# Two tmpfs artifacts, both mode 600 under a 700 dir, both wiped on reboot:
#   creds.json   client_id/client_secret/project_id  -- write-once per boot (the one op read)
#   claude.json  the access token + projectId         -- re-minted whenever it expires
# Security tradeoff vs. the earlier "the token is the only persisted artifact" design: we now
# also cache the client_secret in tmpfs. It mints the SAME read-only, `claude`-project-scoped
# token, so it is the same threat surface as the token it produces -- and caching it is the only
# way to make the "one op unlock per boot" invariant actually true. Before, mint() re-read
# 1Password on every refresh, so the (4h) token TTL meant a fresh biometric prompt every ~4h.
#
# Sharing: the cache is keyed by $XDG_RUNTIME_DIR (per user-session, NOT per-project) and the
# token is scoped to the single Infisical project `claude`, so one token is deliberately shared
# across every project and every concurrent Claude instance -- they all need the identical
# read-only scope, and sharing minimizes mints. Writes are atomic (temp file + rename) so a
# concurrent refresh from another instance can never expose a half-written cache. If several
# instances notice expiry at once they may each mint an independent (equally valid) token --
# harmless and op-free now that creds are cached; we don't lock (no flock on macOS) to serialize
# that rare redundant mint.
#
# No proactive TTL: we don't guess when the token expires. The cached token is reused for every
# call until a consumer's API request is actually rejected; that consumer then re-mints via
# `infisical-token --refresh` and retries. This avoids both needless re-mints and using a token
# we wrongly believed was still valid.
#
# Secrets never touch argv. We do NOT use `infisical login` -- it always persists the token to
# the OS keyring (`--plain` only changes output formatting), defeating the tmpfs-only design.
# Instead we hit the raw universal-auth API with curl: the client id/secret are built into the
# request body by jq from env vars (never a jq arg) and streamed to curl over stdin (never a
# curl arg), so no secret appears in any process command line. The access token likewise reaches
# consumers via the INFISICAL_TOKEN env var, not `--token`.
#
# Usage:
#   infisical-token                    # print the cached token (mint if absent)
#   infisical-token --field projectId  # print a cached field (projectId)
#   infisical-token --refresh          # force re-mint, then print the token
#
# `op` is intentionally NOT in runtimeInputs (same reason as anytype/default.nix): we inherit
# the platform-wrapped `op` from PATH so 1Password desktop integration keeps working. curl/jq/
# infisical are provided by writeShellApplication.

: "${INFISICAL_API_URL:=https://infisical.marnas.sh/api}"
OP_ITEM="${INFISICAL_OP_ITEM:-infisical-claude}"
OP_VAULT="${INFISICAL_OP_VAULT:-Private}"

cache_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/infisical"
cache="$cache_dir/claude.json"
creds_cache="$cache_dir/creds.json"

field=""
force=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --field) field="$2"; shift 2 ;;
    --refresh) force=1; shift ;;
    *) echo "infisical-token: unknown arg $1" >&2; exit 2 ;;
  esac
done

# Write stdin to $1 atomically: a temp file in the SAME dir (so rename stays on one filesystem)
# then mv -f. mode 600 under the 700 dir. A concurrent reader/refresher never sees a partial file.
atomic_write() {
  local dest="$1" tmp
  mkdir -p "$cache_dir"
  chmod 700 "$cache_dir"
  tmp="$(mktemp "$cache_dir/.tmp.XXXXXX")"
  cat >"$tmp"
  chmod 600 "$tmp"
  mv -f "$tmp" "$dest"
}

# Populate cid/csec/pid (dynamically scoped into the caller, mint). Read from the tmpfs creds
# cache; only when it is absent/incomplete do we fall back to the ONE-TIME 1Password read -- the
# single `op` unlock per boot -- which then seeds the cache for every later mint.
load_creds() {
  if [ -s "$creds_cache" ]; then
    cid="$(jq -r '.client_id // empty' "$creds_cache")"
    csec="$(jq -r '.client_secret // empty' "$creds_cache")"
    pid="$(jq -r '.project_id // empty' "$creds_cache")"
    if [ -n "$cid" ] && [ -n "$csec" ]; then return 0; fi
  fi
  local j
  j="$(op item get "$OP_ITEM" --vault "$OP_VAULT" --format json)"
  cid="$(jq -r '.fields[]|select(.label=="client_id")|.value' <<<"$j")"
  csec="$(jq -r '.fields[]|select(.label=="client_secret")|.value' <<<"$j")"
  pid="$(jq -r '.fields[]|select(.label=="project_id")|.value' <<<"$j")"
  [ -n "$cid" ] && [ -n "$csec" ] || {
    echo "infisical-token: missing client_id/client_secret in 1Password item '$OP_ITEM'" >&2
    return 1
  }
  jq -nc --arg c "$cid" --arg s "$csec" --arg p "$pid" \
    '{client_id:$c,client_secret:$s,project_id:$p}' | atomic_write "$creds_cache"
}

mint() {
  local cid csec pid tok
  load_creds || return 1
  # Build the body with jq from env vars (secret is never a jq arg) and stream it to curl over
  # stdin (--data @-, never a curl arg). Nothing secret reaches any command line.
  tok="$(CID="$cid" CSEC="$csec" jq -nc '{clientId:env.CID,clientSecret:env.CSEC}' \
    | curl -fsS -X POST -H 'Content-Type: application/json' --data @- \
        "$INFISICAL_API_URL/v1/auth/universal-auth/login" \
    | jq -r '.accessToken // empty')"
  [ -n "$tok" ] || {
    echo "infisical-token: universal-auth login returned no token (check creds / connectivity)" >&2
    return 1
  }
  jq -nc --arg t "$tok" --arg p "$pid" '{token:$t,projectId:$p}' | atomic_write "$cache"
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
