{ ... }: {

  # Enable and config the avizo notification daemon for multimedia keys
  services.avizo = {
    enable = true;
    settings = {
      default = {
        time = 1.0;
        # y-offset = 0.5;
        fade-in = 0.1;
        fade-out = 0.2;
        # padding = 10;
      };
    };
  };
}
