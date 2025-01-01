{ pkgs, gameStateName, serverConfig, extraServerConfig, rcon }:

with pkgs;
let
  sServerConfig = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (n: v: let
      vType = builtins.typeOf v;
      args = if vType == "str" then v
        else if vType == "int" then toString v
        else if vType == "float" then toString v
        else throw "Unexpected type ${vType} given to services.srcds.games.${gameStateName}.config.${n}";
    in "${n} ${toString v}") serverConfig
  );
in
writeText "server.cfg" ''
//NIX-MANAGED
// -----------------------------------------------------------------
// DO NOT MANUALLY EDIT THIS FILE!
//
// This is generated by the srcds-nix NixOS module.
// You should edit your system config.
// Any changes to this file will be overwritten.
//
// If you want to edit a locally-stored config not managed by NixOS,
// create/edit the server_local.cfg file.
// -----------------------------------------------------------------

${lib.optionalString rcon.enable ''
// RCON (services.srcds.games.${gameStateName}.rcon)
rcon_password ${if rcon.password == "nixos" then
  (warn "the RCON password for ${gameStateName} is the default \"${rcon.password}\", you should change this by setting services.srcds.games.${gameStateName}.rcon.password" rcon.password)
  else rcon.password}
''}

// services.srcds.games.${gameStateName}.config
${sServerConfig}

// services.srcds.games.${gameStateName}.extraConfig
${extraServerConfig}

// Execute local commands.
exec server_local.cfg
''
