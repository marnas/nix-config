# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    # postman = prev.postman.overrideAttrs (old: rec {
    #   version = "20230716100528";
    #   src = final.fetchurl {
    #     url = "https://web.archive.org/web/${version}/https://dl.pstmn.io/download/latest/linux_64";
    #     sha256 = "sha256-svk60K4pZh0qRdx9+5OUTu0xgGXMhqvQTGTcmqBOMq8=";
    #
    #     name = "${old.pname}-${version}.tar.gz";
    #   };
    # });

    openldap = prev.openldap.overrideAttrs (_: {
      doCheck = !prev.stdenv.hostPlatform.isi686;
    });

    # Pin claude-code ahead of nixpkgs-unstable (which lags the upstream release).
    # Mirrors the package's own platformKey logic; checksums are the hex sha256s
    # from https://downloads.claude.ai/claude-code-releases/<version>/manifest.json.
    # Drop this once nixpkgs catches up.
    claude-code =
      let
        version = "2.1.170";
        checksums = {
          "darwin-arm64" = "e903646d8b7a31882a80ecd27569a27d8ac57b3708745f349709632c84117fdf";
          "darwin-x64" = "914f23a70bbed5d9ae567e3e04b86206ed9971b371bc9baca3f79c8885bfddb4";
          "linux-arm64" = "1bb9d032440a75532f7dd4cafbc687f220aaf16c63eba17e192dfbec2f04bd25";
          "linux-x64" = "849e007277a0442ab27570d3e3d6d43787507946590e8dd1947e5a39b7081f9e";
        };
        platformKey = "${prev.stdenv.hostPlatform.node.platform}-${prev.stdenv.hostPlatform.node.arch}";
      in
      prev.claude-code.overrideAttrs {
        inherit version;
        src = prev.fetchurl {
          url = "https://downloads.claude.ai/claude-code-releases/${version}/${platformKey}/claude";
          sha256 = checksums.${platformKey};
        };
      };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
