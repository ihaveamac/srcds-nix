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
  # Game port
  gamePort,
  # Extra ConVar arguments
  extraConVarArgs,
  # Starting map
  startingMap
}:

let
  eStateDir = lib.escapeShellArg stateDir;
  sAppId = toString appId;
  sExtraConVarArgs = lib.concatStringsSep " " (
    lib.mapAttrsToList (n: v:
      "+${n} ${lib.escapeShellArg v}"
    ) (extraConVarArgs //
      (lib.optionalAttrs (startingMap != null) { map = startingMap; })
    )
  );
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
    chown ${user}:${group} ${eStateDir}
  '';
  run = ''
    action=Initializing
    if test -d ${eStateDir}/${gameFolder}; then
      action=Updating
    fi
    echo "$action ${gameName} (${gameStateName})"
    steamcmd +force_install_dir ${eStateDir} +login anonymous +app_update ${sAppId} validate +exit
    echo "Running ${gameName} (${gameStateName})"
    steam-run ./srcds_run -game ${gameFolder} -nohltv -port ${toString gamePort} -strictportbind ${sExtraConVarArgs}
  '';
}
