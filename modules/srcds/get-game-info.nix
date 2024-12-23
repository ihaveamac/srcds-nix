rec {
  gameIds = {
    "740" = { game = "Counter-Strike: Global Offensive"; folder = "csgo"; };
    "232330" = { game = "Counter-Strike: Source"; folder = "cstrike"; };
    "232290" = { game = "Day of Defeat: Source"; folder = "dod"; };
    "4020" = { game = "Garry's Mod"; folder = "garrysmod"; };
    "232370" = { game = "Half-Life 2: Deathmatch"; folder = "hl2mp"; };
    "255470" = { game = "Half-Life Deathmatch: Source"; folder = "hl1mp"; };
    "222860" = { game = "Left 4 Dead 2"; folder = "left4dead2"; };
    "222840" = { game = "Left 4 Dead"; folder = "left4dead"; };
    "232250" = { game = "Team Fortress 2"; folder = "tf"; };
    "244310" = { game = "Source SDK Base 2013"; folder = null; };
  };
  get = id: if gameIds ? ${toString id} then gameIds.${toString id} else null;
  checkAssertion = name: info:
    let sAppId = toString info.appId; in
    if !(gameIds ? ${sAppId}) then
      if !info.allowUnknownId then
        "Unrecognized App ID ${sAppId} for `services.srcds.games.${name}`. Possible solutions:\n - Did you use the game client ID instead of the dedicated server? For example, Team Fortress 2 Dedicated server is 232250 (the one you want to use), while the client AppID is 440.\n - Is this a typo, or a game server this module is not aware of? If if's really a version of Source Dedicated Server that is unknown to this module, set `services.srcds.games.${name}.allowUnknownId = true`."
      else null
    else if info.appId == 255470 then
      "Sorry, Half-Life Deathmatch: Source Dedicated server cannot be downloaded through an anonymous account with steamcmd for some reason. Blame Valve."
    else if info.appId == 244310 && info.gameFolder == "AUTOMATIC" then
      "Source SDK Base 2013 Dedicated Server is being used for services.srcds.games.${name}, but gameFolder is not set. You need to set it to the Source mod to load.\n(Hint: What folder did you add to the server folder, next to \"sourcetest\"?)"
    else null;
  checkWarning = name: info:
    let sAppId = toString info.appId; in
    if info.allowUnknownId && gameIds ? ${sAppId} then
      "services.srcds.games.${name}.allowUnknownId is true, but AppID ${sAppId} is known to this module as \"${gameIds.${sAppId}.game}\". Maybe this game was unknown when the module was used, but it is now. This setting can safely be removed."
    else null;
}
