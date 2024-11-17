{ ... }: {
  # Define VPN network namespace
  vpnNamespaces.wg = {
    enable = true;
    wireguardConfigFile = "/secrets/wg0.conf";
    accessibleFrom = [ "192.168.0.0/24" ];
    portMappings = [{
      from = 9091;
      to = 9091;
    }];
    openVPNPorts = [{
      port = 60729;
      protocol = "both";
    }];
  };

  # Add systemd service to VPN network namespace.
  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "wg";
  };

  services.transmission = {
    enable = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0"; # Bind RPC/WebUI to bridge address
      download-dir = "/mnt/media/";
      incomplete-dir-enabled = false;
      download-queue-enabled = false;
      upload-limit-enabled = true;
    };
  };
}
