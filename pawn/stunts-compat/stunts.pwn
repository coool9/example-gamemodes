/*
	NGS Stunts Room
	Made by Lasha "dakyskye" Kanteladze


	=======================================
	|                                     |
	|           NGS Stunts Room           |
	|             By dakyskye             |
	|                                     |
	=======================================
*/

#include <a_samp>

#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
#endif
#define MAX_PLAYERS 32

#define YSI_NO_HEAP_MALLOC

#include <YSI_Server\y_scriptinit>
#include <YSI_Visual\y_commands>
#include <YSI_Coding\y_va>
#include <YSI_Server\y_colours>
#include <YSI_Visual\y_dialog>
#include <YSI_Coding\y_inline>
#include <YSI_Coding\y_timers>
#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_hooks>

#include <formatex>

#pragma compress 0

#if !defined isnull
	#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

//
enum E_PLAYER_SPEEDOMETER
{
	bool:E_PLAYER_SPEEDOMETER_IS_SHOWN,
	PlayerText:E_PLAYER_SPEEDOMETER_TITLE[2],
	PlayerText:E_PLAYER_SPEEDOMETER_VEHICLE,
	PlayerText:E_PLAYER_SPEEDOMETER_SPEED
};


#define MAX_SPAWN_NAME 32

enum E_SPAWN
{
	E_SPAWN_NAME[MAX_SPAWN_NAME],
	Float:E_SPAWN_POS_X,
	Float:E_SPAWN_POS_Y,
	Float:E_SPAWN_POS_Z,
	Float:E_SPAWN_POS_A
};


#define MAX_COMMAND_DESCRIPTION_LENGTH 113

enum E_COMMAND_DATA
{
	E_COMMAND_NAME[MAX_COMMAND_LENGTH],
	E_COMMAND_ALIAS[MAX_COMMAND_LENGTH / 2],
	E_COMMAND_DESCRIPTION[MAX_COMMAND_DESCRIPTION_LENGTH]
};

//
new Text:gServerTextDraw;
new gSpeedoTextDraw[MAX_PLAYERS][E_PLAYER_SPEEDOMETER];
new gServerSpawns[3][E_SPAWN];
new gServerCommands[14][E_COMMAND_DATA];
new Iterator:gPlayerTPRequests[MAX_PLAYERS]<MAX_PLAYERS>;

//
main()
{
	print("\n");
	print(" =======================================");
	print(" |                                     |");
	print(" |           NGS Stunts Room           |");
	print(" |             By dakyskye             |");
	print(" |                                     |");
	print(" =======================================");
	print("\n");
	print(" > Asserting max players sort with defined MAX_PLAYERS");
	assert(GetMaxPlayers() == MAX_PLAYERS);
	print(" > Assertion succeed");
	print("\n");
}

