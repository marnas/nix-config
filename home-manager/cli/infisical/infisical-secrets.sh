# Fetch the secrets at one Infisical folder path (project `claude`) and print them as a
# flat JSON object {"KEY":"value",...} on stdout. This is the shared consumer-side
# counterpart to ./infisical-token.sh: it owns the fetch-with-cached-token dance — use the
# cached token, sniff an auth rejection, re-mint once via `infisical-token --refresh`,
# retry — so per-API CLIs (`any`, `actual`, ...) reduce their creds logic to one call:
#
#   secrets="$(infisical-secrets /anytype)"
#   APIKEY="$(jq -r '.ANYTYPE_APIKEY // empty' <<<"$secrets")"
#
# Output is normalized: `infisical export --format=json` returns either an array of
# {key,value} pairs or a flat object depending on version; we always emit the flat object.
# Secrets transit stdout only (callers capture with "$(...)"), never argv; the access token
# reaches `infisical` via the INFISICAL_TOKEN env var, not `--token`. Nothing is cached
# here — fetch and discard per call; the only persisted artifact is infisical-token's
# tmpfs-cached machine-identity token.
#
# Usage:
#   infisical-secrets </path> [--env ENV]    # ENV defaults to $INFISICAL_ENV or prod

: "${INFISICAL_API_URL:=https://infisical.marnas.sh/api}"

path=""
env="${INFISICAL_ENV:-prod}"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --env) env="$2"; shift 2 ;;
    -*) echo "infisical-secrets: unknown arg $1" >&2; exit 2 ;;
    *)
      [ -z "$path" ] || { echo "infisical-secrets: unexpected arg $1" >&2; exit 2; }
      path="$1"; shift ;;
  esac
done
[ -n "$path" ] || { echo "usage: infisical-secrets </path> [--env ENV]" >&2; exit 2; }

fetch() { # fetch TOKEN PROJECT_ID
  INFISICAL_TOKEN="$1" infisical export --format=json --silent \
    --domain "$INFISICAL_API_URL" \
    --projectId "$2" --env "$env" --path "$path"
}

token="$(infisical-token)"
pid="$(infisical-token --field projectId)"

# Use the cached token until the server rejects it (we don't track its TTL). If export
# fails and the error looks like an auth rejection, re-mint once and retry; any other
# failure (network, project-id) is surfaced as-is rather than triggering a needless mint.
errf="$(mktemp)"
if ! secrets="$(fetch "$token" "$pid" 2>"$errf")"; then
  if grep -qiE '401|unauthor|forbidden|invalid.*token|token.*(expired|invalid)|expired' "$errf"; then
    token="$(infisical-token --refresh)"
    if ! secrets="$(fetch "$token" "$pid" 2>"$errf")"; then
      echo "infisical-secrets: export failed after token refresh:" >&2
      cat "$errf" >&2
      rm -f "$errf"
      exit 1
    fi
  else
    echo "infisical-secrets: export failed:" >&2
    cat "$errf" >&2
    rm -f "$errf"
    exit 1
  fi
fi
rm -f "$errf"

jq 'if type=="array" then map({(.key): .value}) | add // {} else . end' <<<"$secrets"
