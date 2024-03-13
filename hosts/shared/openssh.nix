{
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };

  users.users.marnas = {
    openssh.authorizedKeys.keys = [
      "./ssh_host_rsa_key.pub"
    ];

  };
}
