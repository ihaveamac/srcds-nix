{ pkgs ? import <nixpkgs> {} }:

with builtins; with pkgs.lib;
let
  gameInfo = import ./modules/srcds/game-info.nix;
  renderedDoc = import ./render-doc.nix { inherit pkgs; };
  text = pkgs.writeText "README.md" ''
    # srcds-nix
    <!--
      EDIT build-readme.nix INSTEAD OF THIS FILE

      nix-shell build-readme.nix
    -->

    > [!WARNING]
    > WORK IN PROGRESS - The module does not have a stable interface. If you use this then you should recognize that options could change in totally breaking ways up until I decide that it's stable.

    Manage and run Source Dedicated Server games on NixOS.

    Unlike other projects like [nix-garrys-mod](https://github.com/TGRCdev/nix-garrys-mod), this module does not attempt to download and store the dedicated server software as a Nix derivation. Instead, it generates systemd units that download the software with steamcmd at launch, then applies configurations to files like `server.cfg`. The upsides mean this the module can easily support more games, and automatically use the latest updates, but the downside is the server is a little less reproducible.

    ## Games

    | Game | AppID | Game Folder |
    | --- | --- | --- |
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "| ${v.game} | ${n} | ${if v.folder != null then v.folder else "(undefined)"} |") gameInfo.gameIds)}

    ## Install

    ### Flake

    Add this repo to your flake inputs:
    ```nix
    srcds-nix.url = "github:ihaveamac/srcds.nix";
    ```

    Add `srcds-nix` to the `outputs` arguments.

    Add to `modules` of the NixOS system:
    ```
    modules = [
      srcds-nix.nixosModules.default
    ];
    ```

    ## Example

    This will set up a server for Counter-Strike: Source, enable RCON, and configure it. Server files will be stored at `/var/lib/srcds/my-css-server`.

    ```nix
    services.srcds = {
      enable = true;
      openFirewall = true;
      games = {
        my-css-server = {
          appId = 232330;
          gamePort = 27015;
          rcon = {
            enable = true;
            password = "secretpass";
          };
          config = {
            hostname = "My CSS server on NixOS!";
            sv_password = "entrypass";
            sv_contact = "you@example.com";
          };
        };
      };
    };
    ```

    ## Module options

    Please see [the module options list](OPTIONS.md).
  '';
in pkgs.mkShellNoCC {
  name = "srcds-nix-readme-builder";
  shellHook = ''
    set -x
    cp ${text} README.md
    cat ${renderedDoc.optionsCommonMark} > OPTIONS.md
    set +x
    exit
  '';
}
