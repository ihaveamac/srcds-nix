# srcds-nix

> [!WARNING]
> WORK IN PROGRESS - Probably not functional, definitely not stable

Manage and run Source Dedicated Server games on NixOS.

# Games

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
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games



Game servers to run\. Each attribute name will store server files in a different directory, allowing for multiple servers of the same game\.



*Type:*
attribute set of (submodule)

*Declared by:*
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.allowUnknownId



Allow an unknown AppID\. The option ` gameFolder ` must be set if this is used\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.appId



Steam AppID for the game’s dedicated server\.



*Type:*
signed integer

*Declared by:*
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.extraConVarArgs



Additional ConVar arguments (the ones that start with ` + `) to pass to ` srcds_run `\.



*Type:*
attribute set of string



*Default:*
` { } `

*Declared by:*
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



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
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.gamePort



Game port to open\. This is normally 27015, but is deliberately left without a default value to avoid conflicts with multiple servers\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)

*Declared by:*
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



## services\.srcds\.games\.\<name>\.startingMap



Starting map\.



*Type:*
null or string



*Default:*
` null `



*Example:*
` "pl_upward" `

*Declared by:*
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



## services\.srcds\.openGameFirewall



Open game firewall ports for all defined servers\. This can be overridden per-server by setting each one’s ` openGameFirewall ` option\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds](file:///home/ihaveahax/Documents/Projects/srcds-nix/modules/srcds)