//
hook OnScriptInit()
{
	SetGameModeText("NGS Stunts Room");

	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	SetWeather(2);
	SetWorldTime(16);

	gServerTextDraw = TextDrawCreate(633.999572, 3.333337, "NGS Stunts Room");
	TextDrawLetterSize(gServerTextDraw, 0.400000, 1.600000);
	TextDrawAlignment(gServerTextDraw, 3);
	TextDrawColor(gServerTextDraw, -610526465);
	TextDrawSetShadow(gServerTextDraw, 0);
	TextDrawSetOutline(gServerTextDraw, 1);
	TextDrawBackgroundColor(gServerTextDraw, 255);
	TextDrawFont(gServerTextDraw, 2);
	TextDrawSetProportional(gServerTextDraw, 1);

	AddNewSpawn("Los Santos", 1481.6265, -1739.4241, 13.5469, 5.2883);
	AddNewSpawn("San Fierro", -1982.5508, 883.1596, 45.2031, 91.1614);
	AddNewSpawn("Las Venturas", 2031.8076, 1007.8995, 10.8203, 268.7229);

	RegisterCommandInfo("help", "get a help about a command");
	RegisterCommandInfo("heal", "fills in your health and repairs a car if you're in the driver seat", "hp");
	RegisterCommandInfo("kill", "sets your health to 0 (kills you)");
	RegisterCommandInfo("teleport", "offers you to teleport to certain places", "tp");
	RegisterCommandInfo("skin", "changes your skin by inputting a skin ID");
	RegisterCommandInfo("vehicle", "swpans a vehicle or vehicle part by inputting a vehicle ID", "veh");
	RegisterCommandInfo("destroyvehicle", "destroys a vehicle if you're in the driver seat", "dveh");
	RegisterCommandInfo("virtualworld", "changes your virtual world by inputting a virtual world id", "vw");
	RegisterCommandInfo("savepos", "saves your current on-foot or vehicle position", "spos");
	RegisterCommandInfo("pos", "teleports you to your previously saved on-foot or vehicle position");
	RegisterCommandInfo("commands", "lists all the available commands", "cmds");
	RegisterCommandInfo("alts", "lists the commands with the aliases");
	RegisterCommandInfo("goto", "sends a player your teleport requests by inputting a valid player id", "g");
	RegisterCommandInfo("requests", "lists who requested to teleported to you", "r");

	for (new in = 0; in != sizeof gServerCommands; in++)
	{
		if (!isnull(gServerCommands[in][E_COMMAND_ALIAS]))
		{
			Command_AddAlt(Command_GetID(gServerCommands[in][E_COMMAND_NAME]), gServerCommands[in][E_COMMAND_ALIAS]);
		}
	}

	for(new id = 1; id != 312; id++)
	{
		if (id == 74)
		{
			continue;
		}
		AddPlayerClass(id, 1514.7428, -2286.0576, 13.5469, 269.0387, 0, 0, 0, 0, 0, 0);
	}

	Iter_Init(gPlayerTPRequests);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnScriptExit()
{
	TextDrawDestroy(gServerTextDraw);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerConnect(playerid)
{
	SendClientMessage(playerid, X11_FOREST_GREEN, "Welcome to the NGS Stunts Room");
	SendClientMessage(playerid, X11_FOREST_GREEN, "Entertain and train yourself with the freeroam of vehicles");
	SendClientMessage(playerid, X11_FOREST_GREEN, "To get the list of commands, type /commands");
	SendClientMessage(playerid, X11_FOREST_GREEN, "To get the list of command aliases, type /alts");
	SendClientMessage(playerid, X11_FOREST_GREEN, "To get a help for a command, type /help");

	new pName[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, pName, sizeof(pName));
	va_SendClientMessageToAll(X11_ORANGE_RED, "" SALMON "%s " ORANGE_RED "is connecting to the server", pName);

	TextDrawShowForPlayer(playerid, gServerTextDraw);

	gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0] = CreatePlayerTextDraw(playerid, 164.353012, 331.749908, "Vehicle:");
	PlayerTextDrawLetterSize(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], 0.306823, 1.360833);
	PlayerTextDrawAlignment(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], 3);
	PlayerTextDrawColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], -1);
	PlayerTextDrawSetShadow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], 0);
	PlayerTextDrawSetOutline(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], 1);
	PlayerTextDrawBackgroundColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], 255);
	PlayerTextDrawFont(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], 1);
	PlayerTextDrawSetProportional(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0], 1);

	gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1] = CreatePlayerTextDraw(playerid, 164.353012, 349.250000, "Speed:");
	PlayerTextDrawLetterSize(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], 0.306823, 1.360833);
	PlayerTextDrawAlignment(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], 3);
	PlayerTextDrawColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], -1);
	PlayerTextDrawSetShadow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], 0);
	PlayerTextDrawSetOutline(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], 1);
	PlayerTextDrawBackgroundColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], 255);
	PlayerTextDrawFont(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], 1);
	PlayerTextDrawSetProportional(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1], 1);

	gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE] = CreatePlayerTextDraw(playerid, 172.823532, 331.166748, "_");
	PlayerTextDrawLetterSize(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], 0.239999, 1.541666);
	PlayerTextDrawAlignment(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], 1);
	PlayerTextDrawColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], -1);
	PlayerTextDrawSetShadow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], 0);
	PlayerTextDrawSetOutline(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], 1);
	PlayerTextDrawBackgroundColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], 255);
	PlayerTextDrawFont(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], 2);
	PlayerTextDrawSetProportional(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], 1);

	gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED] = CreatePlayerTextDraw(playerid, 172.352935, 348.666748, "0_KMPH");
	PlayerTextDrawLetterSize(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], 0.239999, 1.541666);
	PlayerTextDrawAlignment(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], 1);
	PlayerTextDrawColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], -1);
	PlayerTextDrawSetShadow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], 0);
	PlayerTextDrawSetOutline(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], 1);
	PlayerTextDrawBackgroundColor(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], 255);
	PlayerTextDrawFont(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], 2);
	PlayerTextDrawSetProportional(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], 1);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	PlayerTextDrawDestroy(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0]);
	PlayerTextDrawDestroy(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1]);
	PlayerTextDrawDestroy(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE]);
	PlayerTextDrawDestroy(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED]);

	Iter_Clear(gPlayerTPRequests[playerid]);

	new const maxPlayerID = GetPlayerPoolSize();

	for (new in = 0; in != maxPlayerID + 1; in++)
	{
		if (in == playerid)
		{
			continue;
		}
		else if (Iter_Contains(gPlayerTPRequests[in], playerid))
		{
			Iter_Remove(gPlayerTPRequests[in], playerid);
		}
	}

	new const disconnectReason[3][14] =
	{
		"Timeout/Crash",
		"Quit",
		"Kick/Ban"
	};

	new pName[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, pName, sizeof(pName));

	va_SendClientMessageToAll(X11_ORANGE_RED, "" SALMON "%s " ORANGE_RED "has just left the server (" TOMATO "%s" ORANGE_RED ")", pName, disconnectReason[reason]);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1514.7428, -2286.0576, 13.5469);
	SetPlayerCameraPos(playerid, 1517.9448, -2285.8569 + 0.4, 13.3828);
	SetPlayerCameraLookAt(playerid, 1514.7428, -2286.0576, 13.5469);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (((newkeys & (KEY_FIRE)) == (KEY_FIRE)) && ((oldkeys & (KEY_FIRE)) != (KEY_FIRE)))
	{
		if (GetPlayerVehicleSeat(playerid) == 0)
		{
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (oldstate == PLAYER_STATE_ONFOOT && ((newstate == PLAYER_STATE_DRIVER) || (newstate == PLAYER_STATE_PASSENGER)))
	{
		PlayerTextDrawShow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0]);
		PlayerTextDrawShow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1]);
		PlayerTextDrawShow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE]);
		PlayerTextDrawShow(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED]);
		new vehName[128];
		format(vehName, sizeof(vehName), "~w~%v", GetVehicleModel(GetPlayerVehicleID(playerid)));
		PlayerTextDrawSetString(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE], vehName);
		gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_IS_SHOWN] = true;
	}
	if ((newstate != PLAYER_STATE_DRIVER) && (newstate != PLAYER_STATE_PASSENGER))
	{
		PlayerTextDrawHide(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][0]);
		PlayerTextDrawHide(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_TITLE][1]);
		PlayerTextDrawHide(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_VEHICLE]);
		PlayerTextDrawHide(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED]);
		gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_IS_SHOWN] = false;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	inline _response(playerID, dialogID, response, listitem, string:inputtext[])
	{
		#pragma unused dialogID, listitem, inputtext

		if (!response)
		{
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if (GetPlayerVehicleSeat(playerid) == 0)
		{
			SetVehiclePos(GetPlayerVehicleID(playerID), fX, fY, fZ);
		}
		else
		{
			SetPlayerPos(playerID, fX, fY, fZ);
		}

		SendClientMessage(playerID, X11_FOREST_GREEN, "You just teleported to the position you marked on map");
	}

	Dialog_ShowCallback(playerid, using inline _response, DIALOG_STYLE_MSGBOX, "Want to teleport?", "You just clicked on a map, if you want to teleport there, click \"TP\"", "TP", "Abort");

	return Y_HOOKS_CONTINUE_RETURN_1;
}

