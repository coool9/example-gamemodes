// ------------------------------------------------------------------------------------------------------------
//
// Kingdom - TDM Gamemode - by CaioTJF (2019)
// open.mp Team
//
// ------------------------------------------------------------------------------------------------------------

#include <a_samp>

// ------------------------------------------------------------------------------------------------------------

#define	COLOR_WHITE 							(0xFFFFFFFF)
#define COLOR_ORANGE 							(0xFFA500FF)
#define COLOR_LIGHTBLUE 						(0xADD8E6FF)
#define COLOR_YELLOW 							(0xFFFF00FF)

#define COLOR_ERROR                             (0xD3D3D3FF)

#define COLOR_TEAM_GROVE 						(0x33AA33FF)
#define COLOR_TEAM_LSVAGOS 						(0xB8860BFF)
#define COLOR_TEAM_BALLAS                       (0x800080FF)
#define COLOR_TEAM_AZTECAS                      (0x3380ccFF)
#define COLOR_TEAM_POLICE                       (0x6666ffFF)

// ------------------------------------------------------------------------------------------------------------

#define MAX_TEAM_SKINS 							(6)
#define STARTING_MONEY                          (20000)
#define MONEY_PER_KILL                          (5000)
#define VEHICLE_RESPAWN_TIME                    (60) // In seconds

#define GANGZONE_ATTACK_TIME 					(1000 * 60 * 5)
#define GANGZONE_MEMBERS_NEEDED_TO_ATTACK 		(1) // Minimum

// ------------------------------------------------------------------------------------------------------------

#define DIALOG_MESSAGE                          (1)
#define DIALOG_GUNSTORE                         (2)

// ------------------------------------------------------------------------------------------------------------

enum E_TEAM_DATA
{
    E_TEAM_DATA_NAME[64],
    E_TEAM_DATA_SKINS[MAX_TEAM_SKINS],
    E_TEAM_DATA_COLOR,
	Float:E_TEAM_DATA_RESPAWN[4],
	Float:E_TEAM_DATA_SKIN_POS[4],
	// Not need be defined
	E_TEAM_DATA_CLASSID[MAX_TEAM_SKINS]
}

enum E_GANGZONE_DATA
{
    Float:E_GANGZONE_DATA_POS[4],
    E_GANGZONE_DATA_NAME[64],
    // Not need be defined
    E_GANGZONE_DATA_ZONEID,
    E_GANGZONE_DATA_OWNERID,
    bool:E_GANGZONE_DATA_INWAR,
	E_GANGZONE_DATA_ATTACKERID
}

enum E_GUNSTORE_DATA
{
	E_GUNSTORE_DATA_WEAPONID,
	E_GUNSTORE_DATA_PRICE,
	E_GUNSTORE_DATA_AMMO
}

