{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.srcds;
  #steamcfg = config.programs.steam;
  username = "srcds";
  gameInfo = import ./get-game-info.nix;
  getGameFolder = v: if v.gameFolder != "AUTOMATIC" then v.gameFolder else (gameInfo.get v.appId).folder;
  getGameName = v: let gi = gameInfo.get v.appId; in if gi == null then "Unknown SRCDS" else gi.game;
  mkScripts = import ./bootstrap-script.nix;
  needsWorkaround = v: let gi = gameInfo.get v.appId; in if gi == null then true else gi.windowsWorkaround;
in
{
  options.services.srcds = {
    enable = mkEnableOption "the Source Dedicated Server module";
    
    openFirewall = mkOption {
      description = "Whether to open firewall ports for all defined servers. This can be overridden per-server by setting each one's `openFirewall` option.";
      type = types.bool;
      default = false;
    };
    
    games = mkOption {
      description = "Game servers to run. Each attribute name will store server files in a different directory, allowing for multiple servers of the same game.";
      type = types.attrsOf (types.submodule (import ./games.nix { inherit config lib pkgs; }));
    };
  };

  config = mkIf cfg.enable {
    assertions = filter (v: v.message != null) (mapAttrsToList (n: v: { assertion = false; message = gameInfo.checkAssertion n v; }) cfg.games);
    warnings = filter (v: v != null) (mapAttrsToList (n: v: gameInfo.checkWarning n v) cfg.games);

    # TODO: make this support other users
    users.users = optionalAttrs (username == "srcds") {
      srcds = {
        group = "srcds";
        isSystemUser = true;
        home = "/var/lib/srcds";
      };
    };

    users.groups.srcds = {};

    environment.systemPackages = with pkgs; [ steamcmd ];

    networking.firewall.allowedUDPPorts = filter (v: v != null) (
      mapAttrsToList (n: v:
        if v.openFirewall then v.gamePort else null
      ) cfg.games
    );

    #networking.firewall.allowedTCPPorts = filter (v: v != null) (
    #  mapAttrsToList (n: v:
    #    if v.openFirewall and v.rcon.enable then v.gamePort else null
    #  ) cfg.games
    #);

    systemd.services = listToAttrs (
      mapAttrsToList (n: v: let
        gameFolder = getGameFolder v;
        gameName = getGameName v;
        windowsWorkaround = needsWorkaround v;
        scripts = mkScripts {
          inherit pkgs lib gameFolder gameName windowsWorkaround;
          inherit (v) appId gamePort extraArgs startingMap;
          user = username;
          group = username;
          gameStateName = n;
          stateDir = "/var/lib/srcds/${n}";
        };
      in {
        name = "srcds-${n}";
        value = {
          description = "Server runner for ${gameName} (${n})";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          preStart = scripts.prepare;
          script = scripts.run;
          path = with pkgs; [ steamcmd steam-run ];
          serviceConfig = {
            StateDirectory = "srcds";
            StateDirectoryMode = "0775";
            User = username;
            Group = username;
            UMask = "0002";
          };
        };
      }) cfg.games
    );
  };
}
