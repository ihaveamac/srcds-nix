{ 
  pkgs,
  lib,

  # Username of the runner
  user,
  # Groupname of the runner
  group,
  # Game name
  gameName,
  # Game state name (the <name> part of services.srcds.games.<name>)
  gameStateName,
  # Game/mod folder (e.g. tf, cstrike)
  gameFolder,
  # State directory to store server files in (like /var/lib/srcds/gamename)
  stateDir,
  # Steam AppID
  appId,
  # Requires workaround to download
  windowsWorkaround,
  # Game port
  gamePort,
  # Extra ConVar arguments
  extraArgs,
  # Starting map
  startingMap
}:

with lib;
let
  eStateDir = escapeShellArg stateDir;
  sAppId = toString appId;
  #sExtraArgs = lib.concatStringsSep " " (
  #  lib.mapAttrsToList (n: v:
  #    "+${n} ${if v != null then lib.escapeShellArg v else ""}"
  #  ) ((lib.optionalAttrs (startingMap != null) { map = startingMap; }) //
  #    extraCommandArgs) # this is put at the end to allow for manual overrides
  #);
  sExtraArgs = concatStringsSep " " (map (v: escapeShellArg v) (
    filter (v: v != null) (lists.flatten (
      [
        "-port" (toString gamePort)
      ] ++ (optional (startingMap != null) [ "+map" startingMap ])
      ++ extraArgs))));
in
{
  prepare = ''
    isNixStoreLink () {
      link=readlink "$1"
      if [[ "$link" != /nix/store/* ]]; then
        return 1
      else
        return 0
      fi
    }
    mkdir -p ${eStateDir}
  '';
  run = ''
    action=Initializing
    if test -d ${eStateDir}/${gameFolder}; then
      action=Updating
    fi
    cd ${eStateDir};
    echo "$action ${gameName} (${gameStateName})"

    ${if windowsWorkaround then ''
    if test -f srcds_linux; then
      steamcmd +force_install_dir ${eStateDir} +login anonymous +app_update ${sAppId} validate +exit
    else
      # the server for ${gameName} requires a workaround to download for Linux
      # (or we don't know if it does, in which case, we will do it anyway)
      steamcmd +force_install_dir ${eStateDir} +@sSteamCmdForcePlatformType windows +login anonymous +app_update ${sAppId} validate +exit
      steamcmd +force_install_dir ${eStateDir} +@sSteamCmdForcePlatformType linux +login anonymous +app_update ${sAppId} validate +exit
    fi
    '' else ''
    steamcmd +force_install_dir ${eStateDir} +login anonymous +app_update ${sAppId} validate +exit
    ''}

    echo "Running ${gameName} (${gameStateName})"
    steam-run ./srcds_run -game ${gameFolder} -nohltv -port ${toString gamePort} -strictportbind ${sExtraArgs}
  '';
}
