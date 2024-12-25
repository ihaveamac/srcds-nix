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
| Left 4 Dead | 222840 | left4dead |
| Left 4 Dead 2 | 222860 | left4dead2 |
| Team Fortress 2 | 232250 | tf |
| Day of Defeat: Source | 232290 | dod |
| Counter-Strike: Source | 232330 | cstrike |
| Half-Life 2: Deathmatch | 232370 | hl2mp |
| Source SDK Base 2013 | 244310 | (undefined) |
| Half-Life Deathmatch: Source | 255470 | hl1mp |
| Garry's Mod | 4020 | garrysmod |
| Counter-Strike: Global Offensive | 740 | csgo |

# Example

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

# Module options
## services\.srcds\.enable

Whether to enable the Source Dedicated Server module\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games



Game servers to run\. Each attribute name will store server files in a different directory, allowing for multiple servers of the same game\.



*Type:*
attribute set of (submodule)

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.allowUnknownId



Allow an unknown AppID\. The option ` gameFolder ` must be set if this is used\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.appId



Steam AppID for the game’s dedicated server\.



*Type:*
signed integer

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.config



Configuration to put in ` <gamedir>/cfg/server.cfg `\. If this file already exists and is not managed by NixOS, it will be renamed to avoid overwriting\. To store local configuration not managed by NixOS, put commands in ` <gamedir>/cfg/server_local.cfg `\.



*Type:*
attribute set of (string or signed integer)



*Default:*

```
{
  hostname = "My NixOS TF2 server";
  sv_contact = "you@example.com";
  sv_pure = 0;
}
```

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.extraArgs



Additional arguments to pass to ` srcds_run `\.



*Type:*
list of string



*Default:*
` [ ] `



*Example:*

```
[
  "-timeout"
  "0"
  "-nobots"
  "+randommap"
]
```

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.extraConfig



Additional configuration to put at the end of ` <gamedir>/cfg/server.cfg `\.



*Type:*
string



*Default:*
` "" `



*Example:*

```
''
  alias thing "say my thing alias"
  exec thing.cfg
''
```

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.gameFolder



The game folder to use\. This normally does not need to be set, as the value of ` appId ` will determine it, but there are two cases where it should be:

 - Source SDK Base 2013 Dedicated Server is being used
 - An AppID not known to this module is used

In this case it should be the name of the Source mod\. For example, with Team Fortress 2 Classic, the mod folder name is ` "tf2classic" `\.



*Type:*
string



*Default:*
` determined by appId `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.gamePort



Game port to open\. This is normally 27015, but is deliberately left without a default value to avoid conflicts with multiple servers\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.openFirewall



Whether to open firewall ports for this server\.



*Type:*
boolean



*Default:*
` config.services.srcds.openFirewall `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.rcon\.enable



Enable RCON\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.rcon\.password



Password to use for RCON\.



*Type:*
string



*Default:*
` "nixos" `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.startingMap



Starting map\.



*Type:*
null or string



*Default:*
` null `



*Example:*
` "pl_upward" `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)



## services\.srcds\.openFirewall



Whether to open firewall ports for all defined servers\. This can be overridden per-server by setting each one’s ` openFirewall ` option\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/home/ihaveahax/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Projects/srcds-nix/modules/srcds)


