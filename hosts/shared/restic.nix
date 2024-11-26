let
  user = "marnas";
  backupRepo = "/mnt/backup";
  envFile = "/secrets/s3_env";
  passwordFile = "/secrets/restic";
  repositoryFile = "/secrets/repository";
  homeBackup = [
    "/home/${user}/Desktop/"
    "/home/${user}/Documents/"
    "/home/${user}/Music/"
    "/home/${user}/Pictures/"
    "/home/${user}/Templates/"
    "/home/${user}/Videos/"
  ];
in { pkgs, ... }: {
  services.restic.backups = {
    homebackup = {
      user = "${user}";
      exclude = [ ".git/" ];
      initialize = true;
      passwordFile = "${passwordFile}";
      repository = "${backupRepo}";
      paths = homeBackup;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 2"
        "--keep-yearly 0"
      ];
      extraBackupArgs = [ "--exclude-caches" ];
      timerConfig = {
        OnCalendar = "daily"; # Empty string to disable the timer
        Persistent = true;
      };
    };
    s3backup = {
      initialize = true;
      user = "${user}";
      environmentFile = "${envFile}";
      repositoryFile = "${repositoryFile}";
      passwordFile = "${passwordFile}";
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 2"
        "--keep-yearly 0"
      ];
      paths = homeBackup;
      backupPrepareCommand =
        "${pkgs.restic}/bin/restic unlock"; # necessary to prevent locks from persisting indefinitely. See more:
      # https://forum.restic.net/t/restic-unlock-automation/5511
      extraBackupArgs = [ "--exclude-caches" ];
      timerConfig = {
        OnCalendar = "daily"; # Empty string to disable the timer
        Persistent = true;
      };
    };
  };
}
