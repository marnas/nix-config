# git-agent-seed — ensure the agent ssh-agent is running and holds the dedicated git key,
# then print its socket path on stdout. Shared by the two Claude-scoped git wrappers:
# git-sign-agent (commit signing) and git-ssh (push/fetch auth). Idempotent and lazy — the
# first caller per boot fetches the key, every later caller reuses the live agent.
#
# The key is the agent's own identity (public half in claude/settings.nix as user.signingkey
# + registered on git.marnas.sh / GitHub). Its private half lives in the self-hosted Infisical
# (project `claude`, path /git, secret GIT_SSH_KEY) and is `ssh-add`-ed from stdin so it
# never lands on disk. After the first sign/push per boot the key is already loaded.
#
# infisical + infisical-token are inherited from PATH (same convention as any.sh); openssh
# and jq come from runtimeInputs. Only the socket path goes to stdout; diagnostics to stderr.

run_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/git-agent"
mkdir -p "$run_dir"
chmod 700 "$run_dir"
sock="$run_dir/agent.sock"
export SSH_AUTH_SOCK="$sock"

# Extract a secret from `infisical export --format=json`, tolerating both the
# array-of-{key,value} and flat-object shapes (mirrors any.sh's ival).
ival() { jq -r --arg k "$1" 'if type=="array" then (.[]|select(.key==$k)|.value) else .[$k] end // empty'; }

export_secrets() { # export_secrets TOKEN PID
  INFISICAL_TOKEN="$1" infisical export --format=json --silent \
    --domain "${INFISICAL_API_URL:-https://infisical.marnas.sh/api}" \
    --projectId "$2" --env "${INFISICAL_ENV:-prod}" --path /git 2>/dev/null || true
}

fetch_key() {
  local token pid out
  token="$(infisical-token)"
  pid="$(infisical-token --field projectId)"
  out="$(export_secrets "$token" "$pid")"
  # Cached token may be expired; re-mint once and retry if the key didn't come back.
  if [ -z "$(ival GIT_SSH_KEY <<<"$out")" ]; then
    token="$(infisical-token --refresh)"
    out="$(export_secrets "$token" "$pid")"
  fi
  ival GIT_SSH_KEY <<<"$out"
}

# `ssh-add -l`: 0 = key loaded, 1 = agent up but empty, 2 = no agent on the socket.
rc=0
ssh-add -l >/dev/null 2>&1 || rc=$?
if [ "$rc" -eq 2 ]; then
  rm -f "$sock"
  ssh-agent -a "$sock" >/dev/null
  rc=1
fi
if [ "$rc" -eq 1 ]; then
  key="$(fetch_key)"
  [ -n "$key" ] || {
    echo "git-agent-seed: could not fetch GIT_SSH_KEY from Infisical (project=claude path=/git)" >&2
    exit 1
  }
  # -t 8h: any same-user process can use the agent socket, so bound how long
  # the key sits loaded. Expiry is free — `ssh-add -l` then returns 1 and the
  # next caller re-seeds without a prompt.
  printf '%s\n' "$key" | ssh-add -t 8h - >/dev/null 2>&1 || {
    echo "git-agent-seed: ssh-add rejected the key material (must be an unencrypted OpenSSH private key)" >&2
    exit 1
  }
fi

printf '%s\n' "$sock"
