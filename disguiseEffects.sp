#include    <sourcemod>
#include    <sdktools>
#include    <tf2condhooks>
#include    <dhooks>
#include    <tf2attributes>
#include    <tf2_stocks>
#include    <stocksoup/tf/entity_prop_stocks>
#include    <rtd2>
#include    <clients>

#undef REQUIRE_PLUGIN
#tryinclude <freak_fortress_2>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION		"1.0.0"

/***************[Variables]***************/

Handle  g_cvEnableDisguiseEffects;
Handle  g_cvDisguiseCooldown;
Handle  g_cvEffectDuration;
Handle  hWaitTimer[MAXPLAYERS+1];
float   g_flDisguiseTimer                       = 30.0;
float   g_flEffectDuration                      = 10.0;
bool    g_bEffectsEnabled                       = true;
bool    ff2Running;

/***************[PLUGIN SETUP]***************/

public Plugin myinfo = 
{
    name        = "disguised Effects",
    author      = "Samm-Cheese#9500",
    description = "Allows the Disguisekit to have various effects",
    version     = PLUGIN_VERSION,
    url         = "http://alliedmods.net"
}

public APLRes AskPluginLoad2(Handle myself, bool late)
{
    MarkNativeAsOptional("FF2_IsFF2Enabled");
    MarkNativeAsOptional("FF2_GetBossIndex");
    MarkNativeAsOptional("FF2_GetBossTeam");

    return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
    #if defined _FF2_included
	ff2Running = LibraryExists("freak_fortress_2") ? FF2_IsFF2Enabled() : false;
	#else
	ff2Running = false;
	#endif
}

public void OnPluginStart()
{
    CreateConVar(
        "sm_disguiseeffects_version", PLUGIN_VERSION,
        "Disguise Effects Version", 
        FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY
    );

    g_cvEnableDisguiseEffects = CreateConVar(
        "sm_disgeffects_enabled", "1",
        "Enables Disguise Effects",
        FCVAR_NOTIFY
    );

    g_cvEffectDuration = CreateConVar(
        "sm_disguiseeffects_duration", "10.0",
        "Duration of the Disguise Effects",
        FCVAR_NOTIFY
    );

    g_cvDisguiseCooldown = CreateConVar(
        "sm_disguisecooldown", "15.0",
        "Time you can Use the Disguise Kit again",
        FCVAR_NOTIFY
    );


    HookConVarChange(g_cvEnableDisguiseEffects,     convar_ChangeEnable);
    HookConVarChange(g_cvEffectDuration,            convar_ChangeDuration);
    HookConVarChange(g_cvDisguiseCooldown,          convar_ChangeTimer);


    g_flEffectDuration      =   GetConVarFloat(g_cvEffectDuration);
    g_bEffectsEnabled       =   GetConVarBool(g_cvEnableDisguiseEffects);
    g_flDisguiseTimer       =   GetConVarFloat(g_cvDisguiseCooldown);
}

/***************[CONVARS]***************/

public int convar_ChangeEnable(Handle convar, const char[] sOld, const char[] sNew)
{
    if (StringToInt(sNew) >= 1)
    {
        g_bEffectsEnabled = true;
    }
    else
    {
        g_bEffectsEnabled = false;
    }
}

public int convar_ChangeTimer(Handle convar, const char[] sOld, const char[] sNew)
{
    g_flDisguiseTimer = StringToFloat(sNew);
}

public int convar_ChangeDuration(Handle convar, const char[] sOld, const char[] sNew)
{
    g_flEffectDuration = StringToFloat(sNew);
}

/***************[PLUGIN FUNCTIONALITY]***************/

