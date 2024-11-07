{ pkgs, inputs, ... }: {
  programs.yazi = {
    enable = true;
    package = inputs.yazi.packages.${pkgs.system}.default;
  };

}
