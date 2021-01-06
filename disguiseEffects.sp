#include <sourcemod>
#include <sdktools>
#include <tf2condhooks>
#include <dhooks>
#include <tf2attributes>
#include <tf2_stocks>
#include <stocksoup/tf/entity_prop_stocks>
#include <rtd2>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION		"1.0.0"

/*
Scout: Triple Jump
Sniper: GunDamage and accuracy increase (both 25%)
Solly: 20 hp more health + Explosion Res (less than demo) 15%
Demo: Explosive Shots + Explosion Res (25%)
Medic: Health Regen (2hp per sec)
Heavy: 50 hp more health
Pyro: Gun deals Firedamage (like ignition) + Fire res (25%)
Spy: Invisiblity + Can attack but no backstabs
Engineer: Increased FIrerate (15%) + 10 more hp
*/


Handle  g_cvEnableDisguiseEffects;
Handle  g_cvDisguiseCooldown;
Handle  g_cvEffectDuration;
Handle  hWaitTimer[MAXPLAYERS+1];
float   g_flDisguiseTimer                   = 30.0;
float   g_flEffectDuration                  = 10.0;
bool    g_bEffectsEnabled                   = true;


public Plugin myinfo = 
{
    name        = "disguised Effects",
    author      = "Samm-Cheese#9500",
    description = "Allows the Disguisekit to have various effects",
    version     = PLUGIN_VERSION,
    url         = "http://alliedmods.net"
}

public void OnPluginStart()
{
    CreateConVar(
        "sm_disguiseeffects_version", PLUGIN_VERSION,
        "Disguise Effects Version", 
        FCVAR_NOTIFY
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

    g_flEffectDuration      = GetConVarFloat(g_cvEffectDuration);
    g_bEffectsEnabled       = GetConVarBool(g_cvEnableDisguiseEffects);
    g_flDisguiseTimer       = GetConVarFloat(g_cvDisguiseCooldown);
    
}

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

public Action TF2_OnAddCond(int client, TFCond &cond, float &time, int &provider)
{
    if (IsValidClient(client))
    {
        if (g_bEffectsEnabled)
        {
            if (cond == TFCond_Disguised)
            {
                float wait = 0.2;
                Handle pack;
                hWaitTimer[client] = CreateDataTimer(wait, searchAndExec, pack);
                WritePackCell(pack, client);
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
    //TFTeam      playerTeam  = TF2_GetClientDisguiseTeam(client);
    TF2Attrib_AddCustomPlayerAttribute(client, "cannot disguise", 1.0, g_flDisguiseTimer);

    switch(playerClass)
    {
        case TFClass_Scout:
        {
            PrintToChat(client, "You disguised as Scout!");
            TF2Attrib_AddCustomPlayerAttribute(client, "air dash count", 1.0, g_flEffectDuration);
        }
        case TFClass_Sniper:
        {
            PrintToChat(client, "You disguised as Sniper!");
        }
        case TFClass_Soldier:
        {
            PrintToChat(client, "You disguised as Soldier!");
        }
        case TFClass_DemoMan:
        {
            PrintToChat(client, "You disguised as Demoman!");
        }
        case TFClass_Medic:
        {
            PrintToChat(client, "You disguised as Medic!");
        }
        case TFClass_Heavy:
        {
            PrintToChat(client, "You disguised as Heavy!");
        }
        case TFClass_Pyro:
        {
            PrintToChat(client, "You disguised as Pyro!");
        }
        case TFClass_Spy:
        {
            PrintToChat(client, "You disguised as Spy!");
        }
        case TFClass_Engineer:
        {
            PrintToChat(client, "You disguised as Engineer!");
        }
        default:
        {
            PrintToChat(client, "Invalid Disguise");
        }
    }
}



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