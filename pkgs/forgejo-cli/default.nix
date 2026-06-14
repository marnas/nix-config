{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  installShellFiles,
  openssl,
  stdenv,
  darwin,
  writeShellApplication,
  symlinkJoin,
  jq,
}:
# Forgejo-native CLI (binary `fj`) — Codeberg's incubating-official tool. The exposed package
# is a WRAPPER: fj only reads its token from $XDG_DATA_HOME/forgejo-cli/keys.json (no env/flag
# token), so the wrapper materializes that file in tmpfs from Infisical per-invocation and
# removes it on exit — the credential never lands on persistent disk. See ./fj-seed.sh.
# The keys.json blob lives in Infisical project `claude`, path /forgejo, secret
# FORGEJO_KEYS_JSON. infisical + infisical-token are inherited from PATH (like git-agent).
let
  # Raw upstream build. Mirrors upstream's flake (pkg-config + openssl; git2/libssh2 are
  # vendored by their -sys crates).
  forgejo-cli = rustPlatform.buildRustPackage rec {
    pname = "forgejo-cli";
    version = "0.5.0";

    src = fetchFromGitea {
      domain = "codeberg.org";
      owner = "forgejo-contrib";
      repo = "forgejo-cli";
      rev = "v${version}";
      hash = "sha256-6qouGcqNau2aCBPYpn0hFdm8QXL1WjZvnowK4aspe/Q=";
    };

    cargoHash = "sha256-UPDhPKC/x0ccfm7Df74PtCn+Zt9ShCxf9uB5TVaYV6Y=";

    nativeBuildInputs = [
      pkg-config
      installShellFiles
    ];

    buildInputs = [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      # cross-platform: home-manager/cli/ is imported by the macOS host too
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    meta = {
      description = "CLI tool for Forgejo (binary: fj)";
      homepage = "https://codeberg.org/forgejo-contrib/forgejo-cli";
      license = with lib.licenses; [
        asl20
        mit
      ];
      mainProgram = "fj";
      platforms = lib.platforms.unix;
    };
  };

  fj = writeShellApplication {
    name = "fj";
    runtimeInputs = [ jq ];
    text = ''
      export FJ_REAL=${lib.getExe forgejo-cli}
      ${builtins.readFile ./fj-seed.sh}
    '';
  };
in
symlinkJoin {
  name = "forgejo-cli-${forgejo-cli.version}";
  paths = [ fj ];
  meta = forgejo-cli.meta // {
    description = "${forgejo-cli.meta.description} (Infisical-seeded wrapper)";
  };
}
