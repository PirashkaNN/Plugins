#include <base/amxmodx>
#include <base/fakemeta>
#include <base/hamsandwich>
#include <base/engine>
#include <base/reapi>

#include <raws>

#define DISPENSER_CUSTOM_MAX_HEALTH		//Использовать свойство var_max_health у игрока
#define SET_DEFAULT_VIP					//Чисто тег для разработки (Постоянный VIP раздатчик)

new const plugin_name[]                 = "Dispenser";
new const plugin_version[]              = "0.9";
new const plugin_author[]               = "ISellGarage";

const Float:DISPENSER_TRACELINE_UPDATE		= 0.5;
const Float:DISPENSER_RADIUS				= 2000.0;
const Float:DISPENSER_HEAL					= 1.0;
const Float:DISPENSER_UPDATE_HEAL			= 0.1;
const Float:DISPENSER_TOUCH_UPDATE			= 0.5;

new const dispenser_classname[]         	= "Dispenser";

new const dispenser_model[]             	= "models/Plugins/Dispenser/DispenserChanged.mdl";

new const dispenser_active_snd[]			= "RAWS/Dispenser/Active.wav";
new const dispenser_build_snd[]				= "RAWS/Dispenser/Building.wav";
new const dispenser_explode_snd[]			= "RAWS/Dispenser/Explode.wav";

new const dispenser_healing_spr[]			= "sprites/RAWS/Dispenser/Healing.spr";
new const dispenser_particles_spr[]			= "sprites/RAWS/Dispenser/Particles.spr";
new const dispenser_explode_spr[]			= "sprites/RAWS/Dispenser/Explode.spr";

const TASKID_BUILD_TIMER                = 472381;

const dispenser_max_obj                 = 1200;
const dispenser_max                     = 3;
const dispenser_max_level               = 3;

enum _:DISPENSER_LEVELS
{
	DISPENSER_LEVEL_1,
	DISPENSER_LEVEL_2,
	DISPENSER_LEVEL_3,
};

new maxplayers;

new dispenser_model_id;
new dispenser_healing_sprite_id;
new dispenser_explode_sprite_id;
new dispenser_particles_sprite_id;

new dispenser_time_build									= 10;
new dispenser_cost[dispenser_max] 							= {1, 2, 3};
new dispenser_upgrade_cost[dispenser_max_level] 			= {10, 20, 30};
new dispenser_destroy_reward								= 2500;
new Float:dispenser_health[dispenser_max_level] 			= {1000.0, 2000.0, 3000.0};
new Float:dispenser_vip_health[dispenser_max_level]			= {150.0, 250.0, 500.0};
new Float:dispenser_heal_value[dispenser_max_level] 		= {1.0, 2.0, 3.0};
new Float:dispenser_heal_time[dispenser_max_level] 			= {1.0, 0.5, 0.25};
new Float:dispenser_radius_heal[dispenser_max_level]		= {1000.0, 2000.0, 3000.0};

#if defined DISPENSER_CUSTOM_MAX_HEALTH
	new Float:dispenser_max_health[dispenser_max_level]		= {100.0, 200.0, 300.0};
#endif

new user_build_entity[33]               = 0;

new user_quantity[33];

/* Последствия ночных работ 00:31 */
stock set_building(const id, value) 						{ user_build_entity[id] = value; 									}
stock set_team_dispenser(const entity, team) 				{ set_entvar(entity, var_team, team);								}
stock set_owner_dispenser(const entity, const id) 			{ set_entvar(entity, var_iuser1, id);								}
stock set_level_dispenser(const entity, level) 				{ set_entvar(entity, var_iuser2, level);							}
stock set_building_time(const entity, time) 				{ set_entvar(entity, var_iuser3, time); 							}
stock set_ability_dispenser(const entity, ability)			{ set_entvar(entity, var_iuser4, ability); 							}
stock set_upgrader_dispenser_1(const entity, upgrader)		{ get_entvar(entity, var_euser1);									}
stock set_upgrader_dispenser_2(const entity, upgrader)		{ get_entvar(entity, var_euser2);									}
stock set_upgrader_dispenser_3(const entity, upgrader)		{ get_entvar(entity, var_euser3);									}
stock set_upgrader_dispenser_4(const entity, upgrader)		{ get_entvar(entity, var_euser4);									}
stock set_vip_dispenser(const entity, bVip)					{ get_entvar(entity, var_bInDuck, bVip);							}
/*------------------------------------------------------------------------------------------------------------------------------- */
stock get_building(const id) 								{ return user_build_entity[id]; 									}
stock get_team_dispenser(const entity) 						{ return get_entvar(entity, var_team); 								}
stock get_owner_dispenser(const entity) 					{ return get_entvar(entity, var_iuser1);							}
stock get_level_dispenser(const entity) 					{ return get_entvar(entity, var_iuser2);  							}
stock get_build_time(const entity) 							{ return get_entvar(entity, var_iuser3);							}
stock get_ability_dispenser(const entity)					{ return get_entvar(entity, var_iuser4); 							}
stock get_upgrader_dispenser_1(const entity)				{ return get_entvar(entity, var_euser1);							}
stock get_upgrader_dispenser_2(const entity)				{ return get_entvar(entity, var_euser2);							}
stock get_upgrader_dispenser_3(const entity)				{ return get_entvar(entity, var_euser3);							}
stock get_upgrader_dispenser_4(const entity)				{ return get_entvar(entity, var_euser4);							}
stock get_vip_dispenser(const entity)						{ return get_entvar(entity, var_bInDuck);							}



