#include <a_samp>

    // Amount of kills required per level-up
#define KILLS_PER_LEVEL 3

#define BODYPART_HEAD 9
    // x - y - z - rotation angle
new Float:RandPos[9][4] = {
	{-1291.6622,2513.7566,87.0500,355.3697},
	{-1303.8662,2527.4270,87.5878,358.6714},
	{-1308.1099,2544.3853,87.7422,171.4412},
	{-1321.0725,2526.1138,87.4379,183.3481},
	{-1335.7893,2520.8984,87.0469,270.7455},
	{-1298.5408,2547.2991,87.6747,356.4313},
	{-1291.3345,2533.8853,87.7422,92.7705},
	{-1288.5410,2528.5769,87.6331,183.0114},
	{-1316.3402,2499.9949,87.0420,271.8305}
};

// new Weaps[14] = {
// 	23,
// 	22,
// 	27,
// 	26,
// 	29,
// 	32,
// 	30,
// 	31,
// 	38,
// 	33,
// 	34,
// 	35,
// 	36,
// 	24
// };


new Weaps[] = {
    WEAPON_COLT45,
    WEAPON_SILENCED,
    WEAPON_TEC9,
    WEAPON_UZI,
    WEAPON_MP5,
    WEAPON_GRENADE,
    WEAPON_SHOTGUN,
    WEAPON_SHOTGSPA,
    WEAPON_SAWEDOFF,
    WEAPON_RIFLE,
    WEAPON_AK47,
    WEAPON_M4,
    WEAPON_SNIPER,
    WEAPON_DEAGLE
};

enum status {
	level,
    kills_at_level,
	bool:dead,
	bool:pw, //Primary weapon
};
new PlayerStatus[MAX_PLAYERS][status];
new Text:Respawn;
new bool:GameInProgress;

main()
{
	print("\n----------------------------------");
	print(" ggame is a gun game mode.");
	print(" Author: anesthesia");
	print("----------------------------------\n");
}

EndRound() {
    SendClientMessageToAll(0x008000FF, "The game has ended!");
    SendClientMessageToAll(0x008000FF, "A new round will start in 8 seconds.");
	GameInProgress = false;
		// Print the top three best players.
    new Highest[3] = {INVALID_PLAYER_ID, ...};
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        TogglePlayerSpectating(i, 1);
        SetPlayerCameraPos(i, -1251.1089, 2551.7546, 104.6863);
        SetPlayerCameraLookAt(i, -1302.1554, 2533.4226, 93.8427);
			// Find the player with the highest score.
        if(GetPlayerScore(i) > GetPlayerScore(Highest[0]))
        {
            Highest[2] = Highest[1];
            Highest[1] = Highest[0];
            Highest[0] = i;
        }
            else if(GetPlayerScore(i) > GetPlayerScore(Highest[1]))
        {
            Highest[2] = Highest[1];
            Highest[1] = i;
        }
            else if(GetPlayerScore(i) > GetPlayerScore(Highest[1]))
        {
            Highest[2] = i;
        }
    }
    
    new string[144], Name[3][MAX_PLAYER_NAME + 1];
    GetPlayerName(Highest[0], Name[0], MAX_PLAYER_NAME);
    GetPlayerName(Highest[1], Name[1], MAX_PLAYER_NAME);
    GetPlayerName(Highest[2], Name[2], MAX_PLAYER_NAME);
    format(string, sizeof string, "~r~The match ended!~n~~g~1. %02i - %s~n~~y~2. %02i - %s~n~~r~~h~3. %02i - %s", 
        GetPlayerScore(Highest[0]), Name[0], GetPlayerScore(Highest[1]), Name[1], GetPlayerScore(Highest[2]), Name[2]);
    GameTextForAll(string, 7500, 1);
    SetTimer("Restart", 8000, 0);
}

ShowKillsTillNextLevel(playerid) {
    new str[128];
    format(str, sizeof str, "~r~%i~y~ kills till level up!", KILLS_PER_LEVEL - PlayerStatus[playerid][kills_at_level]);
    GameTextForPlayer(playerid, str, 700, 4);
}

public OnGameModeInit()
{
	SetGameModeText("Gun Game");
	AddPlayerClass(0, -1291.6622, 2513.7566, 87.0500, 355.3697, 0, 0, 0, 0, 0, 0);
	ShowPlayerMarkers(0);
	
	Respawn = TextDrawCreate(320.000000, 155.000000, "~y~Press '~r~~k~~VEHICLE_ENTER_EXIT~~y~' to spawn!");
	TextDrawAlignment(Respawn, 2);
	TextDrawBackgroundColor(Respawn, 255);
	TextDrawFont(Respawn, 2);
	TextDrawLetterSize(Respawn, 0.549999, 1.500000);
	TextDrawColor(Respawn, -65281);
	TextDrawSetOutline(Respawn, 0);
	TextDrawSetProportional(Respawn, 1);
	TextDrawSetShadow(Respawn, 3);
	GameInProgress = true;
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraPos(playerid, -1251.1089, 2551.7546, 104.6863);
    SetPlayerCameraLookAt(playerid, -1302.1554, 2533.4226, 93.8427);
	return 1;
}

