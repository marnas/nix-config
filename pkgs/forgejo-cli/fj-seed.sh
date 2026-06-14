# fj-seed — run fj with its credential store materialized in tmpfs from Infisical, never on
# persistent disk. fj reads its token only from $XDG_DATA_HOME/forgejo-cli/keys.json (there is
# no env/flag token), so we fetch the whole keys.json blob (Infisical project `claude`, path
# /forgejo, secret FORGEJO_KEYS_JSON), write it 0600 under XDG_RUNTIME_DIR (RAM-backed), run fj,
# then remove it on exit. Mirrors the git-agent SSH-key discipline: the secret lives in
# tmpfs/process memory only. Re-fetched per invocation — no on-disk cache to expire.
#
# infisical + infisical-token are inherited from PATH (same convention as git-agent-seed); jq
# comes from runtimeInputs. FJ_REAL (the unwrapped fj) is set by the Nix wrapper.

run_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/forgejo-cli"
data_dir="$run_dir/data"
config_dir="$run_dir/config"
keys="$data_dir/forgejo-cli/keys.json"
mkdir -p "$data_dir/forgejo-cli" "$config_dir"
chmod 700 "$run_dir"

cleanup() { rm -f "$keys"; }
trap cleanup EXIT

# Extract a secret from `infisical export --format=json`, tolerating both the
# array-of-{key,value} and flat-object shapes (mirrors git-agent-seed's ival).
ival() { jq -r --arg k "$1" 'if type=="array" then (.[]|select(.key==$k)|.value) else .[$k] end // empty'; }

export_secrets() { # export_secrets TOKEN PID
  INFISICAL_TOKEN="$1" infisical export --format=json --silent \
    --domain "${INFISICAL_API_URL:-https://infisical.marnas.sh/api}" \
    --projectId "$2" --env "${INFISICAL_ENV:-prod}" --path /forgejo 2>/dev/null || true
}

fetch_keys() {
  local token pid out
  token="$(infisical-token)"
  pid="$(infisical-token --field projectId)"
  out="$(export_secrets "$token" "$pid")"
  # Cached token may be expired; re-mint once and retry if the blob didn't come back.
  if [ -z "$(ival FORGEJO_KEYS_JSON <<<"$out")" ]; then
    token="$(infisical-token --refresh)"
    out="$(export_secrets "$token" "$pid")"
  fi
  ival FORGEJO_KEYS_JSON <<<"$out"
}

blob="$(fetch_keys)"
[ -n "$blob" ] || {
  echo "fj-seed: could not fetch FORGEJO_KEYS_JSON from Infisical (project=claude path=/forgejo)" >&2
  exit 1
}
(
  umask 077
  printf '%s\n' "$blob" >"$keys"
)

export XDG_DATA_HOME="$data_dir"
export XDG_CONFIG_HOME="$config_dir"
"$FJ_REAL" "$@"