ptask UpdatePlayerVehicleSpeed[100](playerid)
{
	if (gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_IS_SHOWN])
	{
		new
			Float:velX,
			Float:velY,
			Float:velZ,
			Float:vehSpeed
		;

		GetVehicleVelocity(GetPlayerVehicleID(playerid), velX, velY, velZ);

		vehSpeed = (floatsqroot(((velX * velX) + (velY * velY)) + (velZ * velZ)) * 175.8);

		new speedAsString[9];
		format(speedAsString, sizeof(speedAsString), "%i_KM/H", floatround(vehSpeed, floatround_floor));

		PlayerTextDrawSetString(playerid, gSpeedoTextDraw[playerid][E_PLAYER_SPEEDOMETER_SPEED], speedAsString);
	}
}

timer CheckPlayerTPRequest[30000](playerid, requesterID)
{
	if (Iter_Contains(gPlayerTPRequests[playerid], requesterID))
	{
		Iter_Remove(gPlayerTPRequests[playerid], requesterID);
		new pName[MAX_PLAYER_NAME + 1];
		GetPlayerName(playerid, pName, sizeof(pName));
		va_SendClientMessage(requesterID, X11_FOREST_GREEN, "Your teleport request to %s has expired", pName);
	}
}

//
YCMD:help(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "help");
		return 1;
	}
	if (isnull(cmdtext))
	{
		SendClientMessage(playerid, X11_FOREST_GREEN, "Usage of the help command is \"/help <command>\"");
		SendClientMessage(playerid, X11_FOREST_GREEN, "Example usage: /help commands");
	}
	else
	{
		Command_ReProcess(playerid, cmdtext, true);
	}
	return 1;
}