public plugin_precache()
{
	dispenser_model_id = precache_model_ex(dispenser_model);

	precache_sound(dispenser_active_snd);
	precache_sound(dispenser_explode_snd);
	precache_sound(dispenser_build_snd);

	dispenser_healing_sprite_id = precache_model_ex(dispenser_healing_spr);
	dispenser_explode_sprite_id = precache_model_ex(dispenser_explode_spr);
	dispenser_particles_sprite_id = precache_model_ex(dispenser_particles_spr);
}

public plugin_init()
{
	register_plugin(plugin_name, plugin_version, plugin_author);
	plugin_notification(plugin_name, plugin_version, plugin_author);

	maxplayers = get_maxplayers();


	register_forward ( FM_TraceLine, "DispenserTraceline", 1);

	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed", true);
	RegisterHam(Ham_TakeDamage, classname_breakable, "@HamTakeDamage", false); //Событие получения урона (объекты)

	register_clcmd("raws_build_dispenser", "_CmdBuildDispenser");

	/* register_concmd("raws_dispensers", "_CmdDispenserList"); */
}

public _CmdBuildDispenser(id)
{
	new Float:origin[WORLD_POSITION];
	get_entvar(id, var_origin, origin);

	create_dispenser(id, origin);

	return PLUGIN_HANDLED;
}

create_dispenser(const id, Float:origin[WORLD_POSITION] = {0.0, 0.0, 0.0})
{

	origin[2] -= 36.5;
	if(is_origin_null(origin))
	{
		server_print("[%s] Origin is null! (%.1f / %.1f / %.1f)", plugin_name, origin[X], origin[Y], origin[Z])
		return 0;
	}

	new user_dispensers = user_quantity[id];

	if(user_dispensers >= dispenser_max)
	{
		client_print_color(id, print_team_default, "^1[^3%s^1] Количество построенных раздатчиков равно максимуму (%d/%d)", plugin_name, user_dispensers, dispenser_max);
		server_print("[%s] Player %n try create dispenser (max %d/%)", plugin_name, id, user_dispensers, dispenser_max);
		return 0;
	}

	new money = get_member(id, m_iAccount);

	if(money < dispenser_cost[user_dispensers])
	{
		client_print_color(id, print_team_default, "^1[^3%s^1] У вас недостаточно денег (%d$/%d$)", plugin_name, money, dispenser_cost[user_dispensers]);
		server_print("[%s] Player %n try create dispenser (money not have %d$/%d$)", plugin_name, id, money, dispenser_cost[user_dispensers]);
		return 0;
	}

	if(get_building(id))
	{
		client_print_color(id, print_team_default, "^1[^3%s^1] У вас уже строится раздатчик.", plugin_name);
		server_print("[%s] Player %n try create dispenser (building dispenser)", plugin_name, id);
		return 0;
	}

	new entity = rg_create_entity(classname_breakable);

	if( !is_entity(entity) )
	{
		server_print("[%s] Player %n try create dispenser (entity id invalid)", plugin_name, id);
		return 0;
	}

	new team = get_member(id, m_iTeam);
	new tt = 3;
	new ct = 0;

	set_entvar(entity, var_solid, SOLID_NOT);
	set_entvar(entity, var_modelindex, dispenser_model_id);
	entity_set_model(entity, dispenser_model);
	entity_set_size(entity, Float:{-16.0, -32.0, -5.0}, Float: {16.0, 32.0, 43.0}) //fix sizes after sets solid

	set_entvar(entity, var_body, team == 1 ? tt : ct)
 	set_entvar(entity, var_origin, origin);
	
	set_entvar(entity, var_movetype, MOVETYPE_TOSS );
	set_entvar(entity, var_takedamage, DAMAGE_NO );

	set_rendering(entity, kRenderFxDistort, 0,0,0 , kRenderTransAdd, 70);

	set_owner_dispenser(entity, id);
	set_team_dispenser(entity, team);
	set_level_dispenser(entity, 0);

	rg_add_account(id, money - dispenser_cost[user_dispensers], AS_SET);

	SetThink(entity, "@DispenserThink");
	SetTouch(entity, "@DispenserTouch");
	set_entvar(entity, var_nextthink, get_gametime() + 0.1);

	set_user_building(id, entity);

	rh_emit_sound2(entity, 0, CHAN_AUTO, dispenser_build_snd);

	return 1;
}

