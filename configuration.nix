{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./modules/srcds/default.nix ];

  services.srcds.enable = true;
  services.srcds.openFirewall = true;
  services.srcds.games.cstrike = {
    appId = 232330;
    gamePort = 27015;
    startingMap = "cs_office";
    autoUpdate = true;
    rcon = {
      enable = true;
      password = "ihaveahax";
    };
    serverConfig.hostname = "test";
    extraServerConfig = ''
      echo test
    '';
  };
  services.srcds.games.cstrike2 = {
    appId = 232330;
    gamePort = 27016;
    startingMap = "cs_office";
    autoUpdate = false;
    rcon = {
      enable = true;
      password = "ihaveahax";
    };
    serverConfig.hostname = "test";
    extraServerConfig = ''
      echo test
    '';
  };

  boot.enableContainers = false;
  boot.isContainer = true;
  networking.hostName = "srcds-container-test";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  networking.useDHCP = false;
  system.stateVersion = "25.05";
}
