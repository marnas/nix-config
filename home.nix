{ config, pkgs, ... }:

let
  tilish-colemak = pkgs.tmuxPlugins.mkTmuxPlugin
  {
    pluginName = "tilish";
    version = "unstable-2023-05-12";
    src = pkgs.fetchFromGitHub {
      owner = "marnas";
      repo = "tmux-tilish";
      rev = "d81c007f29aa3d81f1381eda58dc1fd0524d55f1";
      sha256 = "sha256-HgzYBn0eEkG/HNGSZkWzFufnMDqxBfYUgAl6XzKT+zQ=";
    };
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "marnas";
  home.homeDirectory = "/home/marnas";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/marnas/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "neovim";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "mrtazz";
      plugins = [ ];
    }; 
    shellAliases = {
      ".." = "cd ..";
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    escapeTime = 10;
    baseIndex = 1;
    #shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs;
      [
        {
          plugin = tilish-colemak;
          extraConfig = ''
            set -g @tilish-default 'main-vertical'
            set -g @tilish-colemak 'on'
            set -g @tilish-navigator 'on'
          '';
        }
#        {
#	  plugin = tmuxPlugins.tilish;
#          extraConfig = ''
#            set -g @tilish-default 'main-vertical'
#          '';
#	}
        tmuxPlugins.better-mouse-mode
      ];
    extraConfig = ''
      bind -n S-Up resize-pane -U 5
      bind -n S-Down resize-pane -D 5
      bind -n S-Left resize-pane -L 5
      bind -n S-Right resize-pane -R 5
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