YCMD:heal(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "heal");
		return 1;
	}
	SetPlayerHealth(playerid, 100.0);
	if (GetPlayerVehicleSeat(playerid) == 0)
	{
		RepairVehicle(GetPlayerVehicleID(playerid));
		SendClientMessage(playerid, X11_FOREST_GREEN, "Your health was filled and the car was repaired");
	}
	else
	{
		SendClientMessage(playerid, X11_FOREST_GREEN, "Your health was filled");
	}
	return 1;
}

YCMD:kill(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "kill");
		return 1;
	}
	SetPlayerHealth(playerid, 0.0);
	SendClientMessage(playerid, X11_FOREST_GREEN, "You killed yourself");
	return 1;
}

YCMD:teleport(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "teleport");
		return 1;
	}
	inline _response(playerID, dialogID, response, listitem, string:inputtext[])
	{
		#pragma unused dialogID, inputtext

		if (!response)
		{
			return 0;
		}

		if (GetPlayerVehicleSeat(playerid) == 0)
		{
			SetVehiclePos(
				GetPlayerVehicleID(playerid),
				gServerSpawns[listitem][E_SPAWN_POS_X],
				gServerSpawns[listitem][E_SPAWN_POS_Y],
				gServerSpawns[listitem][E_SPAWN_POS_Z]
			);
		}
		else
		{
			SetPlayerPos(
				playerID,
				gServerSpawns[listitem][E_SPAWN_POS_X],
				gServerSpawns[listitem][E_SPAWN_POS_Y],
				gServerSpawns[listitem][E_SPAWN_POS_Z]
			);
			SetPlayerFacingAngle(playerID, gServerSpawns[listitem][E_SPAWN_POS_A]);
		}
		va_SendClientMessage(playerid, X11_FOREST_GREEN, "You just teleported to %s", gServerSpawns[listitem][E_SPAWN_NAME]);
	}
	new list[128];
	for (new in = 0; in != sizeof gServerSpawns; in++)
	{
		if (list[0] == EOS)
		{
			strins(list, gServerSpawns[in][E_SPAWN_NAME], 0);
		}
		else
		{
			new listItem[MAX_SPAWN_NAME];
			format(listItem, sizeof(listItem), "\n%s", gServerSpawns[in][E_SPAWN_NAME]);
			strcat(list, listItem);
		}
	}
	Dialog_ShowCallback(playerid, using inline _response, DIALOG_STYLE_LIST, "Select where you want to teleport", list, "TP", "Abort");
	return 1;
}

