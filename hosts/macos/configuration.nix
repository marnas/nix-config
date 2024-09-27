{ pkgs, inputs, ... }: {
  imports = [
    ./system.nix

    ../shared/fish.nix
    ../shared/nix.nix
  ];

  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  # Necessary for using flakes on this system.
  nix = {
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  security.pam.enableSudoTouchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish = {
    enable = true;
    # Add Brew path to shell
    interactiveShellInit = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  environment = {
    shells = [ pkgs.bash pkgs.zsh pkgs.fish ];
    loginShell = pkgs.fish;

    #Allow touchIdAuth with tmux
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';
  };

  fonts = { packages = with pkgs; [ nerdfonts jetbrains-mono meslo-lgs-nf ]; };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    kubectl
    talosctl
    cargo
    docker
    fluxcd
    python3
  ];

  homebrew = {
    enable = true;
    global.autoUpdate = true;
    brews = [ "helm" ];

    casks = [
      #"hackintool"
      #"soulseek"
      #"karabiner-elements"
      #"opencore-configurator"

      "whatsapp"
      "the-unarchiver"
      "autodesk-fusion"
      "1password"
      "firefox"
      "garmin-express"
      "tailscale"
    ];
  };

  # home-manager.useUserPackages = true;
  # Set Git commit hash for darwin-version.
  system.configurationRevision =
    inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
