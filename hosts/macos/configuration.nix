{ pkgs, inputs, ... }: {
  imports = [
    ./aerospace.nix
    ./brew.nix
    ./system.nix

    ../shared/fish.nix
    ../shared/nix.nix
  ];

  nixpkgs = { hostPlatform = "aarch64-darwin"; };

  # Necessary for using flakes on this system.
  nix = {
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  ids.gids.nixbld = 350;

  # security.pam.enableSudoTouchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    zsh.enable = true; # default shell on catalina
    fish = {
      enable = true;
      # Add Brew path to shell
      interactiveShellInit = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
    };
  };

  environment = {
    shells = [ pkgs.bash pkgs.zsh pkgs.fish ];

    #Allow touchIdAuth with tmux
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    systemPackages = with pkgs; [ awscli2 cargo kubelogin python3 teleport ];
  };

  fonts = {
    packages = with pkgs; [ jetbrains-mono meslo-lgs-nf nerd-fonts.fira-code ];
  };

  # home-manager.useUserPackages = true;
  # Set Git commit hash for darwin-version.
  system.configurationRevision =
    inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
