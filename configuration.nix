{ config, pkgs, lib, ... }:

{
  imports = [ ./modules/srcds ];

  services.srcds.enable = true;
  services.srcds.games.tf2 = {
    appId = 232330;
    gamePort = 27015;
    startingMap = "cs_office";
    extraConVarArgs.sv_password = "ihaveahax";
  };

  boot.enableContainers = false;
  boot.isContainer = true;
  networking.hostName = "srcds-container-test";
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  networking.useDHCP = false;
  system.stateVersion = "25.05";
}
