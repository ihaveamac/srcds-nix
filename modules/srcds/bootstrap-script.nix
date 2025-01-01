{ 
  pkgs,
  lib,
  srcds-fhs-run,

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
  # Branch
  branch,
  # Requires workaround to download
  windowsWorkaround,
  # Command line arguments
  finalArgs,
  # Config for server.cfg
  serverConfig,
  # Extra config for server.cfg
  extraServerConfig,
  # Rcon
  rcon
}:

with lib;
let
  configBuilder = import ./config-builder.nix;
  serverCfg = configBuilder { inherit pkgs gameStateName serverConfig extraServerConfig rcon; };
  eStateDir = escapeShellArg stateDir;
  sAppId = toString appId;
  #sExtraArgs = lib.concatStringsSep " " (
  #  lib.mapAttrsToList (n: v:
  #    "+${n} ${if v != null then lib.escapeShellArg v else ""}"
  #  ) ((lib.optionalAttrs (startingMap != null) { map = startingMap; }) //
  #    extraCommandArgs) # this is put at the end to allow for manual overrides
  #);
  sExtraArgs = concatStringsSep " " (map (v: escapeShellArg v) finalArgs);
in
{
  prepare = ''
    mkdir -p ${eStateDir}
  '';
  run = ''
    nonExistantOrNixManaged () {
      # check if it doesn't exist first
      if [[ ! -f "$1" ]]; then
        return 0;
      fi

      # since it does exist, make sure it's nix-managed
      header=$(head -n 1 "$1")
      if [[ "x$header" == "x//NIX-MANAGED" ]]; then
        return 0;
      else
        return 1;
      fi
    }

    cd ${eStateDir};

    action=Initializing
    if test -d ${gameFolder}; then
      action=Updating
    fi
    echo "$action ${gameName} (${gameStateName})"

    ${if windowsWorkaround then ''
    if test -f srcds_linux; then
      steamcmd +force_install_dir $PWD +login anonymous +app_update ${sAppId} -beta ${branch} validate +exit
    else
      # the server for ${gameName} requires a workaround to download for Linux
      # (or we don't know if it does, in which case, we will do it anyway)
      steamcmd +force_install_dir $PWD +@sSteamCmdForcePlatformType windows +login anonymous +app_update ${sAppId} validate +exit
      steamcmd +force_install_dir $PWD +@sSteamCmdForcePlatformType linux +login anonymous +app_update ${sAppId} validate +exit
    fi
    '' else ''
    steamcmd +force_install_dir $PWD +login anonymous +app_update ${sAppId} validate +exit
    ''}

    if nonExistantOrNixManaged ${gameFolder}/cfg/server.cfg; then
      rm -f ${gameFolder}/cfg/server.cfg
    else
      echo "Moving the old server.cfg out of the way"
      mv ${gameFolder}/cfg/server.cfg ${gameFolder}/cfg/server-old-$RANDOM.cfg
    fi
    echo "Writing server.cfg"
    cp ${serverCfg} ${gameFolder}/cfg/server.cfg
    chmod 664 ${gameFolder}/cfg/server.cfg

    exec ${srcds-fhs-run}/bin/srcds-fhs-run $HOME/.local/share/Steam/ubuntu12_32/steam-runtime/run.sh -- ./srcds_run -console -game ${gameFolder} ${sExtraArgs}
  '';
}
