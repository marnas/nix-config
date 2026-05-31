# User

- Marco Santonastaso <marco@santonastaso.com>
- Default shell is fish. Suggested commands should be fish-compatible (or call out when they're bash-only).
- Primary machine is NixOS, managed via the flake at `~/.dotfiles`. Prefer Nix-native solutions (home-manager modules, overlays, flake inputs) over imperative installs (`curl | sh`, `npm i -g`, language-version managers).
- Do **not** use the auto-memory system (`~/.claude/projects/<slug>/memory/`). Memories are per-host, opaque, and don't sync between machines. When you learn something worth persisting, add it to this file (or the relevant module under `~/.dotfiles/home-manager/cli/claude/`) so it's version-controlled and visible.

# Working style

- Prioritize primary sources over assumptions. When working with a library, tool, config format, or API, fetch the official docs / module source / man page before guessing. `WebFetch` and `WebSearch` are pre-authorized — use them. For Nix, read the module source under `/nix/store/...-source/modules/...` directly.
- If you're inferring behavior from a name or analogy and haven't actually verified it, say so.
- Keep replies condensed — minimum words to convey the point. No preamble, no recap, no trailing "let me know if…". I'll ask for more detail when I want it.
- Avoid chaining read-only bash commands with `&&` or `|`, and skip `2>/dev/null` on allowlisted commands. Compound forms fall through to the `ask` rule even when each piece is individually allowed. Issue separate parallel Bash tool calls instead.

- Commit style: conventional commits, single-line subject only. Format `<type>(<scope>): <subject>`. Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `style`, `test`, `build`, `ci`, `perf`. Scope is the affected area (e.g. `claude`, `tmux`, `settings`, `pkgs`). No body, no `Co-Authored-By` trailer.
