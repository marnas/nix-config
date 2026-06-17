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

  # The Forgejo Actions runner (iOS Simulator build/test for scry-app).
  environment.systemPackages = [ pkgs.forgejo-runner ];

  # Run as a LaunchAgent in marnas's login session so it inherits Xcode and the
  # dev toolchain (host executor — macOS has no container runtime here). The
  # runner is registered out-of-band (token from Forgejo); its `.runner`
  # credential lives in WorkingDirectory, never in this repo.
  launchd.user.agents.forgejo-runner = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.forgejo-runner}/bin/forgejo-runner"
        "daemon"
      ];
      WorkingDirectory = "/Users/marnas/.forgejo-runner";
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Users/marnas/.forgejo-runner/daemon.log";
      StandardErrorPath = "/Users/marnas/.forgejo-runner/daemon.err.log";
      # Jobs inherit this PATH — brew (xcodegen), /usr/bin (xcodebuild/xcrun),
      # and the nix system profile.
      EnvironmentVariables.PATH =
        "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:/run/current-system/sw/bin";
    };
  };
}