YCMD:skin(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "skin");
		return 1;
	}
	inline _response(playerID, dialogID, response, listitem, string:inputtext[])
	{
		#pragma unused dialogID, listitem

		if (!response)
		{
			return 0;
		}

		new skinid;
		skinid = strval(inputtext);
		if (skinid < 1 || skinid > 311)
		{
			Dialog_ShowCallback(playerID, using inline _response, DIALOG_STYLE_INPUT, "Input a valid skin ID", "Valid skin IDs are from 1 to 311.\nInput the skin ID you want to select", "Next", "Cancel");
			return 0;
		}
		new const vehID = GetPlayerVehicleID(playerID);
		new const vehSeat = GetPlayerVehicleSeat(playerID);
		SetPlayerSkin(playerID, skinid);
		if (vehID != -1)
		{
			PutPlayerInVehicle(playerID, vehID, vehSeat);
		}
		va_SendClientMessage(playerID, X11_FOREST_GREEN, "You successfully changed your skin id to " CORAL "%d", skinid);
	}
	Dialog_ShowCallback(playerid, using inline _response, DIALOG_STYLE_INPUT, "Input a skin ID", "Input the skin ID you want to select", "Next", "Cancel");
	return 1;
}

YCMD:vehicle(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "vehicle");
		return 1;
	}
	inline _response(playerID, dialogID, response, listitem, string:inputtext[])
	{
		#pragma unused dialogID, listitem

		if (!response)
		{
			return 0;
		}

		new vehicleid;
		vehicleid = strval(inputtext);
		if (vehicleid < 400 || vehicleid > 611)
		{
			Dialog_ShowCallback(playerID, using inline _response, DIALOG_STYLE_INPUT, "Input a valid vehicle ID", "Valid vehicle IDs are from 400 to 611, but there are also exceptions.\nInput the vehicle ID you want to spawn", "Next", "Cancel");
			return 0;
		}
		new Float:posX, Float:posY, Float:posZ, Float:posA;
		GetPlayerPos(playerID, posX, posY, posZ);
		GetPlayerFacingAngle(playerID, posA);
		new vehID = CreateVehicle(vehicleid, posX+0.8, posY+0.2, posZ, posA, -1, -1, -1);
		SetVehicleNumberPlate(vehID, "NGS");
		SetVehicleVirtualWorld(
			vehID,
			GetPlayerVirtualWorld(playerID)
		);
		AddVehicleComponent(vehID, 1010);
		new msg[128];
		format(msg, sizeof(msg), "You just spawned "SALMON"%v "FOREST_GREEN" ("SALMON"%d"FOREST_GREEN")", vehicleid, vehicleid);
		SendClientMessage(playerid, X11_FOREST_GREEN, msg);
	}
	Dialog_ShowCallback(playerid, using inline _response, DIALOG_STYLE_INPUT, "Input a vehicle ID", "Input the vehicle ID you want to spawn", "Next", "Cancel");
	return 1;
}

YCMD:destroyvehicle(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "destroyvehicle");
		return 1;
	}
	if (GetPlayerVehicleSeat(playerid) == 0)
	{
		DestroyVehicle(GetPlayerVehicleID(playerid));
		SendClientMessage(playerid, X11_FOREST_GREEN, "You just destroyed a vehicle");
	}
	else
	{
		SendClientMessage(playerid, X11_FOREST_GREEN, "You must be in the driver's seat of a vehicle to destroy it");
	}
	return 1;
}

YCMD:virtualworld(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "virtualworld");
		return 1;
	}
	inline _response(playerID, dialogID, response, listitem, string:inputtext[])
	{
		#pragma unused dialogID, listitem

		if (!response)
		{
			return 0;
		}

		new const worldID = strval(inputtext);
		new vehID = GetPlayerVehicleID(playerID);
		new vehSeat = GetPlayerVehicleSeat(playerID);
		if (vehID != -1)
		{
			PutPlayerInVehicle(playerID, vehID, vehSeat);
		}
		SetVehicleVirtualWorld(vehID, worldID);
		SetPlayerVirtualWorld(playerID, worldID);
		va_SendClientMessage(playerID, X11_FOREST_GREEN, "You changed your virtual world to " CORAL "%d", worldID);
	}
	Dialog_ShowCallback(playerid, using inline _response, DIALOG_STYLE_INPUT, "Input a virtual world ID", "Input the virtual world ID you want to move to", "Go", "Cancel");
	return 1;
}

