{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.srcds;
  # this breaks render-doc.nix
  #steamcfg = config.programs.steam;
  username = "srcds";
  gameInfo = import ./get-game-info.nix;
  srcds-run = pkgs.callPackage ./srcds-run.nix {};
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
      #default = steamcfg.dedicatedServer.openFirewall;
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

    networking.firewall.allowedTCPPorts = filter (v: v != null) (
      mapAttrsToList (n: v:
        if v.openFirewall && v.rcon.enable then v.gamePort else null
      ) cfg.games
    );

    systemd.sockets = listToAttrs (
      mapAttrsToList (n: v: let
        gameName = getGameName v;
      in {
        name = "srcds-game-${n}";
        value = {
          description = "Standard input for ${gameName} (${n})";
          partOf = [ "srcds-game-${n}.service" ];
          socketConfig = {
            ListenFIFO = "%t/srcds-game-${n}.stdin";
            SocketMode = "0660";
            SocketUser = username;
            SocketGroup = username;
            RemoveOnStop = true;
            FlushPending = true;
          };
        };
      }) cfg.games
    );

    systemd.services = mkMerge [
      {
        srcds-setup = {
          description = "Source Dedicated Server setup";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            User = username;
            Group = username;
          };
          path = with pkgs; [ gnutar xz steamcmd srcds-run ];
          script = ''
            # Ensure steamcmd is up to date
            steamcmd +exit

            # Ensure Steam runtime
            if [[ ! -d $HOME/.local/share/Steam/ubuntu12_32 ]]; then
              tar -C $HOME/.local/share/Steam -xvf ${pkgs.steam-unwrapped}/lib/steam/bootstraplinux_ubuntu12_32.tar.xz 
              srcds-run $HOME/.local/share/Steam/ubuntu12_32/steam-runtime/setup.sh
            fi
          '';
        };
      }
      
      (listToAttrs (
        mapAttrsToList (n: v: let
        gameName = getGameName v;
          gameFolder = getGameFolder v;
          windowsWorkaround = needsWorkaround v;
          scripts = mkScripts {
            inherit pkgs lib gameFolder gameName windowsWorkaround;
            inherit (v) appId branch gamePort extraArgs startingMap rcon config extraConfig;
            user = username;
            group = username;
            gameStateName = n;
            stateDir = "/var/lib/srcds/${n}";
          };
        in {
          name = "srcds-game-${n}";
          value = {
            description = "Server runner for ${gameName} (${n})";
            wants = [ "network-online.target" ];
            after = [ "srcds-setup.service" "network-online.target" "srcds-game-${n}.socket" ];
            wantedBy = [ "multi-user.target" ];
            requires = [ "srcds-setup.service" "srcds-game-${n}.socket" ];
            preStart = scripts.prepare;
            script = scripts.run;
            path = with pkgs; [ steamcmd srcds-run ];
            serviceConfig = {
              StateDirectory = "srcds";
              StateDirectoryMode = "0775";
              User = username;
              Group = username;
              UMask = "0002";
              StandardInput = "socket";
              StandardOutput = "journal";
              StandardError = "journal";
            };
          };
        }) cfg.games
      ))
    ];
  };
}
