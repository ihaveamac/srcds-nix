rec {
  gameIds = {
    "740" = {
      game = "Counter-Strike: Global Offensive";
      folder = "csgo";
      windowsWorkaround = false;
      sourceTV = true;
    };
    "232330" = {
      game = "Counter-Strike: Source";
      folder = "cstrike";
      windowsWorkaround = false;
      sourceTV = true;
    };
    "232290" = {
      game = "Day of Defeat: Source";
      folder = "dod";
      windowsWorkaround = false;
      sourceTV = true;
    };
    "4020" = {
      game = "Garry's Mod";
      folder = "garrysmod";
      windowsWorkaround = false;
      sourceTV = true;
    };
    "232370" = {
      game = "Half-Life 2: Deathmatch";
      folder = "hl2mp";
      windowsWorkaround = false;
      sourceTV = false;
    };
    "255470" = {
      game = "Half-Life Deathmatch: Source";
      folder = "hl1mp";
      windowsWorkaround = true;
      sourceTV = false;
    };
    "222860" = {
      game = "Left 4 Dead 2";
      folder = "left4dead2";
      windowsWorkaround = true;
      sourceTV = false;
    };
    "222840" = {
      game = "Left 4 Dead";
      folder = "left4dead";
      windowsWorkaround = false;
      sourceTV = false;
    };
    "232250" = {
      game = "Team Fortress 2";
      folder = "tf";
      windowsWorkaround = false;
      sourceTV = true;
    };
    "346680" = {
      game = "Black Mesa";
      folder = "bms";
      windowsWorkaround = false;
      sourceTV = true;
    };
    "244310" = {
      game = "Source SDK Base 2013";
      folder = null;
      windowsWorkaround = false;
      sourceTV = true;
    };
  };
  blockedGameIds = {
    "635" =
      "There is no Linux version of Alien Swarm Dedicated Server. It also cannot be downloaded with the anonymous account.";
    "582400" = "There is no Linux version of Alien Swarm: Reactive Drop Dedicated Server.";
  };
  get = id: if gameIds ? ${toString id} then gameIds.${toString id} else null;
  checkAssertion =
    name: info:
    let
      sAppId = toString info.appId;
    in
    if (blockedGameIds ? ${sAppId}) then
      blockedGameIds.${sAppId}
    else if !(gameIds ? ${sAppId}) then
      if !info.allowUnknownId then
        "Unrecognized App ID ${sAppId} for `services.srcds.games.${name}`. Possible solutions:\n - Did you use the game client ID instead of the dedicated server? For example, Team Fortress 2 Dedicated server is 232250 (the one you want to use), while the client AppID is 440.\n - Is this a typo, or a game server this module is not aware of? If if's really a version of Source Dedicated Server that is unknown to this module, set `services.srcds.games.${name}.allowUnknownId = true`."
      else
        null
    else if info.appId == 244310 && info.gameFolder == "AUTOMATIC" then
      "Source SDK Base 2013 Dedicated Server is being used for services.srcds.games.${name}, but gameFolder is not set. You need to set it to the Source mod to load.\n(Hint: What folder did you add to the server folder, next to \"sourcetest\"?)"
    else if info.sourceTV.enable && !gameIds.${sAppId}.sourceTV then
      "Sorry, ${gameIds.${sAppId}.game} does not support SourceTV. Please disable services.srcds.games.${name}.sourceTV.enable."
    else
      null;
  checkWarning =
    name: info:
    let
      sAppId = toString info.appId;
    in
    if info.allowUnknownId && gameIds ? ${sAppId} then
      "services.srcds.games.${name}.allowUnknownId is true, but AppID ${sAppId} is known to this module as \"${gameIds.${sAppId}.game}\". Maybe this game was unknown when the module was used, but it is now. This setting can safely be removed."
    else
      null;
}
