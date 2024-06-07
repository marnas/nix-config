{ pkgs, lib, inputs, config, ... }:
{
  # inputs.self, inputs.nix-darwin, and inputs.nixpkgs can be accessed here

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    alacritty
    kubectl
    vscode
    cargo
    discord
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true; # default shell on catalina
  environment = {
    shells = [ pkgs.bash pkgs.zsh pkgs.fish ];
    loginShell = pkgs.zsh;
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      nerdfonts
      jetbrains-mono
      meslo-lgs-nf
    ];
  };

  # This is used for showing linking system packages to Applications folder and show them with spotlight search
  system.activationScripts.postUserActivation.text = ''
    rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"
    apps_source="${config.system.build.applications}/Applications"
    moniker="Nix Trampolines"
    app_target_base="$HOME/Applications"
    app_target="$app_target_base/$moniker"
    mkdir -p "$app_target"
    ${pkgs.rsync}/bin/rsync $rsyncArgs "$apps_source/" "$app_target"
  '';

  homebrew = {
    enable = true;
    global.autoUpdate = true;
    casks = [
      "whatsapp"
      "hackintool"
      "soulseek"
      "karabiner-elements"
      "opencore-configurator"
      "the-unarchiver"
      "autodesk-fusion"
    ];
  };

  # home-manager.useUserPackages = true;


  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  # nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.hostPlatform = "x86_64-darwin";
}
