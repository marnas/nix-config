{ pkgs, config, ... }: {

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
  ];

  environment.systemPackages = with pkgs; [
    nfs-utils
    k3s
  ];

  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
  };

  environment.variables = {
    PATH = [
      "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    ];
  };

}
