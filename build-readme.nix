{ pkgs ? import <nixpkgs> {} }:

with builtins; with pkgs.lib;
let
  gameInfo = import ./modules/srcds/get-game-info.nix;
  renderedDoc = import ./render-doc.nix { inherit pkgs; };
in
pkgs.writeText "README.md" ''
# srcds-nix

> [!WARNING]
> WORK IN PROGRESS - Probably not functional, definitely not stable

Manage and run Source Dedicated Server games on NixOS.

# Games

I am aware some games are missing here, I'll add them eventually. For now if you want a missing game, set `appId`, `allowUnknownId`, and `gameFolder`.

| Game | AppID | Game Folder |
| --- | --- | --- |
${concatStringsSep "\n" (mapAttrsToList (n: v: "| ${v.game} | ${n} | ${if v.folder != null then v.folder else "(undefined)"} |") gameInfo.gameIds)}

# Module options

${readFile renderedDoc.optionsCommonMark}
''