@DispenserThink(const entity)
{
	if(!is_entity(entity))
	{
		server_print("[%s] Entity destroy! (Entity id %d)", plugin_name, entity);
		DispenserDestroy(entity);
		return HC_CONTINUE;
	}

	/* Проверка на строится */
	if(task_exists(TASKID_BUILD_TIMER))
	{
		set_entvar(entity, var_nextthink, get_gametime() + 1.0);
		return HC_CONTINUE;
	}

	new owner, team/* , Float:max_health */;
	static level, Float:health;

	owner = get_owner_dispenser(entity);

	if(!is_user_connected(owner))
	{
		server_print("[%s] Owner %n dead! Dispenser destroy", plugin_name, owner);
		DispenserDestroy(entity);
		return HC_CONTINUE;
	}

	health = get_entvar(entity, var_health);

	if(health < 0.0)
	{
		DispenserDestroy(entity);
		return HC_CONTINUE;
	}

	level = get_level_dispenser(entity);
	team = get_team_dispenser(entity);

	static target, target_team;
	static Float:entity_origin[3], Float:target_origin[3], Float:target_health, Float:target_max_health;
	static Float:distance;
	static Float:temp_heal_time;

	get_entvar(entity, var_origin, entity_origin);

	for(target = 1; target < maxplayers; target++)
	{
		if(!is_user_alive(target))
		{
			continue;
		}

		target_team = get_member(target, m_iTeam);

		if(target_team != team)
		{
			continue;
		}

		get_entvar(target, var_origin, target_origin);

		distance = get_distance_f(entity_origin, target_origin);

		if( (distance > dispenser_radius_heal[level]))
		{
			continue;
		}

		if(!is_visible(entity, target))
		{
			continue;
		}

		if(temp_heal_time > get_gametime())
		{
			continue;
		}

		get_entvar(target, var_health, target_health);

#if defined DISPENSER_CUSTOM_MAX_HEALTH
	target_max_health = dispenser_max_health[level];
#else
	get_entvar(target, var_max_health, target_max_health);	
#endif

		if(target_health < target_max_health)
		{
			
			set_entvar(target, var_health, target_health + dispenser_heal_value[level]);
			temp_heal_time = get_gametime() + dispenser_heal_time[level];
			entity_origin[2] += 35.0;
			view_sprite_twopoints(target_origin, entity_origin, dispenser_healing_sprite_id, 5, 2, 1, 60, 0, {0, 200, 0}, 999, 30);
		}
	}

	set_entvar(entity, var_nextthink, get_gametime() + 0.1);

	return HC_CONTINUE;
}

@DispenserTouch(const entity, const toucher)
{
	if(!is_entity(entity))
	{
		return HC_CONTINUE;
	}

	if(!is_user_connected(toucher))
	{
		return HC_CONTINUE;
	}

	static Float:temp_time[33];

	if(temp_time[toucher] > get_gametime())
	{
		return HC_CONTINUE;
	}

	temp_time[toucher] = get_gametime() + DISPENSER_TOUCH_UPDATE;

	new owner = get_owner_dispenser(entity);

	if(!is_user_connected(owner))
	{
		return HC_CONTINUE;
	}

	new team = get_team_dispenser(entity);
	new toucher_team = get_member(toucher, m_iTeam);

	if(toucher_team != team)
	{
		return HC_CONTINUE;
	}

	dispenser_upgrade(entity, toucher, team);

	return HC_CONTINUE;
}

