# User

- Marco Santonastaso <marco@santonastaso.com>
- Default shell is fish. Suggested commands should be fish-compatible (or call out when they're bash-only).
- Primary machine is NixOS, managed via the flake at `~/.dotfiles`. Prefer Nix-native solutions (home-manager modules, overlays, flake inputs) over imperative installs (`curl | sh`, `npm i -g`, language-version managers).
- Per-project auto-memory lives under `~/.claude/projects/<slug>/memory/MEMORY.md` — that's the source of truth for project-specific facts, not this file.

# Working style

- Prioritize primary sources over assumptions. When working with a library, tool, config format, or API, fetch the official docs / module source / man page before guessing. `WebFetch` and `WebSearch` are pre-authorized — use them. For Nix, read the module source under `/nix/store/...-source/modules/...` directly.
- If you're inferring behavior from a name or analogy and haven't actually verified it, say so.
- Keep replies condensed — minimum words to convey the point. No preamble, no recap, no trailing "let me know if…". I'll ask for more detail when I want it.
