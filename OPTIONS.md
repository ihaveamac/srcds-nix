## services\.srcds\.enable

Whether to enable the Source Dedicated Server module\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games



Game servers to run\. Each attribute name will store server files in a different directory, allowing for multiple servers of the same game\.



*Type:*
attribute set of (submodule)

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.allowUnknownId



Allow an unknown AppID\. The option ` gameFolder ` must be set if this is used\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.appId



Steam AppID for the game’s dedicated server\.



*Type:*
signed integer

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.autoUpdate



Automatically check for and install updates\. This should be disabled if using mods that patch game files\. The initial installation will still be performed regardless of this setting\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.branch



Beta branch to download and update the server from\.



*Type:*
string



*Default:*
` "public" `



*Example:*
` "prerelease" `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



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
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.extraServerConfig



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
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



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
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.gamePort



Game port to open\. This is normally 27015, but is deliberately left without a default value to avoid conflicts with multiple servers\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.insecure



Disable Valve Anti-Cheat\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.log\.enable



Enable logging\. Sets ` +log on `\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.log\.compressOnExit



Compress log files on exit\. Sets ` +sv_logfilecompress 1 `\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.log\.logToFile



Log to a file in the ` <gameFolder>/logs ` folder\. Sets ` +sv_logfile 1 `\.



*Type:*
boolean



*Default:*
` true `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.openFirewall



Whether to open firewall ports for this server\.



*Type:*
boolean



*Default:*
` config.services.srcds.openFirewall `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.rcon\.enable



Enable RCON\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.rcon\.password



Password to use for RCON\.

If you would rather not expose it in your NixOS configuration, put it in a ` server_local.cfg ` file in ` <gameFolder>/cfg `\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.serverConfig



Configuration to put in ` <gamedir>/cfg/server.cfg `\. If this file already exists and is not managed by NixOS, it will be renamed to avoid overwriting\. To store local configuration not managed by NixOS, put commands in ` <gamedir>/cfg/server_local.cfg `\.



*Type:*
attribute set of (string or signed integer or floating point number)



*Default:*

```
{
  hostname = "My NixOS TF2 server";
  sv_contact = "you@example.com";
  sv_pure = 0;
}
```

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.sourceTV\.enable



Enable SourceTV\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.sourceTV\.port



SourceTV port to open\. This is usually 27020 (game port + 5), but is deliberately left without a default value to avoid conflicts with multiple servers\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.games\.\<name>\.startingMap



Starting map\.



*Type:*
null or string



*Default:*
` null `



*Example:*
` "pl_upward" `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)



## services\.srcds\.openFirewall



Whether to open firewall ports for all defined servers\. This can be overridden per-server by setting each one’s ` openFirewall ` option\.



*Type:*
boolean



*Default:*
` config.programs.steam.dedicatedServer.openFirewall `

*Declared by:*
 - [modules/srcds/default\.nix](https://github.com/ihaveamac/srcds-nix/blob/main/modules/srcds/default.nix)


