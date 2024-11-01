{ ... }: {
  programs.git = {
    enable = true;
    userName = "Marco Santonastaso";
    userEmail = "marco@santonastaso.com";
    signing = {
      key =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsvPRe5Uk+ZlUjJ5WTZR9PstHLqpWHPX1mRovLCEIsa";
      signByDefault = true;
    };
    extraConfig = {
      gpg.format = "ssh";
      "gpg \"ssh\"".program =
        "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
