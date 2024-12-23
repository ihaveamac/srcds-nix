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
in
{
  options.services.srcds = {
    enable = mkEnableOption "the Source Dedicated Server module";
    
    openGameFirewall = mkOption {
      description = "Open game firewall ports for all defined servers. This can be overridden per-server by setting each one's `openGameFirewall` option.";
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
    environment.etc = listToAttrs (
      mapAttrsToList (n: v: let
        gameFolder = getGameFolder v;
      in {
        name = "srcds/${n}";
        value = { text = "APPID=${toString v.appId}\nGAMEFOLDER=${escapeShellArg gameFolder}\n"; };
      }) cfg.games
    );

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

    systemd.services = listToAttrs (
      mapAttrsToList (n: v: let
        gameFolder = getGameFolder v;
        gameName = getGameName v;
        scripts = mkScripts {
          inherit pkgs lib gameFolder gameName;
          inherit (v) appId gamePort extraConVarArgs startingMap;
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
            WorkingDirectory = "/var/lib/srcds/${n}";
            User = username;
            Group = username;
          };
        };
      }) cfg.games
    );
  };
}
