# This fixes an issue with rendering the documentation, since it thinks programs.steam does not exist.

{ pkgs, lib, ... }:

with lib;
{
  options.programs.steam.dedicatedServer.openFirewall = mkOption {
    description = "Fake Steam module.";
    visible = false;
    default = false;
  };
}
