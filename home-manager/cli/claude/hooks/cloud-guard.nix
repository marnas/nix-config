{ pkgs }:
# PreToolUse guard for cloud-mutating CLIs (az, terraform/tofu). Three outcomes:
#   - a mutating subcommand → "ask": force the interactive prompt in every mode
#     (incl. auto), so an online write never slips through unreviewed.
#   - a command that is ONLY recognized read-only cloud calls → "allow": skip the
#     auto-mode classifier, which otherwise prompts on bare `terraform plan`.
#   - anything else (a foreign segment like `terraform plan && rm …`, or a CLI
#     behind a wrapper) → defer (exit 0): the normal flow / classifier decides,
#     since "allow" would rubber-stamp the WHOLE bash call.
# Wired in default.nix with `if` filters so it only spawns for these CLIs.
pkgs.writeShellApplication {
  name = "claude-cloud-guard";
  runtimeInputs = [
    pkgs.jq
    pkgs.gnused
  ];
  text = ''
    payload="$(cat)"
    cmd="$(jq -r '.tool_input.command // empty' <<<"$payload")"
    [ -z "$cmd" ] && exit 0

    offending=""
    reason=""
    readonly_seen=0 # at least one recognized read-only cloud segment
    foreign=0       # a segment that isn't a recognized az/terraform/tofu call
    # Split compound commands the way the permission matcher does (&&, ||, ;,
    # |, newlines) and also at $( so command substitutions are inspected.
    while IFS= read -r seg; do
      read -ra words <<<"$seg" || true
      [ "''${#words[@]}" -eq 0 ] && continue

      # Skip leading VAR=value assignments.
      i=0
      while [ "$i" -lt "''${#words[@]}" ] && [[ "''${words[$i]}" =~ ^[A-Za-z_][A-Za-z_0-9]*= ]]; do
        i=$((i + 1))
      done
      [ "$i" -ge "''${#words[@]}" ] && continue
      cli="''${words[$i]}"

      case "$cli" in
        az)
          # The az verb is the last group/verb word before the first flag.
          verb=""
          for ((j = i + 1; j < ''${#words[@]}; j++)); do
            w="''${words[$j]//)/}"
            [[ "$w" == -* ]] && break
            verb="$w"
          done
          case "$verb" in
            # Read-only verbs across az command groups.
            show | show-* | list | list-* | get | get-* | check | check-* | what-if | version | find | help) readonly_seen=1 ;;
            "")
              # No verb: `az`, `az --version`, `az --help` are read-only.
              case "''${words[$((i + 1))]:-}" in
                --version | --help | -h) readonly_seen=1 ;;
                *) offending="''${words[*]:$i}" ;;
              esac
              ;;
            *) offending="''${words[*]:$i}" ;;
          esac
          ;;

        terraform | tofu)
          # The verb is the first non-flag word (skipping globals like
          # -chdir=...); state and workspace carry a sub-verb.
          verb=""
          for ((j = i + 1; j < ''${#words[@]}; j++)); do
            w="''${words[$j]//)/}"
            [[ "$w" == -* ]] && continue
            if [ -z "$verb" ]; then
              verb="$w"
              [[ "$verb" == state || "$verb" == workspace ]] || break
            else
              verb="$verb $w"
              break
            fi
          done
          case "$verb" in
            # Read-only / local-only: plan refreshes but writes nothing
            # remote; init/get/providers/fmt only touch the local workdir.
            plan | validate | fmt | show | output | graph | console | version | providers | init | get | login | logout | metadata | help | "") readonly_seen=1 ;;
            "state list" | "state show" | "state pull" | "workspace list" | "workspace show" | "workspace select") readonly_seen=1 ;;
            *) offending="''${words[*]:$i}" ;;
          esac
          ;;

        # A non-cloud segment: can't safely blanket-allow, so remember it and
        # let the normal flow handle the whole command unless something mutates.
        *)
          foreign=1
          continue
          ;;
      esac

      if [ -n "$offending" ]; then
        reason="$cli command writes cloud state, review it: $offending"
        break
      fi
    done < <(sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g; s/|/\n/g; s/[$](/\n/g' <<<"$cmd")

    if [ -n "$offending" ]; then
      jq -n --arg reason "$reason" '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "ask",
          permissionDecisionReason: $reason
        }
      }'
    elif [ "$foreign" -eq 0 ] && [ "$readonly_seen" -eq 1 ]; then
      # Whole command is recognized read-only cloud calls: allow it, bypassing
      # the auto-mode classifier that would otherwise prompt on `terraform plan`.
      jq -n '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "allow",
          permissionDecisionReason: "read-only cloud command"
        }
      }'
    fi
    # Otherwise emit nothing → defer to the normal permission flow.
  '';
}
