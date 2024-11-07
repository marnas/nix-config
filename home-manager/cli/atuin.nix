{ ... }: {
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://atuin.marnas.sh";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      search_mode_shell_up_key_binding = "prefix";
      enter_accept = true;
      sync = { records = true; };
    };
  };
}
