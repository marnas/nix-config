# Dotfiles repo

Nix flake managing NixOS + nix-darwin systems via home-manager. Two hosts: `marnas@nixos`, `marnas@macos`.

## Layout — respect module boundaries

Before introducing a new pattern, grep for an existing example and mirror it. A few things go in specific places:

- `pkgs/<name>/default.nix` — custom derivations (tmux plugins, helper scripts, anything nixpkgs-style). Register in `pkgs/default.nix`; they become `pkgs.<name>` via the `additions` overlay in `overlays/default.nix`. Template to follow: `pkgs/tilish-colemak/`.
- `overlays/default.nix` — nixpkgs modifications (`overrideAttrs`, version pins, the `stable` packages overlay).
- `home-manager/cli/<tool>.nix` — per-tool config. A plugin/package primarily *belongs to* a tool lives in that tool's module, even when another tool drives it. Example: a tmux plugin invoked by Claude hooks is still a tmux concern — package it in `pkgs/`, load it in `tmux.nix`, then reference its path from `claude/hooks.nix`. Don't define the plugin inside `claude/`.
- `home-manager/cli/claude/` — Claude-specific config only: settings, hooks wiring, custom agents/commands, global context.
- `hosts/<host>/` — host-specific system config.

## Building & activation

- Verify a change builds: `nix build --no-link '.#homeConfigurations."marnas@nixos".activationPackage'` (no activation, safe).
- For NixOS-level changes: `nix build --no-link '.#nixosConfigurations.nixos.config.system.build.toplevel'`.
- **Never run** `home-manager switch`, `nixos-rebuild`, or `darwin-rebuild` — the user activates manually.
- **Format before committing:** every `.nix` file must be formatted with `nixfmt` (the official RFC 166 formatter, `nixpkgs#nixfmt` — *not* `nixfmt-classic`). Run `nix run nixpkgs#nixfmt -- <files>` on anything you touch; the whole tree is kept nixfmt-clean.

## Conventions

- Cross-platform: anything in `home-manager/cli/` is imported by both NixOS and macOS hosts. Use `pkgs.stdenv.isLinux` / `isDarwin` for platform-conditional logic; don't assume Linux-only tools (e.g. `libnotify`) are available on macOS.
