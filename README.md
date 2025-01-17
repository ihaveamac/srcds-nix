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

> [!WARNING]
> Source 2 games don't work yet. Don't try to run Counter-Strike 2 with this module until it's finished.

| Game | AppID | Game Folder |
| --- | --- | --- |
| Left 4 Dead | 222840 | left4dead |
| Left 4 Dead 2 | 222860 | left4dead2 |
| Team Fortress 2 | 232250 | tf |
| Day of Defeat: Source | 232290 | dod |
| Counter-Strike: Source | 232330 | cstrike |
| Half-Life 2: Deathmatch | 232370 | hl2mp |
| Source SDK Base 2013 | 244310 | (undefined) |
| Half-Life Deathmatch: Source | 255470 | hl1mp |
| Black Mesa | 346680 | bms |
| Garry's Mod | 4020 | garrysmod |
| Counter-Strike 2 | 730 | game/csgo |
| Counter-Strike: Global Offensive | 740 | csgo |

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