public OnPlayerConnect(playerid)
{
	PlayerStatus[playerid][level] = 0;
    PlayerStatus[playerid][kills_at_level] = 0;
	PlayerStatus[playerid][dead] = true;
	PlayerStatus[playerid][pw] = true;
	TextDrawHideForPlayer(playerid, Respawn);
	SetPlayerColor(playerid, 0xFF0000FF);
	return 1;
}

public OnPlayerSpawn(playerid)
{
		// Position
	new rand = random(9);
	SetPlayerPos(playerid, RandPos[rand][0], RandPos[rand][1], RandPos[rand][2]);
	SetPlayerFacingAngle(playerid, RandPos[rand][3]);
	SetPlayerWorldBounds(playerid, -1274.2817, -1358.5095, 2575.6509, 2472.3486);
	SetCameraBehindPlayer(playerid);
	
	    // Weapons
	GivePlayerWeapon(playerid, WEAPON_KNIFE, 1);
	GivePlayerWeapon(playerid, Weaps[PlayerStatus[playerid][level]], 65535);
	
	    // General stuff
	PlayerStatus[playerid][dead] = false;
	PlayerStatus[playerid][pw] = true;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SendDeathMessage(killerid, playerid, reason);
	TogglePlayerSpectating(playerid, 1);
	TextDrawShowForPlayer(playerid, Respawn);
	PlayerStatus[playerid][dead] = true;
	if(killerid == INVALID_PLAYER_ID)
	{
	    SetPlayerCameraPos(playerid, -1251.1089, 2551.7546, 104.6863);
	    SetPlayerCameraLookAt(playerid, -1302.1554, 2533.4226, 93.8427);
	}
		else
	{
		PlayerSpectatePlayer(playerid, killerid);
	
		if(reason == WEAPON_KNIFE) // Knife deaths are humiliation and demote the player.
		{
		    GameTextForPlayer(killerid, "~r~Humiliation!~n~~y~You demoted someone!", 1650, 6);
			GameTextForPlayer(playerid, "~r~Humiliated~n~~y~You got demoted!", 1650, 6);
			if(PlayerStatus[playerid][level] != 0) PlayerStatus[playerid][level]--;
            PlayerStatus[playerid][kills_at_level] = 0;

		}
        GameTextForPlayer(killerid, "~r~Player Killed!~n~~y~Advanced to the next tier!", 1650, 6);
        PlayerStatus[killerid][kills_at_level]++;
        if(PlayerStatus[killerid][kills_at_level] == KILLS_PER_LEVEL) {
            PlayerStatus[killerid][kills_at_level] = 0;
            PlayerStatus[killerid][level]++;
            if(PlayerStatus[killerid][level] == sizeof Weaps) EndRound(); //Player has won the game.
            else {
                SetPlayerScore(killerid, PlayerStatus[killerid][level] + 1);
                ResetPlayerWeapons(killerid);
                GivePlayerWeapon(killerid, WEAPON_KNIFE, 1);
                GivePlayerWeapon(killerid, Weaps[PlayerStatus[killerid][level]], 65535);
            }
        }
        ShowKillsTillNextLevel(killerid);
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {
    new Float:health;
    new Float:multiplier = 2.0;
    if(bodypart == BODYPART_HEAD) multiplier = 3.0; // Make headshots do 50% more damage over the regular multiplier
    GetPlayerHealth(playerid, health);
    SetPlayerHealth(playerid, health - amount * multiplier);
}

public OnPlayerUpdate(playerid)
{
	if(PlayerStatus[playerid][dead] == false)
	{		
			// We want to avoid the player switching to his hands as a weapon
            // A player should only be able to use his knife and the weapon given to him.
		if(!GetPlayerWeapon(playerid))
		{
			if(PlayerStatus[playerid][pw] == true)
			{
				SetPlayerArmedWeapon(playerid, 4);
				PlayerStatus[playerid][pw] = false;
			}
				else
			{
			    SetPlayerArmedWeapon(playerid, Weaps[PlayerStatus[playerid][level]]);
				PlayerStatus[playerid][pw] = true;
			}
		}
		else PlayerStatus[playerid][pw] = GetPlayerWeapon(playerid) == 4 ? false : true;
		
	}
 	else
	{
	    SetPlayerCameraPos(playerid, -1251.1089, 2551.7546, 104.6863);
	    SetPlayerCameraLookAt(playerid, -1302.1554, 2533.4226, 93.8427);
	    new Keys[3];
	    GetPlayerKeys(playerid, Keys[0], Keys[1], Keys[2]);
	    if(Keys[0] & KEY_SECONDARY_ATTACK && GameInProgress == true)
	    {
	        TogglePlayerSpectating(playerid, 0);
	        SpawnPlayer(playerid);
	        TextDrawHideForPlayer(playerid, Respawn);
			PlayerStatus[playerid][dead] = false;
		}
	}
	return 1;
}

forward Restart();
public Restart()
{
	SendRconCommand("gmx");
}