public Action TF2_OnAddCond(int client, TFCond &cond, float &time, int &provider)
{
    if (IsValidClient(client))
    {
        if (g_bEffectsEnabled)
        {
            if (cond == TFCond_Disguised && !ff2Running)
            {
                float wait = 0.2;
                Handle pack;
                hWaitTimer[client] = CreateDataTimer(wait, searchAndExec, pack);
                WritePackCell(pack, client);
            }
            else if (cond == TFCond_Disguised && ff2Running)
            {
                if (FF2_GetBossIndex(client) == -1)
                {
                    // We dont want a Hale to get Disguise effects
                    float wait = 0.2;
                    Handle pack;
                    hWaitTimer[client] = CreateDataTimer(wait, searchAndExec, pack);
                    WritePackCell(pack, client);
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action searchAndExec(Handle Timer, Handle pack)
{
    int client;
    ResetPack(pack);
    client = ReadPackCell(pack);
    hWaitTimer[client] = INVALID_HANDLE;

    TFClassType playerClass = TF2_GetPlayerDisguiseClass(client);
    TF2Attrib_AddCustomPlayerAttribute(client, "cannot disguise", 1.0, g_flDisguiseTimer);
    TF2_RemoveCondition(client, TFCond_Disguised);

    switch(playerClass)
    {
        case TFClass_Scout:
        {
            PrintToChat(client, "You disguised as Scout, you are slightly Faster!");
            TF2Attrib_AddCustomPlayerAttribute(client, "air dash count", 1.0, g_flEffectDuration);  //supposed to increase jumps, doesnt work
            TF2Attrib_AddCustomPlayerAttribute(client, "move speed bonus", 1.20, g_flEffectDuration); //speed 20% increase
        }
        case TFClass_Sniper:
        {
            PrintToChat(client, "You disguised as Sniper, your Guns have Increased Accuracy and Damage!");
            TF2Attrib_AddCustomPlayerAttribute(client, "weapon spread bonus", 0.10, g_flEffectDuration); //90% increase accuracy
            TF2Attrib_AddCustomPlayerAttribute(client, "damage bonus", 1.25, g_flEffectDuration); //25% damage increase
        }
        case TFClass_Soldier:
        {
            PrintToChat(client, "You disguised as Soldier, have some Health and Blast Res!");
            TF2Attrib_AddCustomPlayerAttribute(client, "dmg taken from blast reduced", 0.85, g_flEffectDuration); //15% less damage from explosives
            TF2Attrib_AddCustomPlayerAttribute(client, "hidden maxhealth non buffed", 20.0, g_flEffectDuration);  //20% health bon, overheal stays same
        }
        case TFClass_DemoMan:
        {
            PrintToChat(client, "You disguised as Demoman, have some Resistance!");
            TF2Attrib_AddCustomPlayerAttribute(client, "dmg taken from blast reduced", 0.70, g_flEffectDuration); //30% less damage from explosives
            TF2Attrib_AddCustomPlayerAttribute(client, "damage bonus", 1.30, g_flEffectDuration);  //30% damage bon
        }
        case TFClass_Medic:
        {
            PrintToChat(client, "You disguised as Medic, here some Regeneration for you!");
            TF2Attrib_AddCustomPlayerAttribute(client, "health regen", 3.0, g_flEffectDuration); //Medics Health Regen
        }
        case TFClass_Heavy:
        {
            PrintToChat(client, "You disguised as Heavy, Your health was buffed by 50%!");
            TF2Attrib_AddCustomPlayerAttribute(client, "hidden maxhealth non buffed", 50.0, g_flEffectDuration);  //50% health bon, overheal stays same
        }
        case TFClass_Pyro:
        {
            PrintToChat(client, "You disguised as Pyro, Fireresistance increased!");
            TF2Attrib_AddCustomPlayerAttribute(client, "dmg taken from fire reduced", 0.50, g_flEffectDuration); //50% fire res
        }
        case TFClass_Spy:
        {
            PrintToChat(client, "You disguised as Spy, there are no Abilities for you.");
        }
        case TFClass_Engineer:
        {
            PrintToChat(client, "You disguised as Engineer, firerate and health slightly!");
            TF2Attrib_AddCustomPlayerAttribute(client, "fire rate bonus", 0.85, g_flEffectDuration);            //15% firerate bon
            TF2Attrib_AddCustomPlayerAttribute(client, "hidden maxhealth non buffed", 15.0, g_flEffectDuration);  //15% health bon
        }
    }
    return Plugin_Continue;
}


/***************[VALIDITY CHECKS]***************/

bool IsValidClient(int client, bool replaycheck = true) //checks client validity
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