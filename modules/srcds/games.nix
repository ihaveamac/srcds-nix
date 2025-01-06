globalConfig:

{ config, lib, pkgs, ... }:

with lib;
let
  cfg = globalConfig.services.srcds;
  gameInfo = import ./game-info.nix;
  boolToNum = b: if b then "1" else "0";
in
{
  options = with types; {
    appId = mkOption {
      description = "Steam AppID for the game's dedicated server.";
      type = int;
    };

    branch = mkOption {
      description = "Beta branch to download and update the server from.";
      type = str;
      default = "public";
      example = "prerelease";
    };

    allowUnknownId = mkOption {
      description = "Allow an unknown AppID. The option `gameFolder` must be set if this is used.";
      type = bool;
      default = false;
    };

    gameFolder = mkOption {
      description = "The game folder to use. This normally does not need to be set, as the value of `appId` will determine it, but there are two cases where it should be:\n\n* Source SDK Base 2013 Dedicated Server is being used\n* An AppID not known to this module is used\n\nIn this case it should be the name of the Source mod. For example, with Team Fortress 2 Classic, the mod folder name is `\"tf2classic\"`.";
      type = str;
      default = "AUTOMATIC";
      defaultText = literalExpression "determined by appId";
    };

    openFirewall = mkOption {
      description = "Whether to open firewall ports for this server.";
      type = bool;
      default = cfg.openFirewall;
      defaultText = literalExpression "config.services.srcds.openFirewall";
    };

    autoUpdate = mkOption {
      description = "Automatically check for and install updates. This should be disabled if using mods that patch game files. The initial installation will still be performed regardless of this setting.";
      type = bool;
      default = true;
    };

    gamePort = mkOption {
      description = "Game port to open. This is normally 27015, but is deliberately left without a default value to avoid conflicts with multiple servers.";
      type = port;
    };

    extraArgs = mkOption {
      description = "Additional arguments to pass to `srcds_run`.";
      type = listOf str;
      default = [];
      example = [ "-timeout" "0" "-nobots" "+randommap" ];
    };

    startingMap = mkOption {
      description = "Starting map.";
      type = nullOr str;
      default = null;
      example = "pl_upward";
    };

    insecure = mkOption {
      description = "Disable Valve Anti-Cheat.";
      type = bool;
      default = false;
    };

    serverConfig = mkOption {
      description = "Configuration to put in `<gamedir>/cfg/server.cfg`. If this file already exists and is not managed by NixOS, it will be renamed to avoid overwriting. To store local configuration not managed by NixOS, put commands in `<gamedir>/cfg/server_local.cfg`.";
      type = attrsOf (oneOf [ str int float ]);
      default = { hostname = "My NixOS TF2 server"; sv_pure = 0; sv_contact = "you@example.com"; };
    };

    extraServerConfig = mkOption {
      description = "Additional configuration to put at the end of `<gamedir>/cfg/server.cfg`.";
      type = str;
      default = "";
      example = ''
        alias thing "say my thing alias"
        exec thing.cfg
      '';
    };

    sourceTV = {
      # TODO: check that this can actually be used (not all source games support it!)
      enable = mkOption {
        description = "Enable SourceTV.";
        type = bool;
        default = false;
      };

      port = mkOption {
        description = "SourceTV port to open. This is usually 27020 (game port + 5), but is deliberately left without a default value to avoid conflicts with multiple servers.";
        type = port;
      };
    };

    rcon = {
      enable = mkOption {
        description = "Enable RCON.";
        type = bool;
        default = false;
      };
      password = mkOption {
        description = "Password to use for RCON.\n\nIf you would rather not expose it in your NixOS configuration, put it in a `server_local.cfg` file in `<gameFolder>/cfg`.";
        type = str;
        default = "";
      };
    };

    log = {
      enable = mkOption {
        description = "Enable logging. Sets `+log on`.";
        type = bool;
        default = true;
      };

      logToFile = mkOption {
        description = "Log to a file in the `<gameFolder>/logs` folder. Sets `+sv_logfile 1`.";
        type = bool;
        default = true;
      };

      compressOnExit = mkOption {
        description = "Compress log files on exit. Sets `+sv_logfilecompress 1`.";
        type = bool;
        default = true;
      };
    };

    finalArgs = mkOption {
      description = "Final set of command line args that are passed to `srcds_run`.";
      visible = false;
      type = listOf (nullOr str);
      readOnly = true;
    };
  };

  config = mkIf true {
    # pidfile is handlded separately in bootstrap-script.nix
    finalArgs = flatten (filter (v: v != null) ([
      "-port" (toString config.gamePort)
      "-strictportbind"
      (if config.log.enable then [
        "+log" "1"
        "+sv_logfile" (boolToNum config.log.logToFile)
        "+sv_logfilecompress" (boolToNum config.log.compressOnExit)
      ] else [ "+log 0" ])
      "+ip 0.0.0.0" # maybe this should be an option?
      (if config.sourceTV.enable then [ "+tv_enable" "1" "+tv_port" (toString config.sourceTV.port) ] else "-nohltv")
    ] ++ (optional (config.startingMap != null) [ "+map" config.startingMap ])
      ++ (optional (config.rcon.enable) "-usercon")
      ++ (optional (config.insecure) "-insecure")
      ++ config.extraArgs));
  };
}