dispenser_upgrade(entity, toucher, team)
{
	new level = get_level_dispenser(entity);
	new next_level = level + 1;

	if(level == dispenser_max_level-1)
	{
		return HC_CONTINUE;
	}

	new money = get_member(toucher, m_iAccount);

	if(money < dispenser_upgrade_cost[level])
	{
		server_print("[%s] Player %n upgrade dispenser (not have %d$)", plugin_name, toucher, dispenser_upgrade_cost[level] - money);
		client_print_color(toucher, print_team_default, "^1[^3%s^1] У вас недостаточно денег! (%d$/%d$)", plugin_name, money, dispenser_upgrade_cost[level]);
		return HC_CONTINUE;
	}

	if(level == dispenser_max_level-1)
	{
		return HC_CONTINUE;
	}

	new bVip = get_vip_dispenser(entity);

	new list_ct[dispenser_max_level] = {1, 2, 3};
	new list_tt[dispenser_max_level] = {4, 5, 6};
	set_entvar(entity, var_body, team == 1 ? list_tt[level] : list_ct[level]);

	set_max_health(entity, dispenser_health[next_level] + bVip ? dispenser_vip_health[next_level] : 0.0, 1);
	/* set_upgrader_dispenser(toucher, entity, level); */

	switch(level)
	{
		case 0:
		{
			set_upgrader_dispenser_1(entity, toucher);
		}
		case 1:
		{
			set_upgrader_dispenser_2(entity, toucher);
		}
		case 2:
		{
			set_upgrader_dispenser_3(entity, toucher);
		}

	}

	rg_add_account(toucher, money - dispenser_upgrade_cost[level], AS_SET)

	set_level_dispenser(entity, next_level);

	return HC_CONTINUE;
}

public DispenserTraceline ( Float:start[3], Float:end[3], conditions, id, trace )
{
	if(!is_user_alive(id))
	{
		return FMRES_IGNORED;
	}

	static hit, Float:temp_time[33];

	if(temp_time[id] > get_gametime())
	{
		return FMRES_IGNORED;
	}

	temp_time[id] = get_gametime() + DISPENSER_TRACELINE_UPDATE;

	hit = get_tr(TR_pHit);

	if(!is_entity(hit))
	{
		return FMRES_IGNORED;
	}

	static classname[32];
	get_entvar(hit, var_classname, classname, charsmax(classname));

	if(!equal(classname, dispenser_classname))
	{
		return FMRES_IGNORED;
	}

	static team, owner, level, Float:health, Float:max_health;

	owner = get_owner_dispenser(hit);

	if(!is_user_connected(owner))
	{
		return FMRES_IGNORED;
	}

	team = get_entvar(hit, var_team);

	if(team != get_member(id, m_iTeam))
	{
		return FMRES_IGNORED;
	}

	health = Float:get_entvar(hit, var_health);
	
	if(health <= 0.0)
	{
		return FMRES_IGNORED;
	}

	max_health = get_entvar(hit, var_max_health);
	level = get_level_dispenser(hit);

	static color[3];
	static message[128];
	static owner_name[32];

	switch(team)
	{
		case 1: color[0] = 150, color[1] = 50, color[2] = 0;
		case 2: color[0] = 0, color[1] = 50, color[2] = 150 ;
	}

	get_user_name(owner, owner_name, charsmax(owner_name));

	formatex(message, charsmax(message), "Раздатчик %s^nЗдоровье: %.1f/%.1f^nУровень: %d %s", owner_name, health, max_health, level+1, level == dispenser_max_level-1 ? "Max level" : fmt("%d$", dispenser_upgrade_cost[level]) );

	set_dhudmessage ( 150, 50, 0, -1.0, 0.35, 0, 0.0, 0.55, 0.0, 0.0 )
	show_dhudmessage ( id, message);
	return FMRES_IGNORED;
}

@CBasePlayer_Killed(const victim, const attacker, iGib)
{
	if(user_quantity[victim])
	{
		DispenserDestroyAll(victim);
	}
}

