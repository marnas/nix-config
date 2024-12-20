{ ... }: {

  services.transmission = {
    enable = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0"; # Bind RPC/WebUI to bridge address
      rpc-whitelist-enabled = false;
      download-dir = "/mnt/media/";
      incomplete-dir-enabled = false;
      download-queue-enabled = false;
      upload-limit-enabled = true;
    };
  };

}
