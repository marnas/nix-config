{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "mrtazz";
      plugins = [ ];
    };
    shellAliases = {
      ".." = "cd ..";
      "k" = "kubectl";
    };
    initExtra = "source <(kubectl completion zsh)";
  };
}