YCMD:savepos(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "savepos");
		return 1;
	}
	new Float:x, Float:y, Float:z, Float:a;
	if (GetPlayerVehicleSeat(playerid) == 0)
	{
		GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
		SetPVarFloat(playerid, "vehX", x);
		SetPVarFloat(playerid, "vehY", y);
		SetPVarFloat(playerid, "vehZ", z);
	}
	else
	{
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);
		SetPVarFloat(playerid, "posX", x);
		SetPVarFloat(playerid, "posY", y);
		SetPVarFloat(playerid, "posZ", z);
		SetPVarFloat(playerid, "posA", a);
	}
	SendClientMessage(playerid, X11_FOREST_GREEN, "You just saved your current position, use /pos to teleport there anytime");
	return 1;
}

YCMD:pos(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "pos");
		return 1;
	}
	new Float:x, Float:y, Float:z, Float:a;
	if (GetPlayerVehicleSeat(playerid) == 0)
	{
		x = GetPVarFloat(playerid, "vehX");
		y = GetPVarFloat(playerid, "vehY");
		z = GetPVarFloat(playerid, "vehZ");
		if (!(x != 0.0 && y != 0.0 && z != 0.0))
		{
			SendClientMessage(playerid, X11_FOREST_GREEN, "You have not saved any in-vehicle position yet");
			return 3;
		}
		SetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
	}
	else
	{
		x = GetPVarFloat(playerid, "posX");
		y = GetPVarFloat(playerid, "posY");
		z = GetPVarFloat(playerid, "posZ");
		a = GetPVarFloat(playerid, "posA");
		if (!(x != 0.0 && y != 0.0 && z != 0.0))
		{
			SendClientMessage(playerid, X11_FOREST_GREEN, "You have not saved any on-foot position yet");
			return 3;
		}
		SetPlayerPos(playerid, x, y, z);
		SetPlayerFacingAngle(playerid, a);
	}
	SendClientMessage(playerid, X11_FOREST_GREEN, "You just teleported to your saved position");
	return 1;
}

YCMD:commands(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "commands");
		return 1;
	}
	new commands[128];
	for (new i = 0; i != Command_GetPlayerCommandCount(playerid); i++)
	{
		new cmdName[YSI_MAX_STRING];
		cmdName = Command_GetNext(i, playerid);
		new bool:isAlt = false;
		for (new in = 0; in != 14; in++)
		{
			if (isnull(gServerCommands[in][E_COMMAND_ALIAS]))
			{
				continue;
			}
			else if (!strcmp(cmdName, gServerCommands[in][E_COMMAND_ALIAS]))
			{
				isAlt = true;
				break;
			}
		}
		if (!isAlt)
		{
			new fmt[MAX_COMMAND_LENGTH + 3];
			format(fmt, sizeof fmt, "/%s ", cmdName);
			strcat(commands, fmt);
		}
	}
	SendClientMessage(playerid, X11_GOLDENROD, "All the available commands are:");
	SendClientMessage(playerid, X11_GOLDENROD, commands);
	return 1;
}

YCMD:alts(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "alts");
		return 1;
	}
	SendClientMessage(playerid, X11_GOLDENROD, "Commands with alternative names are:");
	for (new in = 0; in != sizeof gServerCommands; in++)
	{
		if (!isnull(gServerCommands[in][E_COMMAND_ALIAS]))
		{
			new msg[128];
			format(msg, sizeof(msg), "/%s (/%s)", gServerCommands[in][E_COMMAND_NAME], gServerCommands[in][E_COMMAND_ALIAS]);
			SendClientMessage(playerid, X11_GOLDENROD, msg);
		}
	}
	return 1;
}

