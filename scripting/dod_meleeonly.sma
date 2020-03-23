#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <dodfun>
#include <dodx>

#define WPN_LINUX_DIFF 4
#define MAX_PLAYERS 32

new g_pCvarMeleeOnly

public plugin_init()
{
	register_plugin("Melee Only", "0.1", "Fysiks")
	
	register_clcmd("say ammo", "stripBullets")
	g_pCvarMeleeOnly = register_cvar("melee_only_enable", "1")
	set_pcvar_num(g_pCvarMeleeOnly, 1) // Force the melee to be enabled at the begining of the map
	RegisterHam(Ham_Spawn,"player","ham_player_spawn",1)
}

public ham_player_spawn(id)
{
	if( is_user_alive(id) && get_pcvar_num(g_pCvarMeleeOnly) )
	{
		stripBullets(id)
		set_task(0.5, "stripBullets", id)
	}
}

public stripBullets(id)
{
	new iWeaponIDs[32], iWeaponsNum, wEnt, wpnid
	
	get_user_weapons(id, iWeaponIDs, iWeaponsNum)
	
	for( new i = 0; i < iWeaponsNum; i++ )
	{
		wpnid = iWeaponIDs[i]
		switch( wpnid )
		{
			case DODW_GARAND_BUTT, DODW_K43_BUTT, DODW_KAR_BAYONET, DODW_AMERKNIFE, DODW_BRITKNIFE, DODW_GERKNIFE, DODW_SPADE, DODW_ENFIELD_BAYONET, DODW_HANDGRENADE, DODW_STICKGRENADE, DODW_STICKGRENADE_EX, DODW_HANDGRENADE_EX, DODW_MILLS_BOMB, DODW_BAZOOKA, DODW_PANZERSCHRECK, DODW_PIAT:
			{
				// Do nothing
			}
			default:
			{
				set_user_bpammo(id, wpnid, 0)
				wEnt = get_weapon_ent(id, wpnid)
				if(pev_valid(wEnt))
				{
					dod_set_weapon_ammo(wEnt, 0)
				}
			}
		}
	}
}

// sets clip ammo, offset thanks to Wilson [29th ID]
stock dod_set_weapon_ammo(index,newammo)
{
	return set_pdata_int(index, 108, newammo, WPN_LINUX_DIFF);
}

stock set_user_bpammo(id, weapon, ammo)
{
	return dod_set_user_ammo(id, weapon, ammo);
}

 // find a player's weapon entity
stock get_weapon_ent(id, wpnid=0, wpnName[]="")
{
	// who knows what wpnName will be
	static newName[24];

	// need to find the name
	if(wpnid) dod_get_weaponname(wpnid, newName, 23);

	// go with what we were told
	else formatex(newName, 23, "%s", wpnName);

	// prefix it if we need to
	if(!equal(newName, "weapon_",7))
		format(newName, 23, "weapon_%s", newName);

	return fm_find_ent_by_owner(MAX_PLAYERS, newName, id);
}

// DoD has fancy weapon names.
stock dod_get_weaponname(weapon,ret[],retLen)
{
	if(weapon < 1 || weapon > 41)
	 return 0;

	static logName[24];
	xmod_get_wpnlogname(weapon,logName,23);

	if(equal(logName,"grenade")) logName = "handgrenade";
	else if(equal(logName,"grenade2")) logName = "stickgrenade";
	else if(equal(logName,"scoped_fg42")) logName = "fg42";
	else if(equal(logName,"fcarbine")) logName = "m1carbine";
	else if(equal(logName,"scoped_enfield")) logName = "enfield";
	else if(equal(logName,"brit_knife")) logName = "amerknife";

	return formatex(ret,retLen,"weapon_%s",logName);
}

