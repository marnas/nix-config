{ pkgs, inputs, ... }:
# Minimal nix-darwin host for the Mac mini "minios" — a headless iOS build host
# and Forgejo Actions runner for scry-app CI. System-level only (no home-manager).
# Secrets (runner token, signing keychain pw) live in Infisical, never here:
# nix-config is a public repo.
{
  imports = [
    ../shared/nix.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "marnas";
  system.stateVersion = 4;

  # The modern Nix installer creates the nixbld group with GID 350 (was 30000);
  # match it so nix-darwin doesn't abort activation. (Same as the macos host.)
  ids.gids.nixbld = 350;
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # The Forgejo Actions runner + the tools its jobs need (scry-app iOS CI:
  # build/test on the iOS Simulator). node is required by JS actions like
  # actions/checkout; xcodegen generates the project. xcodebuild comes from Xcode
  # (/usr/bin). Pulling these from nixpkgs keeps CI off any brew dependency.
  environment.systemPackages = [
    pkgs.forgejo-runner
    pkgs.nodejs_22
    pkgs.xcodegen
  ];

  # Run as a LaunchAgent in marnas's login session so it inherits Xcode and the
  # dev toolchain (host executor — macOS has no container runtime here). The
  # runner is registered out-of-band (token from Forgejo); its `.runner`
  # credential lives in WorkingDirectory, never in this repo.
  launchd.user.agents.forgejo-runner = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.forgejo-runner}/bin/forgejo-runner"
        "daemon"
        "--config"
        "/Users/marnas/.forgejo-runner/config.yml"
      ];
      WorkingDirectory = "/Users/marnas/.forgejo-runner";
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Users/marnas/.forgejo-runner/daemon.log";
      StandardErrorPath = "/Users/marnas/.forgejo-runner/daemon.err.log";
      # Jobs inherit this PATH: nix system profile first (node, xcodegen,
      # forgejo-runner), then /usr/bin (xcodebuild/xcrun/git). brew kept last as a
      # fallback but CI no longer depends on it.
      EnvironmentVariables.PATH =
        "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin";
    };
  };
}