static
	gTeamData[][E_TEAM_DATA] =
	{                                                                                                   																																																	/*
		Name					Skins								Color					Respawn											Skin Position (For Class Selection)		                                                    																				*/
		{"Grove Street",		{105, 106, 107},					COLOR_TEAM_GROVE,		{2515.2280, -1681.4805, 13.4170, 48.0854}, 		{2463.7131, -1667.0674, 13.4771, 86.2142}},
		{"Los Santos Vagos",	{108, 109, 110},					COLOR_TEAM_LSVAGOS,		{2803.1096, -1183.1365, 25.5073, 264.5774}, 	{2855.9277, -1191.7800, 24.5803, 260.3824}},
		{"Ballas",				{102, 103, 104},					COLOR_TEAM_BALLAS,		{1084.1046, -1211.8845, 17.8120, 276.5225}, 	{1114.4854, -1209.9791, 17.7987, 316.0495}},
		{"Los Aztecas",			{114, 115, 116},					COLOR_TEAM_AZTECAS,		{315.8699, -1772.3295, 4.6857, 187.4871}, 		{336.2047, -1819.4639, 4.2275, 194.6938}},
        {"Police",				{280, 281, 284, 306, 265, 266},		COLOR_TEAM_POLICE,		{1574.2010, -1634.2572, 13.5559, 0.6023}, 		{1519.3356, -1603.8440, 13.5469, 43.6743}}
	},
	gGangZoneData[][E_GANGZONE_DATA] =
	{																																																																										/*
	    MinX     				MinY        			MaxX        			MaxY    				Name                                                                                                                                                                                                                                                */
	    {{1859.0, 				-1263.0, 				2069.0, 				-1135.0}, 				"Park Gleen"},
	    {{1155.0, 				-2085.0, 				1293.0, 				-1988.0}, 				"Mansion"},
	    {{1687.9690551757812, 	-1949.9933471679688, 	1811.9690551757812,  	-1869.9933471679688}, 	"Station"},
	    {{2444.9447021484375, 	-2468.2816467285156, 	2554.9447021484375,  	-2358.2816467285156}, 	"Port"}
	},
	gGunStoreData[][E_GUNSTORE_DATA] =
	{                                                                                                                                                                                                                                                                                                       /*
		WeaponID	Price		Ammo                     																																																											*/
		{16, 		2000,		10}, 	// Granade
		{18, 		2000,		10}, 	// Molotov
		{22,        500,		100}, 	// 9mm
		{23,        500,		100}, 	// Silecend 9mm
		{24,        3000,		100}, 	// Deagle
		{25,        3000,		50}, 	// Shotgun,
		{26,        5000,		100}, 	// Sawnoff Shotgun
		{27,       	5000,		100}, 	// Combat Shotgun
		{28,       	5000,		300}, 	// Micro SMG/Uzi
		{29,        5000,		300}, 	// MP5
		{30,        7000,		250}, 	// AK-47
		{31,        7000,		250}, 	// M4
		{32,        5000,		300}, 	// Tec-9
		{33,        3000,		30}, 	// Country Rifle
		{34,        9000,		50} 	// Sniper Rifle
	};

static
	gString[256],

	Text:TD_SelectTeam,
	PlayerText:PTD_TeamName[MAX_PLAYERS],

	gPlayerCurrentGZ[MAX_PLAYERS] = {-1, ...},
	gPlayerTimer[MAX_PLAYERS] = {-1, ...},
	gPlayerTeam[MAX_PLAYERS],
	gPlayerName[MAX_PLAYERS][MAX_PLAYER_NAME + 1];

// ------------------------------------------------------------------------------------------------------------

forward OnPlayerUpdateEx(playerid); // One second timer
forward OnPlayerEnterGangZone(playerid, zoneid);
forward FinishGangZoneWar(zoneid);

// ------------------------------------------------------------------------------------------------------------

main()
{
	print("--------------------------------------------");
	print("---------- Kingdom TDM by CaioTJF ----------");
	print("--------------- open.mp Team ---------------");
	print("--------------------------------------------");
	print(" ");
}

// ------------------------------------------------------------------------------------------------------------

