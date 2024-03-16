{ pkgs, inputs, config, lib, ... }: {

  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.survival = {
      enable = true;
      package = pkgs.paperServers.paper-1_20_4;
      autoStart = true;
      enableReload = true;
      serverProperties = {
        server-port = 25570;
        online-mode = true;
        view-distance = 25;
        difficulty = 2;
        gamemode = "survival";
        motd = "NixOS Minecraft server!";
      };

      files = {
        "ops.json".value = [{
          uuid = "99b2b8c3-02f9-468c-b384-b30bcb0dbc11";
          name = "marnas1";
          level = 4;
        }];
      };
    };
  };

}
