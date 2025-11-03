{ pkgs, vars, ... }: {
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Marco Santonastaso";
          email = "marco@santonastaso.com";
        };
        gpg.format = "ssh";
        "gpg \"ssh\"".program = if (vars.hostname == "macos") then
          "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else
          "${pkgs._1password-gui}/bin/op-ssh-sign";
      };
      signing = {
        key =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsvPRe5Uk+ZlUjJ5WTZR9PstHLqpWHPX1mRovLCEIsa";
        signByDefault = true;
      };
    };
    lazygit = { enable = true; };
  };
}
