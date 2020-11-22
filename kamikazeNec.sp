#include <freak_fortress_2>
#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <clients>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required


bool isCaberRound = false;
Handle cvarDynamicCabers;

public Plugin myinfo =
{
    name = "KamikazeFF2",
    author = "Samm-Cheese#9500",
    description = "Initiate a Kamikaze Round",
    version = "1.3.8",
    url = "http://sourcemod.net/"
}

public void OnPluginStart()
{
    RegAdminCmd("sm_kamikaze", Command_Kamikaze, ADMFLAG_CUSTOM1); //basically Everyone caber Demo
    PrintToServer("Plugin loaded Successfully!");
    HookEvent("teamplay_round_win", onRoundEnd);
    cvarDynamicCabers = FindConVar("ff2_dynamic_caber");

     //comment for no damagescaling
    for(int client = 1; client <= MaxClients; client++)
    {
        if(IsValidClient(client))
        {
            SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
        }
    } 
    //comment for no damagescaling <
}

//comment for no damagescaling
public void OnClientPutInServer(int client)
{
    if(IsValidClient(client))
        SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
        
    return;
} 
//comment for no damagescaling <


//comment for no damagescaling
public Action OnTakeDamageAlive(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if(!FF2_IsFF2Enabled()) //checks if FF2 Is Enabled
        return Plugin_Continue;

    if(isCaberRound == false)   //checks if caber round
        return Plugin_Continue;
    
    if(attacker<1 || client==attacker || !IsValidClient(attacker) || !IsValidClient(client))    // checks if client and attacker are valid
        return Plugin_Continue;
    
    if(FF2_GetBossIndex(client) != -1 && FF2_GetBossIndex(attacker) == -1)  //checks if receiver is boss and attacker a RED
        return Plugin_Continue;

    if(!IsValidEntity(weapon) || weapon<=MaxClients)    //checks Validity of Weapon
        return Plugin_Continue;

    if(!HasEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"))    //checks stuff
		return Plugin_Continue;
				
    int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");    //checks if caber
	if (index != 307)
	    return Plugin_Continue;

    int receiver_boss = FF2_GetBossIndex(client);
    float result = ((FF2_GetBossMaxHealth(receiver_boss)*FF2_GetBossMaxLives(receiver_boss))/PlayerCounter()+700);
    damage = result;
    damagetype |= DMG_BLAST|DMG_CRIT;
    SDKHooks_TakeDamage(client, inflictor, attacker, damage, DMG_BLAST);

    return Plugin_Changed;
} 
//comment for no damagescaling <

public Action Command_Kamikaze(int client, int args) // does thing aswell
{
    char arg1[32];
    GetCmdArg(1, arg1, sizeof(arg1));
    
    if(args > 1)
    {
    	PrintToChat(client, "[Kamikaze] Wrong amount of arguments. !kamikaze <argument> (argument is used whether or not you want to respawn the players, it's false by default. True / False)");
    }
    
    if(StrEqual(arg1, "true", false))
    {
        isCaberRound = true;
        setDynamicCVar();
    	initKamikazeRound(true);
    }
    else if(StrEqual(arg1, "false", false) || args == 0)
    {
        isCaberRound = true;
        setDynamicCVar();
    	initKamikazeRound(false);
    }
    else
    {
    	PrintToChat(client, "[Kamikaze] Wrong argument. !kamikaze <argument> ( argument can be either false or true, false by default))");
    }
    
    return Plugin_Handled;
}

public void respawnPlayers()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            if (FF2_GetBossIndex(i) == -1)
            {
                TF2_RespawnPlayer(i);
            }
        }
    }
}

public void initKamikazeRound(bool respawn)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            if (FF2_GetBossIndex(i) == -1)
            {
                if(respawn == true)
                {
                    respawn = false;
                    respawnPlayers();
                }
                CreateTimer(2.0, giveCaber);

            }
        }
    }
}

public Action giveCaber(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            if (FF2_GetBossIndex(i) == -1)
            {
                TF2_SetPlayerClass(i, TFClass_DemoMan);
                TF2_RemoveAllWeapons(i);

                //FF2_SpawnWeapon(i, "tf_weapon_stickbomb", 307, 99, 5, " 65 ; 10 ; 207 ; 10 ; 311 ; 1 ; 138; 11 "); uncomment for no damagescaling
                //Caber: dmg from blast +900%, +900% damage to self (instakill), infinite use, 1000% damage vs players

                FF2_SpawnWeapon(i, "tf_weapon_stickbomb", 307, 99, 5, " 65 ; 10 ; 207 ; 10 ; 311 ; 1 ;"); //comment for no damagescaling
                //Caber: dmg from blast +900%, +900% damage to self (instakill), infinite use, damage handled by OnTakeDamageAlive()
            }
        }
    }
}


//comment for no damagescaling
public void onRoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
    isCaberRound = false;
    setDynamicCVar();
    for(int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive); //Unhook all clients at the end of the round, that way nobody is hooked multiple times, which would cause OnTakeDamage to activate multiple times when that player is hurt
		}
	}
}
//comment for no damagescaling <


bool IsValidClient(int client, bool replaycheck = true) //checks if client is valid
{
    if (client<=0 || client>MaxClients)
    {
        return false;
    }
    if (!IsClientInGame(client))
    {
        return false;
    }
    if (GetEntProp(client, Prop_Send, "m_bIsCoaching"))
	{
    	return false;
    }
    if (replaycheck)
    {
        if (IsClientSourceTV(client) || IsClientReplay(client))
        {
            return true;
        }

    }
    return true;
}

//comment for no damagescaling
int PlayerCounter()
{
    int PCR = GetTeamClientCount(2);
    return PCR;
}
//comment for no damagescaling <

public void setDynamicCVar()
{

    if (isCaberRound == true && cvarDynamicCabers != null)
    {
        SetConVarBool(cvarDynamicCabers, false);
    }
    else if (isCaberRound == false && cvarDynamicCabers != null)
    {
        SetConVarBool(cvarDynamicCabers, true);
    }
    else
    {
        PrintToServer("ff2_dynamic_cabers not Found");
    }

}