public OnGameModeInit()
{
	SetGameModeText("Kingdom");
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	
	// ------------------------------------------------------------------------------------------------------------
	
	for (new teamid; teamid < sizeof(gTeamData); teamid++)
	{
	    for (new i; i < MAX_TEAM_SKINS; i++)
	    {
	        if (gTeamData[teamid][E_TEAM_DATA_SKINS][i] == 0)
			{
			    gTeamData[teamid][E_TEAM_DATA_CLASSID][i] = -1;
				continue;
			}
			
 			gTeamData[teamid][E_TEAM_DATA_CLASSID][i] = AddPlayerClassEx(teamid, gTeamData[teamid][E_TEAM_DATA_SKINS][i], gTeamData[teamid][E_TEAM_DATA_RESPAWN][0], gTeamData[teamid][E_TEAM_DATA_RESPAWN][1], gTeamData[teamid][E_TEAM_DATA_RESPAWN][2], gTeamData[teamid][E_TEAM_DATA_RESPAWN][3], 0, 0, 0, 0, 0, 0);
		}
	}
	
	// ------------------------------------------------------------------------------------------------------------
	
	for (new zoneid; zoneid < sizeof(gGangZoneData); zoneid++)
	{
	    gGangZoneData[zoneid][E_GANGZONE_DATA_ZONEID] = GangZoneCreate(gGangZoneData[zoneid][E_GANGZONE_DATA_POS][0], gGangZoneData[zoneid][E_GANGZONE_DATA_POS][1], gGangZoneData[zoneid][E_GANGZONE_DATA_POS][2], gGangZoneData[zoneid][E_GANGZONE_DATA_POS][3]);
		gGangZoneData[zoneid][E_GANGZONE_DATA_OWNERID] = -1;
		gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID] = -1;
	}
	
	// ------------------------------------------------------------------------------------------------------------
	
	AddStaticVehicleEx(480,2470.1204,-1669.9761,13.4069,192.4426,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(536,2476.4575,-1679.8903,13.4293,235.2687,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(560,2489.7241,-1682.6383,13.4285,270.5974,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(559,2508.0806,-1671.2938,13.4715,346.8494,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(411,2498.1665,-1655.9650,13.4828,79.2710,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(424,2479.1880,-1655.1149,13.4112,89.3957,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(560,2464.1628,-1655.0410,13.3964,89.5012,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(521,2457.9844,-1669.6687,13.0751,358.0117,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(521,2455.5549,-1669.5909,13.0744,358.4251,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(521,2453.0496,-1669.5446,13.0750,356.1776,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	AddStaticVehicleEx(521,2450.5151,-1669.4875,13.0747,356.5550,86,86,VEHICLE_RESPAWN_TIME); // Grove Street
	
	AddStaticVehicleEx(480,2828.4094,-1197.4763,24.9042,1.0749,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(536,2829.8730,-1170.2423,25.0640,269.1320,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(560,2829.8369,-1165.0836,25.0730,272.6667,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(559,2834.9453,-1149.3245,24.8752,182.1950,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(411,2842.7266,-1224.3308,23.1214,7.0893,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(424,2840.7993,-1211.8372,23.6898,7.6515,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(560,2838.5779,-1195.8250,24.4129,7.5936,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(521,2823.8469,-1187.7213,24.7818,357.1795,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(521,2821.6116,-1187.7472,24.7975,355.7195,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(521,2819.2043,-1187.5837,24.8082,357.4650,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos
	AddStaticVehicleEx(521,2816.9001,-1187.6846,24.8204,357.0965,6,6,VEHICLE_RESPAWN_TIME); // Los Vagos

	AddStaticVehicleEx(480,1089.7250,-1218.5763,17.9007,180.0250,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(536,1093.8928,-1218.4945,17.8970,180.6232,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(560,1098.1289,-1218.4507,17.8970,179.8605,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(559,1102.3893,-1218.4579,17.8970,180.2194,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(411,1106.7385,-1218.4133,17.8971,179.9522,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(424,1087.9153,-1193.8549,18.2251,179.8887,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(560,1111.0127,-1226.2096,15.9144,359.7874,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(521,1114.0278,-1191.5243,17.7175,186.5465,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(521,1111.6527,-1191.6737,17.7283,179.3140,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(521,1109.3523,-1191.7332,17.7553,180.5423,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	AddStaticVehicleEx(521,1106.9326,-1191.7196,17.7763,176.5248,211,211,VEHICLE_RESPAWN_TIME); // Ballas
	
	AddStaticVehicleEx(480,311.5325,-1809.5338,4.5570,180.6798,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(536,317.9842,-1809.4557,4.5678,181.0660,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(560,321.1478,-1809.3885,4.5706,179.5743,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(559,321.4612,-1788.7019,4.8244,0.2898,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(411,331.2597,-1788.5397,4.9766,0.0026,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(424,337.6725,-1788.6711,5.0200,359.4413,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(560,334.1064,-1809.3040,4.5824,180.6222,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(521,311.8359,-1788.3594,4.1580,359.0935,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(521,327.7237,-1809.5890,4.0598,179.9502,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(521,324.6534,-1788.4703,4.3715,359.6192,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	AddStaticVehicleEx(521,343.8807,-1809.8601,4.0854,178.9172,162,162,VEHICLE_RESPAWN_TIME); // Aztecas
	
	AddStaticVehicleEx(427,1604.3518,-1606.6647,13.6039,358.5899,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(427,1600.1307,-1606.6971,13.5568,359.7650,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(596,1590.0594,-1606.6263,13.4752,358.7953,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(596,1586.2788,-1606.7006,13.4752,359.4074,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(596,1582.7948,-1606.7186,13.4752,0.6130,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(596,1573.3386,-1606.7429,13.4752,359.2841,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(596,1564.8365,-1606.7915,13.4752,358.3239,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(523,1566.8750,-1634.6659,13.1408,1.8933,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(523,1563.7185,-1634.5760,13.1387,1.2125,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(523,1560.6783,-1634.6315,13.1402,357.8896,0,1,VEHICLE_RESPAWN_TIME); // Police
	AddStaticVehicleEx(523,1552.9863,-1634.6147,13.1375,358.8776,0,1,VEHICLE_RESPAWN_TIME); // Police

    // ------------------------------------------------------------------------------------------------------------

	TD_SelectTeam = TextDrawCreate(318.687194, 100.499984, "Choose your team!");
	TextDrawLetterSize(TD_SelectTeam, 0.579910, 2.498333);
	TextDrawTextSize(TD_SelectTeam, 0.000000, 496.000000);
	TextDrawAlignment(TD_SelectTeam, 2);
	TextDrawColor(TD_SelectTeam, 0xf4f4f4FF);
	TextDrawSetOutline(TD_SelectTeam, 1);
	TextDrawBackgroundColor(TD_SelectTeam, 32);
	TextDrawFont(TD_SelectTeam, 1);
	TextDrawSetProportional(TD_SelectTeam, 1);

	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
	// Looping all teams
    for (new teamid; teamid < sizeof(gTeamData); teamid++)
    {
        // Looping all teams skins
        for (new i; i < MAX_TEAM_SKINS; i++)
	    {
	        // Find the classid within the array
	        if (classid == gTeamData[teamid][E_TEAM_DATA_CLASSID][i])
	        {
	        	SetPlayerPos(playerid, gTeamData[teamid][E_TEAM_DATA_SKIN_POS][0], gTeamData[teamid][E_TEAM_DATA_SKIN_POS][1], gTeamData[teamid][E_TEAM_DATA_SKIN_POS][2]);
				SetPlayerFacingAngle(playerid, gTeamData[teamid][E_TEAM_DATA_SKIN_POS][3]);

	        	static
	        	    Float:x, Float:y, Float:a;
	        	    
	        	x = gTeamData[teamid][E_TEAM_DATA_SKIN_POS][0];
	        	y = gTeamData[teamid][E_TEAM_DATA_SKIN_POS][1];
	        	a = gTeamData[teamid][E_TEAM_DATA_SKIN_POS][3];

				// Get XY from the front of the player (Credits for Y_Less)
			    x += (4.0 * floatsin(-a, degrees));
			    y += (4.0 * floatcos(-a, degrees));

				// Set the camera in front of the skin
			    SetPlayerCameraPos(playerid, x, y, gTeamData[teamid][E_TEAM_DATA_SKIN_POS][2]);
				SetPlayerCameraLookAt(playerid, gTeamData[teamid][E_TEAM_DATA_SKIN_POS][0], gTeamData[teamid][E_TEAM_DATA_SKIN_POS][1], gTeamData[teamid][E_TEAM_DATA_SKIN_POS][2] + 0.2);

				// Saving the teamid in a variable
	        	gPlayerTeam[playerid] = teamid;
	        	
	        	// Set the team color on the player
	        	SetPlayerColor(playerid, gTeamData[teamid][E_TEAM_DATA_COLOR]);
	        	
	        	// Set the team name in Textdraw
	            format(gString, sizeof gString, "%s", gTeamData[teamid][E_TEAM_DATA_NAME]);
	            PlayerTextDrawSetString(playerid, PTD_TeamName[playerid], gString);
	            
	            // Set the team color in TextDraw
	            PlayerTextDrawColor(playerid, PTD_TeamName[playerid], ((gTeamData[teamid][E_TEAM_DATA_COLOR] & ~0xAA) | 0xFF));

				// Show TextDraw's
            	TextDrawShowForPlayer(playerid, TD_SelectTeam);
	            PlayerTextDrawShow(playerid, PTD_TeamName[playerid]);
	            break;
	        }
	    }
    }

	return true;
}

public OnPlayerRequestSpawn(playerid)
{
    TextDrawHideForPlayer(playerid, TD_SelectTeam);
    PlayerTextDrawHide(playerid, PTD_TeamName[playerid]);
    return true;
}

public OnPlayerSpawn(playerid)
{
	// Looping all GangZones
	for (new zoneid; zoneid < sizeof(gGangZoneData); zoneid++)
	{
		// Show GangZone to the player
	    GangZoneShowForPlayer(playerid, gGangZoneData[zoneid][E_GANGZONE_DATA_ZONEID], GangZone_GetOwnerColor(zoneid));
	    
	    // Checking if the GangZone is being attacked
	    if (gGangZoneData[zoneid][E_GANGZONE_DATA_INWAR])
	    {
			static
			    attackerid;

			attackerid = gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID];
			
	        GangZoneFlashForPlayer(playerid, gGangZoneData[zoneid][E_GANGZONE_DATA_ZONEID], ((gTeamData[attackerid][E_TEAM_DATA_COLOR] & ~0xFF) | 0xAA));
			// Now the player knows that GangZone is over-attacking
	    }
	}
	
	Player_GiveSpawnWeapons(playerid);
	
	SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] To buy weapons, press the Y key.");

	return true;
}

public OnPlayerConnect(playerid)
{
    gPlayerTimer[playerid] = SetTimerEx("OnPlayerUpdateEx", 1000, true, "i", playerid); // Create a player timer

    gPlayerCurrentGZ[playerid] = -1; // Set the current GZ to -1 (-1 = none, avoiding bugs)
    
    GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME + 1); // Save the player name
    
    SetPlayerColor(playerid, COLOR_WHITE); // Set no-team color
    
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 200); // Notifies player connection

	GivePlayerMoney(playerid, STARTING_MONEY); // Gives the starting money
	
    PTD_TeamName[playerid] = CreatePlayerTextDraw(playerid, 316.626281, 367.315704, "TeamName");
	PlayerTextDrawLetterSize(playerid, PTD_TeamName[playerid], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, PTD_TeamName[playerid], 2);
	PlayerTextDrawSetShadow(playerid, PTD_TeamName[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, PTD_TeamName[playerid], 64);
	PlayerTextDrawFont(playerid, PTD_TeamName[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PTD_TeamName[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PTD_TeamName[playerid], 1);
	
	return true;
}

public OnPlayerDisconnect(playerid)
{
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201); // Notifies player disconnection
    
    // Kill the player timer
    if (gPlayerTimer[playerid] != -1)
    {
        KillTimer(gPlayerTimer[playerid]);
        gPlayerTimer[playerid] = -1;
    }
    
    return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    SendDeathMessage(killerid, playerid, reason);
    
	if (killerid != INVALID_PLAYER_ID)
	{
		GivePlayerMoney(killerid, MONEY_PER_KILL);
		GivePlayerMoney(playerid, - (MONEY_PER_KILL / 2));

		SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
	}
	else
	{
	    // Probable Suicide
	}
	
	return true;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (newkeys & KEY_YES)
	{
		static
			dialog[512],
			gunName[32];

		dialog = "Weapon\tPrice\tAmmo\n";
		gString[0] = EOS;
		
		for (new i; i < sizeof(gGunStoreData); i++)
		{
  			GetWeaponName(gGunStoreData[i][E_GUNSTORE_DATA_WEAPONID], gunName, sizeof(gunName));
  			
			format(gString, sizeof gString, "%s\t$%d\t%d\n",
				gunName,
				gGunStoreData[i][E_GUNSTORE_DATA_PRICE],
				gGunStoreData[i][E_GUNSTORE_DATA_AMMO]
			);
			
			strcat(dialog, gString);
		}
		
	    ShowPlayerDialog(playerid, DIALOG_GUNSTORE, DIALOG_STYLE_TABLIST_HEADERS, "Gun Store", dialog, "Buy", "Cancel");
	}
	
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if (dialogid == DIALOG_GUNSTORE)
	{
	    if (response)
	    {
			if (gGunStoreData[listitem][E_GUNSTORE_DATA_PRICE] > GetPlayerMoney(playerid))
			{
			    return  SendClientMessage(playerid, COLOR_ERROR, "[ERROR] You don't have enough money to buy it.");
			}
			
			GivePlayerWeapon(playerid, gGunStoreData[listitem][E_GUNSTORE_DATA_WEAPONID], gGunStoreData[listitem][E_GUNSTORE_DATA_AMMO]);
			GivePlayerMoney(playerid, -gGunStoreData[listitem][E_GUNSTORE_DATA_PRICE]);

			static
			    gunName[32];

            GetWeaponName(gGunStoreData[listitem][E_GUNSTORE_DATA_WEAPONID], gunName, sizeof(gunName));
            
            format(gString, sizeof gString, "** You bought an %s with %d ammo.", gunName, gGunStoreData[listitem][E_GUNSTORE_DATA_AMMO]);
            SendClientMessage(playerid, COLOR_LIGHTBLUE, gString);
		}
	    
	    return true;
	}

	return false;
}

public OnPlayerText(playerid, text[])
{
    SetPlayerChatBubble(playerid, text, COLOR_WHITE, 100.0, 10000);
    
	format(gString, sizeof gString, "%s (%d): {FFFFFF}%s", gPlayerName[playerid], playerid, text);
	SendClientMessageToAll(GetPlayerColor(playerid), gString);
	return false;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/dominate", cmdtext, true, 10) == 0)
	{
	    static
	        zoneid;
	        
		zoneid = gPlayerCurrentGZ[playerid];
	        
	    if (zoneid == -1)
	    {
	        return SendClientMessage(playerid, COLOR_ERROR, "[ERROR] You need to be inside a territory to do this.");
	    }
	    
		if (gGangZoneData[zoneid][E_GANGZONE_DATA_INWAR])
		{
		    return SendClientMessage(playerid, COLOR_ERROR, "[ERROR] The territory is already over-attacking.");
		}
		
		if (gGangZoneData[zoneid][E_GANGZONE_DATA_OWNERID] == gPlayerTeam[playerid])
		{
		    return SendClientMessage(playerid, COLOR_ERROR, "[ERROR] This territory already belongs to your team.");
		}
	
		if (Team_GetNearbyMembers(playerid) < GANGZONE_MEMBERS_NEEDED_TO_ATTACK)
		{
			format(gString, sizeof gString, "[ERROR] You need %d teammates nearby to attack territories.", GANGZONE_MEMBERS_NEEDED_TO_ATTACK);
		    return SendClientMessage(playerid, COLOR_ERROR, gString);
		}

		static
		    attackerid;

        attackerid = gPlayerTeam[playerid];

		gGangZoneData[zoneid][E_GANGZONE_DATA_INWAR] = true;
		gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID] = attackerid;

     	GangZoneFlashForPlayer(playerid, gGangZoneData[zoneid][E_GANGZONE_DATA_ZONEID], ((gTeamData[ attackerid ][E_TEAM_DATA_COLOR] & ~0xFF) | 0xAA));

       	format(gString, sizeof gString, "%s and his %s mates started an attack on %s territory!", gPlayerName[playerid], gTeamData[attackerid][E_TEAM_DATA_NAME], gGangZoneData[zoneid][E_GANGZONE_DATA_NAME]);
       	SendClientMessageToAll(COLOR_ORANGE, gString);
       	
       	SetTimerEx("FinishGangZoneWar", GANGZONE_ATTACK_TIME, false, "i", zoneid);
		return true;
	}
	
	return false;
}

public OnPlayerEnterGangZone(playerid, zoneid)
{
	if (!gGangZoneData[zoneid][E_GANGZONE_DATA_INWAR])
	{
	    if (gGangZoneData[zoneid][E_GANGZONE_DATA_OWNERID] != -1)
	    {
	        static
	            teamid;
	            
			teamid = gGangZoneData[zoneid][E_GANGZONE_DATA_OWNERID];
			
			format(gString, sizeof gString, "** The %s territory belongs to the %s team, to dominate enter '/dominate'", gGangZoneData[zoneid][E_GANGZONE_DATA_NAME], gTeamData[teamid][E_TEAM_DATA_NAME]);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, gString);
		}
		else
		{
			format(gString, sizeof gString, "** The %s territory belongs to no one, to dominate enter '/dominate'", gGangZoneData[zoneid][E_GANGZONE_DATA_NAME]);
		    SendClientMessage(playerid, COLOR_LIGHTBLUE, gString);
		}
	}
}

public FinishGangZoneWar(zoneid)
{
    GangZoneHideForAll(gGangZoneData[zoneid][E_GANGZONE_DATA_ZONEID]);
    
	// If the team that attacked has any member within the territory, success.
	// Looping all players
	for (new i; i < MAX_PLAYERS; i++)
	{
	    // Checking if the playerid is valid
		if (IsPlayerConnected(i))
		{
		    // Checking if the player is from the same team that is attacking the territory
		    if (gPlayerTeam[i] == gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID])
		    {
		        // Checking now if the player is inside the territory
			    if (GangZone_IsPlayerIn(zoneid, i))
			    {
			        gGangZoneData[zoneid][E_GANGZONE_DATA_OWNERID] = gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID];
			        gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID] = -1;
			        gGangZoneData[zoneid][E_GANGZONE_DATA_INWAR] = false;

			        GangZoneShowForAll(gGangZoneData[zoneid][E_GANGZONE_DATA_ZONEID], GangZone_GetOwnerColor(zoneid));
			        
			        static
			            ownerid;
			            
					ownerid = gGangZoneData[zoneid][E_GANGZONE_DATA_OWNERID];

			        format(gString, sizeof gString, "The %s team dominated the %s territory.", gTeamData[ownerid][E_TEAM_DATA_NAME], gGangZoneData[zoneid][E_GANGZONE_DATA_NAME]);
			        SendClientMessageToAll(COLOR_ORANGE, gString);
                    return true;
			    }
			}
		}
	}
	
	// If not, failure
    GangZoneShowForAll(gGangZoneData[zoneid][E_GANGZONE_DATA_ZONEID], GangZone_GetOwnerColor(zoneid));
    
    static
		attackerid;

	attackerid = gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID];
	
	gGangZoneData[zoneid][E_GANGZONE_DATA_ATTACKERID] = -1;
	gGangZoneData[zoneid][E_GANGZONE_DATA_INWAR] = false;
	
    format(gString, sizeof gString, "The %s team didn't succeed when trying to dominate the territory %s.", gTeamData[attackerid][E_TEAM_DATA_NAME], gGangZoneData[zoneid][E_GANGZONE_DATA_NAME]);
 	SendClientMessageToAll(COLOR_ORANGE, gString);
    return true;
}

public OnPlayerUpdateEx(playerid)
{
    // ------------------------------------------------------------------------------------------------------------
    // Using the Streamer plugin, this could all be replaced by Callback OnPlayerEnterDynamicArea
	static
		bool:leaveZone;

    leaveZone = true;
    
    for (new zoneid; zoneid < sizeof(gGangZoneData); zoneid++)
    {
    	if (GangZone_IsPlayerIn(zoneid, playerid))
     	{
     	    leaveZone = false;
     	    if (gPlayerCurrentGZ[playerid] != zoneid)
     	    {
	      		gPlayerCurrentGZ[playerid] = zoneid;
	      		CallLocalFunction("OnPlayerEnterGangZone", "dd", playerid, zoneid);
			}
		}
    }

	
	if (leaveZone)
	{
	    gPlayerCurrentGZ[playerid] = -1;
	}
	
	// ------------------------------------------------------------------------------------------------------------

	return true;
}

// ------------------------------------------------------------------------------------------------------------

Player_GiveSpawnWeapons(playerid)
{
    static
		pScore;

	pScore = GetPlayerScore(playerid);

	// Bronze (not need a minimum score)
	GivePlayerWeapon(playerid, 24, 100); // Deagle

	// Silver
 	if (pScore >= 10)
 	{
 	    GivePlayerWeapon(playerid, 24, 30); // Shotgun
 	    GivePlayerWeapon(playerid, 16, 5); // Granade
 	    GivePlayerWeapon(playerid, 18, 5); // Molotov
 	}
 	else
 	{
 	    return SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] You have received the Bronze Rank armaments.");
	 }

	// Gold
 	if (pScore >= 30)
 	{
 		GivePlayerWeapon(playerid, 29, 300); // MP5
 	    GivePlayerWeapon(playerid, 30, 200); // Ak-47
 	    GivePlayerWeapon(playerid, 4, 1); // Knife
 	}
 	else
 	{
 	    return SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] You have received the Silver Rank armaments.");
 	}

	// Platine
 	if (pScore >= 80)
 	{
 	    GivePlayerWeapon(playerid, 32, 300); // Tec9
 	}
 	else
 	{
 	    return SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] You have received the Gold Rank armaments.");
 	}

	// Diamond
 	if (pScore >= 200)
 	{
 	    GivePlayerWeapon(playerid, 34, 10); // Sniper
 	    SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] You have received the Diamond Rank armaments.");
 	}
 	else
 	{
 	    SendClientMessage(playerid, COLOR_YELLOW, "[SPAWN] You have received the Platine Rank armaments.");
 	}

	return true;
}

// ------------------------------------------------------------------------------------------------------------

GangZone_IsPlayerIn(zoneid, playerid)
{
    if (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || (zoneid < 0 || zoneid >= sizeof gGangZoneData))
    {
        return false;
    }
    
    static
		Float:x, Float:y, Float:z;
		
    GetPlayerPos(playerid, x, y, z);
    return (x > gGangZoneData[zoneid][E_GANGZONE_DATA_POS][0] && x < gGangZoneData[zoneid][E_GANGZONE_DATA_POS][2] && y > gGangZoneData[zoneid][E_GANGZONE_DATA_POS][1] && y < gGangZoneData[zoneid][E_GANGZONE_DATA_POS][3]);

}

GangZone_GetOwnerColor(zoneid)
{
    if (zoneid < 0 || zoneid >= sizeof gGangZoneData)
    {
        return false;
    }
    
	static
	    ownerid,
	    color;

	ownerid = gGangZoneData[zoneid][E_GANGZONE_DATA_OWNERID];

	if (ownerid == -1)
	{
	    color = COLOR_WHITE;
	}
	else
	{
	    color = gTeamData[ownerid][E_TEAM_DATA_COLOR];
	}

	return ((color & ~0xFF) | 0xAA);
}


// ------------------------------------------------------------------------------------------------------------

Team_GetNearbyMembers(playerid)
{
	static
	    count,
	    Float:x,
	    Float:y,
	    Float:z;
	    
	count = 0;
	
	for (new i; i < MAX_PLAYERS; i++)
	{
	    if (IsPlayerConnected(i) && GetPlayerState(i) != PLAYER_STATE_SPECTATING)
	    {
	        if (gPlayerTeam[playerid] == gPlayerTeam[i])
	        {
				GetPlayerPos(playerid, x, y, z);
				if (IsPlayerInRangeOfPoint(i, 20.0, x, y, z))
				{
				    count++;
				}
			}
	    }
	}
	
	return count;
}

// ------------------------------------------------------------------------------------------------------------