@HamTakeDamage(const victim, const inflictor, attacker, Float:damage, dmgBits)
{
	if(!is_entity(victim) || !is_user_connected(attacker))
	{
		return HAM_IGNORED;
	}

	if(FClassnameIs(victim, dispenser_classname))
	{
		new Float:health = get_entvar(victim, var_health);
		new Float:health_damaged = health - damage;

		new owner = get_owner_dispenser(victim);

		new Float:origin[WORLD_POSITION];
		get_entvar(victim, var_origin, origin);

		create_sprite_particles(dispenser_particles_sprite_id, origin);

		if(health_damaged <= 0.0)
		{
			if(attacker == owner)
			{
				return HAM_IGNORED;
			}

			rg_add_account(attacker, dispenser_destroy_reward);
			client_print_color(attacker, print_team_default, "^1[^4%s^1] Получено^4 %d$ ^1за уничтожение раздатчика", plugin_name, dispenser_destroy_reward);
			client_print_color(owner, print_team_default, "^1[^4%s^1] ^1Ваш раздатчик был уничтожен!", plugin_name);

			DispenserDestroy(victim);
		}

	}

	return HAM_IGNORED;
}

stock set_user_building(const creator, const entity)
{
	set_building_time(entity, dispenser_time_build);

	rg_send_bartime(creator, dispenser_time_build);

	set_building(creator, 1);

	new data[2];
	data[0] = creator;
	data[1] = entity;

	set_task(1.0, "task_dispenser_build", TASKID_BUILD_TIMER, data, 2, .flags = "b");
}

public task_dispenser_build(data[])
{
	new owner, entity;

	owner = data[0];
	entity = data[1];

	static temp_time;

	temp_time = get_build_time(entity);

	if(!is_entity(entity))
	{
		server_print("[%s] Dispenser build stopped (entity not valid)", plugin_name);

		set_building(owner, 0);
		set_building_time(entity, 0);
		DispenserDestroy(entity);

		remove_task(TASKID_BUILD_TIMER);
		return PLUGIN_HANDLED;
	}

	if(!is_user_alive(owner))
	{
		server_print("[%s] Dispenser build stopped (owner dead)", plugin_name);

		set_building(owner, 0);
		set_building_time(entity, 0);
		DispenserDestroy(entity);
		remove_task(TASKID_BUILD_TIMER);

		return PLUGIN_HANDLED;
	}

	if(temp_time <= 0)
	{
		set_rendering(entity);

		dispenser_end_build(entity, owner);

		server_print("[%s] Dispenser builded (%n)", plugin_name, owner);
		remove_task(TASKID_BUILD_TIMER);
		return PLUGIN_HANDLED;
	}

	

	temp_time -= 1;
	set_building_time(entity, temp_time);

	server_print("[%s] Dispenser time build %d", plugin_name, temp_time);

	return PLUGIN_HANDLED;
}

stock dispenser_end_build(const entity, const owner)
{
	set_entvar(entity, var_classname, dispenser_classname);

	set_entvar(entity, var_solid, SOLID_SLIDEBOX);
	entity_set_size(entity, Float:{-12.0, -12.0, -5.0}, Float: {12.0, 12.0, 36.0})//fix sizes after sets solid

	//build data
	set_building(owner, 0);
	set_building_time(entity, 0);

#if defined SET_DEFAULT_VIP
	set_vip_dispenser(entity, 1);
#endif

	//dispenser property
	set_owner_dispenser(entity, owner);
	set_level_dispenser(entity, 0);
	set_max_health(entity, dispenser_health[0] + get_vip_dispenser(entity) ? dispenser_vip_health[0] : 0.0, 1)
	set_entvar(entity, var_team, get_member(owner, m_iTeam));
	set_entvar(entity, var_takedamage, DAMAGE_YES );
			
	user_quantity[owner]++;

	rh_emit_sound2(entity, 0, CHAN_AUTO, dispenser_active_snd);

	drop_to_floor(entity);
}

stock DispenserDestroyAll(const id)
{
	static entity = NULLENT;
	while( (entity = find_ent_by_class(entity, dispenser_classname) ) != 0 )
	{
		if(!is_entity(entity))
		{
			continue;
		}

		new owner = get_owner_dispenser(entity);

		if(owner == id )
		{
			DispenserDestroy(entity);
		}
	}
}

stock DispenserDestroy(const entity)
{
	if(!is_entity(entity))
	{
		return 0;
	}

	set_level_dispenser(entity, 0);
	set_owner_dispenser(entity, 0);

	user_quantity[get_owner_dispenser(entity)] -= 1;

	rh_emit_sound2(entity, 0, CHAN_AUTO, dispenser_explode_snd);

	new Float:origin[WORLD_POSITION];
	get_entvar(entity, var_origin, origin);
	origin[1] += 35.0;
	create_sprite_explode(dispenser_explode_sprite_id, origin);

	set_entvar(entity, var_flags, get_entvar( entity, var_flags ) | FL_KILLME);
	return 1;
}