YCMD:goto(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "goto");
		return 1;
	}
	inline _response(playerID, dialogID, response, listitem, string:inputtext[])
	{
		#pragma unused dialogID, listitem

		if (!response)
		{
			return 0;
		}

		new pid;
		pid = strval(inputtext);
		if (!IsPlayerConnected(pid))
		{
			va_SendClientMessage(playerID, X11_FOREST_GREEN, "Either a player with ID "CORAL"%d "FOREST_GREEN"is not connected or "CORAL"%d "FOREST_GREEN"is not valid ID", pid);
			return 0;
		}
		if (pid == playerID)
		{
			SendClientMessage(playerID, X11_FOREST_GREEN, "You can't request a teleport with yourself");
			return 0;
		}

		Iter_Add(gPlayerTPRequests[pid], playerID);

		new requesterName[MAX_PLAYER_NAME + 1], requestedName[MAX_PLAYER_NAME + 1];
		GetPlayerName(playerID, requesterName, sizeof(requesterName));
		GetPlayerName(pid, requestedName, sizeof(requestedName));
		va_SendClientMessage(playerID, X11_FOREST_GREEN, "You requested a teleport to " CORAL "%s", requestedName);
		va_SendClientMessage(pid, X11_FOREST_GREEN, ""CORAL"%s "FOREST_GREEN"has requested to teleport to you", requesterName);
		defer CheckPlayerTPRequest(pid, playerID);
	}
	Dialog_ShowCallback(playerid, using inline _response, DIALOG_STYLE_INPUT, "Input a player ID", "Input the player ID you want to teleport to", "TP", "Abort");
	return 1;
}

YCMD:requests(playerid, cmdtext[], help)
{
	if (help)
	{
		ShowCommandHelp(playerid, "requests");
		return 1;
	}
	if (Iter_Count(gPlayerTPRequests[playerid]) == 0)
	{
		SendClientMessage(playerid, X11_FOREST_GREEN, "You don't have any teleport request");
		return 3;
	}
	inline _response(playerID, dialogID, response, listitem, string:inputtext[])
	{
		#pragma unused dialogID, inputtext

		if (!response)
		{
			return 0;
		}

		new requesterIDs[MAX_PLAYERS];
		foreach (new i : gPlayerTPRequests[playerID])
		{
			static in = 0;
			requesterIDs[in] = i;
			in++;
		}
		new const sPlayerID = requesterIDs[listitem];
		if (!Iter_Contains(gPlayerTPRequests[playerID], sPlayerID))
		{
			SendClientMessage(playerid, X11_FOREST_GREEN, "That player might have disconnected or the request expired");
			return 1;
		}
		new
			requesterName[MAX_PLAYER_NAME + 1],
			playerName[MAX_PLAYER_NAME + 1],
			playerVW,
			Float:x,
			Float:y,
			Float:z,
			Float:a
		;

		GetPlayerPos(playerID, x, y, z);
		GetPlayerFacingAngle(playerID, a);
		GetPlayerName(playerID, playerName, sizeof(playerName));
		playerVW = GetPlayerVirtualWorld(playerID);
		x += 0.5;

		GetPlayerName(sPlayerID, requesterName, sizeof(requesterName));

		va_SendClientMessage(playerID, X11_FOREST_GREEN, "You've accepted "CORAL"%s's "FOREST_GREEN"teleport request", requesterName);
		va_SendClientMessage(sPlayerID, X11_FOREST_GREEN, ""CORAL"%s "FOREST_GREEN"has just accepted your teleport request", playerName);

		if (GetPlayerVehicleSeat(sPlayerID) == 0)
		{
			new const sPlayerVehicleID = GetPlayerVehicleID(sPlayerID);
			SetVehicleVirtualWorld(sPlayerVehicleID, playerVW);
			SetPlayerVirtualWorld(sPlayerID, playerVW);
			SetVehiclePos(sPlayerVehicleID, x, y, z);
		}
		else
		{
			SetPlayerPos(sPlayerID, x, y, z);
			SetPlayerFacingAngle(sPlayerID, a);
			SetPlayerVirtualWorld(sPlayerID, playerVW);
		}

		Iter_Remove(gPlayerTPRequests[playerID], sPlayerID);
	}
	new list[YSI_MAX_STRING];
	for (new it = Iter_First(gPlayerTPRequests[playerid]); it != Iter_End(gPlayerTPRequests[playerid]); it = Iter_Next(gPlayerTPRequests[playerid], it))
	{
		new pName[MAX_PLAYER_NAME];
		GetPlayerName(it, pName, sizeof(pName));
		if (list[0] == EOS)
		{
			strins(list, pName, 0);
		}
		else
		{
			new listItem[MAX_PLAYER_NAME + 3];
			format(listItem, sizeof(listItem), "\n%s", pName);
			strcat(list, listItem);
		}
	}
	Dialog_ShowCallback(playerid, using inline _response, DIALOG_STYLE_LIST, "Select whose teleport request to accept", list, "Select", "Abort");
	return 1;
}

