{ config, lib, pkgs, ... }:

with lib;
let
  globalcfg = config.services.srcds;
  gameInfo = import ./get-game-info.nix;
in
{
  options = {
    appId = mkOption {
      description = "Steam AppID for the game's dedicated server.";
      type = types.int;
    };

    allowUnknownId = mkOption {
      description = "Allow an unknown AppID. The option `gameFolder` must be set if this is used.";
      type = types.bool;
      default = false;
    };

    gameFolder = mkOption {
      description = "The game folder to use. This normally does not need to be set, as the value of `appId` will determine it, but there are two cases where it should be:\n\n* Source SDK Base 2013 Dedicated Server is being used\n* An AppID not known to this module is used\n\nIn this case it should be the name of the Source mod. For example, with Team Fortress 2 Classic, the mod folder name is `\"tf2classic\"`.";
      type = types.str;
      default = "AUTOMATIC";
      defaultText = literalExpression "determined by appId";
    };

    openFirewall = mkOption {
      description = "Whether to open firewall ports for this server.";
      type = types.bool;
      default = globalcfg.openFirewall;
    };

    gamePort = mkOption {
      description = "Game port to open. This is normally 27015, but is deliberately left without a default value to avoid conflicts with multiple servers.";
      type = types.port;
    };

    extraArgs = mkOption {
      description = "Additional arguments to pass to `srcds_run`.";
      type = types.listOf types.str;
      default = [];
      example = [ "-timeout" "0" "-nobots" "+randommap" ];
    };

    startingMap = mkOption {
      description = "Starting map.";
      type = types.nullOr types.str;
      default = null;
      example = "pl_upward";
    };
  };
}
