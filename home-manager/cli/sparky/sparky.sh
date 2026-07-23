# Tier-1 CLI over the SparkyFitness MCP endpoint at https://sparky.marnas.sh/mcp
# (streamable-HTTP JSON-RPC, stateless — no initialize/session dance needed). The verbs
# are deliberately generic (tools / schema / call): the server owns the tool catalog, so
# this CLI never goes stale when SparkyFitness upgrades add or change tools. The plain
# REST API is NOT used — most of its routes want a per-user JWT; the API key only covers
# /mcp and /api/health-data. Credentials come from the self-hosted Infisical at call time
# (project `claude`, path /sparky) via `infisical-secrets`, then discarded on exit.
# shebang + `set -euo pipefail` are injected by writeShellApplication, so this file
# starts at the functions. `infisical-secrets` is inherited from PATH (home.packages,
# see ../infisical), same as for `any` and `actual`.

load_creds() {
  local secrets
  secrets="$(infisical-secrets /sparky)"
  APIKEY="$(jq -r '.API_KEY // empty' <<<"$secrets")"
  if [ -z "$APIKEY" ]; then
    echo "sparky: missing API_KEY in Infisical" \
      "(project=claude env=${INFISICAL_ENV:-prod} path=/sparky)" >&2
    exit 1
  fi
  MCP="https://sparky.marnas.sh/mcp"
}

rpc() { # rpc METHOD [PARAMS_JSON] — prints the JSON-RPC .result
  local method="$1" params="${2:-}"
  [ -n "$params" ] || params='{}'
  local body out code
  body="$(jq -nc --arg m "$method" --argjson p "$params" \
    '{jsonrpc:"2.0",id:1,method:$m,params:$p}')"
  # No -f: we capture the status ourselves so a 4xx/5xx body (the API's error message)
  # is surfaced instead of swallowed. The bearer apikey goes via a --config stream on
  # stdin, never argv. Accept must offer text/event-stream too (streamable-HTTP spec).
  out="$(printf 'header = "Authorization: Bearer %s"\n' "$APIKEY" | curl -sS -X POST \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json, text/event-stream' \
    -w '\n%{http_code}' \
    --config - \
    -d "$body" "$MCP")"
  code="${out##*$'\n'}"
  out="${out%$'\n'*}"
  if [ "$code" -lt 200 ] || [ "$code" -ge 300 ]; then
    echo "sparky: $method → HTTP $code" >&2
    [ -n "$out" ] && echo "$out" >&2
    exit 1
  fi
  # The server answers plain JSON today, but streamable-HTTP allows SSE framing —
  # unwrap `data:` lines (the response is the last data event) so both forms work.
  if [[ "$out" == event:* || "$out" == data:* ]]; then
    out="$(sed -n 's/^data:[[:space:]]*//p' <<<"$out" | tail -n1)"
  fi
  if jq -e '.error' >/dev/null 2>&1 <<<"$out"; then
    echo "sparky: $method → RPC error" >&2
    jq -r '.error | "\(.code): \(.message)"' <<<"$out" >&2
    exit 1
  fi
  jq '.result' <<<"$out"
}

cmd_tools() {
  rpc tools/list |
    jq -r '.tools[] | .name + "\t" + ((.description // "") | split("\n")[0])'
}

cmd_schema() { # full description (per-action fields live there) + input schema
  local name="$1" found
  found="$(rpc tools/list | jq --arg n "$name" '[.tools[] | select(.name==$n)] | first')"
  if [ "$found" = "null" ]; then
    echo "sparky: unknown tool '$name' (see: sparky tools)" >&2
    exit 1
  fi
  jq -r '.description // ""' <<<"$found"
  echo
  jq '.inputSchema' <<<"$found"
}

cmd_call() {
  local name="$1" args="${2:-}"
  [ -n "$args" ] || args='{}'
  if ! jq -e . >/dev/null 2>&1 <<<"$args"; then
    echo "sparky: arguments must be valid JSON, got: $args" >&2
    exit 1
  fi
  local res
  res="$(rpc tools/call "$(jq -nc --arg n "$name" --argjson a "$args" \
    '{name:$n,arguments:$a}')")"
  # Tool-level failures come back as isError inside a 200 — surface them as errors.
  if jq -e '.isError == true' >/dev/null <<<"$res"; then
    echo "sparky: $name returned an error:" >&2
    jq -r '[.content[]? | select(.type=="text") | .text] | join("\n")' <<<"$res" >&2
    exit 1
  fi
  jq -r '[.content[]? | select(.type=="text") | .text] | join("\n")' <<<"$res"
}

usage() {
  cat >&2 <<'EOF'
usage:
  sparky tools                      list available tools (name + summary)
  sparky schema <tool>              tool description (per-action fields) + input schema
  sparky call <tool> ['<json>']     invoke a tool; arguments default to {}
EOF
  exit 2
}

[ "$#" -ge 1 ] || usage
verb="$1"
shift
load_creds
case "$verb" in
  tools) [ "$#" -eq 0 ] || usage; cmd_tools ;;
  schema) [ "$#" -eq 1 ] || usage; cmd_schema "$1" ;;
  call) [ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage; cmd_call "$@" ;;
  *) usage ;;
esac
