{ config, pkgs, lib, ... }:

{
  imports = [ ./modules/srcds ];

  services.srcds.enable = true;
  services.srcds.openFirewall = true;
  services.srcds.games.cstrike = {
    appId = 232330;
    gamePort = 27015;
    startingMap = "cs_office";
    rcon = {
      enable = true;
      password = "ihaveahax";
    };
    config.hostname = "test";
    extraConfig = ''
      echo test
    '';
  };
  services.srcds.games.swarm = {
    appId = 635;
    gamePort = 1;
    gameFolder = "swarm";
  };

  boot.enableContainers = false;
  boot.isContainer = true;
  networking.hostName = "srcds-container-test";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  networking.useDHCP = false;
  system.stateVersion = "25.05";
}
