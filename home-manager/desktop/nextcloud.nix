{ ... }:
{
  # Declarative Nextcloud desktop-client ignore list.
  #
  # Nextcloud has NO server-side mechanism to push ignore patterns to clients,
  # so the list is per-machine. We manage it here and the flake deploys it to
  # every host -> edit once, `home-manager switch` on each machine.
  #
  # The client reads ~/.config/Nextcloud/sync-exclude.lst (XDG config dir). Once
  # deployed this is a read-only nix-store symlink, so the GUI "Edit Ignored
  # Files" can no longer modify it -- edit THIS file instead.
  #
  # Contents = upstream stock defaults + our cache/build-dir additions.
  xdg.configFile."Nextcloud/sync-exclude.lst".text = ''
    # This file contains fixed global exclude patterns

    *~
    ~$*
    .~lock.*
    ~*.tmp
    ]*.~*
    ]Icon\r*
    ].DS_Store
    ].ds_store
    *.textClipping
    ._*
    ]Thumbs.db
    ]photothumb.db
    System Volume Information

    .*.sw?
    .*.*sw?

    ].TemporaryItems
    ].Trashes
    ].DocumentRevisions-V100
    ].Trash-*
    .fseventd
    .apdisk
    .Spotlight-V100

    .directory

    *.part
    *.filepart
    *.crdownload

    *.kate-swp
    *.gnucash.tmp-*

    .synkron.*
    .sync.ffs_db
    .symform
    .symform-store
    .fuse_hidden*
    *.unison
    .nfs*

    # (default) metadata files created by Syncthing
    .stfolder
    .stignore
    .stversions

    My Saved Places.

    \#*#

    *.sb-*

    # --- custom: dev cache / build dirs (regenerable, never sync) ---
    # JS / TS
    node_modules
    .pnpm
    .pnpm-store
    .yarn
    .npm
    .next
    .nuxt
    .svelte-kit
    .turbo
    .parcel-cache
    dist
    build
    # Rust
    target
    # Python
    __pycache__
    .venv
    venv
    .tox
    .mypy_cache
    .pytest_cache
    .ruff_cache
    # Python virtualenvs under Documents/klipper-backup
    moonraker-env
    klippy-env
    mobileraker-env
    # IaC / tooling
    .terraform
    .gradle
    .cache
    # Nix / direnv
    .direnv
    # NOTE: not excluding `.git` (33 repos synced) -- doing so would sync a repo
    # without its history and risk corruption from two machines writing it. If you
    # want it ignored, add a `.git` line here; better, stop syncing repos via
    # Nextcloud and use git remotes instead.
  '';
}
