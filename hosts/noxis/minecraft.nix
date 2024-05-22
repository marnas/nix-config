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
	  package = pkgs.paperServers.paper-1_20_6;
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
        "ops.json".value = [
	      {
            uuid = "99b2b8c3-02f9-468c-b384-b30bcb0dbc11";
            name = "marnas1";
            level = 4;
          },
          {
            uuid = "7988a16b-09f8-3d10-8d65-d0abd7edc00a";
            name = "marnas1";
            level = 4;
          }
		];
      };

	  symlinks = {
        "plugins/SkinsRestorer.jar" = pkgs.fetchurl rec {
          pname = "SkinsRestorer";
          version = "15.0.13";
          url = "https://github.com/SkinsRestorer/${pname}/releases/download/${version}/${pname}.jar";
          hash = "sha256-8lRixoervHFvlSQ2gnMerQXr2xK3/bY2hzqQl6qlaMo=";
        };
      };
    };
  };

}
