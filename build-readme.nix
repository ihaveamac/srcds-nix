{ pkgs ? import <nixpkgs> {} }:

with builtins; with pkgs.lib;
let
  gameInfo = import ./modules/srcds/get-game-info.nix;
  renderedDoc = import ./render-doc.nix { inherit pkgs; };
  text = pkgs.writeText "README.md" ''
    # srcds-nix
    <!--
      EDIT build-readme.nix INSTEAD OF THIS FILE

      nix-shell build-readme.nix
    -->

    > [!WARNING]
    > WORK IN PROGRESS - Probably not functional, definitely not stable. If you use this then you should recognize that options could change in totally breaking ways up until I decide that it's stable.

    Manage and run Source Dedicated Server games on NixOS.

    # Games

    I am aware some games are missing here, I'll add them eventually. For now if you want a missing game, set `appId`, `allowUnknownId`, and `gameFolder`.

    | Game | AppID | Game Folder |
    | --- | --- | --- |
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "| ${v.game} | ${n} | ${if v.folder != null then v.folder else "(undefined)"} |") gameInfo.gameIds)}

    # Module options
  '';
in pkgs.mkShellNoCC {
  name = "srcds-nix-readme-builder";
  shellHook = ''
    set -x
    cp ${text} README.md
    cat ${renderedDoc.optionsCommonMark} >> README.md
    set +x
    exit
  '';
}