//
public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
	return COMMAND_OK;
}

public e_COMMAND_ERRORS:OnPlayerCommandPerformed(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
	return COMMAND_OK;
}

//
AddNewSpawn(const name[MAX_SPAWN_NAME], const Float:x, const Float:y, const Float:z, const Float:a)
{
	static index = 0;

	if (index == sizeof gServerSpawns)
	{
		print("[AddNewSpawn] couldn't exceed the limit of an array");
		return 0;
	}

	gServerSpawns[index][E_SPAWN_NAME] = name;
	gServerSpawns[index][E_SPAWN_POS_X] = x;
	gServerSpawns[index][E_SPAWN_POS_Y] = y;
	gServerSpawns[index][E_SPAWN_POS_Z] = z;
	gServerSpawns[index][E_SPAWN_POS_A] = a;

	index++;

	return 1;
}

RegisterCommandInfo(
	const command[MAX_COMMAND_LENGTH],
	const description[MAX_COMMAND_DESCRIPTION_LENGTH],
	const alias[MAX_COMMAND_LENGTH / 2] = ""
) {
	static index = 0;

	if (index == sizeof gServerCommands)
	{
		print("[RegisterCommandInfo] couldn't exceed the limit of an array");
		return 0;
	}

	gServerCommands[index][E_COMMAND_NAME] = command;
	gServerCommands[index][E_COMMAND_DESCRIPTION] = description;
	gServerCommands[index][E_COMMAND_ALIAS] = alias;

	index++;

	return 1;
}

ShowCommandHelp(const playerid, const command[MAX_COMMAND_LENGTH])
{
	new cmd[E_COMMAND_DATA], bool:found = false;

	for (new in = 0; in != sizeof gServerCommands; in++)
	{
		if (!strcmp(command, gServerCommands[in][E_COMMAND_NAME]))
		{
			strcat(cmd[E_COMMAND_ALIAS], gServerCommands[in][E_COMMAND_ALIAS]);
			strcat(cmd[E_COMMAND_DESCRIPTION], gServerCommands[in][E_COMMAND_DESCRIPTION]);
			found = true;
			break;
		}
	}

	if (!found)
	{
		SendClientMessage(playerid, X11_FOREST_GREEN, "No help section was registered for this command");
		printf("[ShowCommandHelp] couldn't show help for command \"%s\"; It might be not registered", command);
		return 0;
	}

	va_SendClientMessage(playerid, X11_SEA_GREEN_3, "> help section for the command - "CORAL"%s", command);

	if (isnull(cmd[E_COMMAND_ALIAS]))
	{
		SendClientMessage(playerid, X11_SEA_GREEN_3, "> does not have any alias");
	}
	else
	{
		va_SendClientMessage(playerid, X11_SEA_GREEN_3, "> has the alias - "CORAL"%s", cmd[E_COMMAND_ALIAS]);
	}

	if (isnull(cmd[E_COMMAND_DESCRIPTION]))
	{
		SendClientMessage(playerid, X11_SEA_GREEN_3, "> no command description provided");
	}
	else
	{
		va_SendClientMessage(playerid, X11_SEA_GREEN_3, "> description: %s", cmd[E_COMMAND_DESCRIPTION]);
	}

	return 1;
}
