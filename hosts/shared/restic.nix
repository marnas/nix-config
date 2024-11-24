let
  user = "marnas";
  backupRepo = "/mnt/backup/home";
  secretFile = "/secrets/restic";
in { ... }: {
  services.restic.backups = {
    homebackup = {
      user = "${user}";
      exclude = [ ".git/" ];
      initialize = true;
      passwordFile = "${secretFile}";
      paths = [
        "/home/${user}/Desktop/"
        "/home/${user}/Documents/"
        "/home/${user}/Music/"
        "/home/${user}/Pictures/"
        "/home/${user}/Templates/"
        "/home/${user}/Videos/"
      ];
      repository = "${backupRepo}";
    };
  };
}
