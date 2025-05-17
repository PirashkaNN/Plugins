/* Adaptation in CS:GO (CS2) */

#include <base/amxmodx>
#include <base/reapi>

#include <raws>

new const plugin_name[]                 = "Bonus Guns";
new const plugin_version[]              = "1.0";
new const plugin_author[]               = "ISellGarage";

new const plugin_default_folder[]       = "RAWS";
new const plugin_configuration[]        = "BonusGuns.ini";
new Array:plugin_configuration_array    = Invalid_Array;

const max_weapons                       = 11;

const TASKID_ACTIVE_EVENT               = 59321;
const TASKID_TIMER_EVENT                = 59322;

/* pointer_cvar, cvar_value */
new pcvar_reward_health, Float:cvar_reward_health;
new pcvar_reward_armor, Float:cvar_reward_armor;
new pcvar_reward_money, cvar_reward_money;
new pcvar_time_repeat, Float:cvar_time_repeat;
new pcvar_event_time, cvar_event_time;
new pcvar_list_weapon, Array:list_weapon;
new pcvar_list_weapon_names, Array:list_weapon_names;

new event_active                        = 0; //Активен ли ивент
new event_timer                         = 0; //Длительность ивента
new event_weapon                        = 0; //Какое оружие будет использоваться в ивенте
new event_bonus                         = 0; //Какая награда при убийстве с бонусного оружия

new event_message_up[128]               = EOS; //Сообщение, первая часть
new event_message_down[128]             = EOS; //Сообщение, вторая часть

new user_event_weapon[33]               = 0; //Игрок использует бонусное оружие?

public plugin_precache()
{
	plugin_configuration_array = ArrayCreate(512, 512);

	list_weapon = ArrayCreate(64, 64);
	list_weapon_names = ArrayCreate(64, 64);

	new path[LEN_MAX_PATH];
	raws_create_folder(plugin_default_folder);

	formatex(path, charsmax(path), "%s/%s/%s", amxx_folder_base, plugin_default_folder, plugin_configuration);

	CreateCvars();
	raws_create_file(path, plugin_configuration_array);
	LoadCvars();
}

public plugin_init()
{
	register_plugin(plugin_name, plugin_version, plugin_author);
	plugin_notification(plugin_name, plugin_version, plugin_author);

	RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed", true);

	register_clcmd("drop", "_CmdHookDrop");

	set_task(cvar_time_repeat, "task_create_event", TASKID_ACTIVE_EVENT);
}

public task_create_event()
{
	if(event_active) //Ивент уже проходит, повторим 
	{
		remove_task(TASKID_ACTIVE_EVENT);
		return PLUGIN_HANDLED;
	}

	if(task_exists(TASKID_TIMER_EVENT))
	{
		remove_task(TASKID_TIMER_EVENT);
		return PLUGIN_HANDLED;
	}

	if(list_weapon == Invalid_Array)
	{
		return PLUGIN_HANDLED;
	}

	new array_size = ArraySize(list_weapon_names);
	event_weapon = random(array_size);
	event_bonus = random_num(1, 3);

	event_timer = cvar_event_time;

	event_active = 1;

	

	set_task(1.0, "task_event_timer", TASKID_TIMER_EVENT, .flags = "b");

	return PLUGIN_CONTINUE;
}

public task_event_timer()
{
	if(event_timer <= 0)
	{
		event_active = 0;
	
		remove_task(TASKID_TIMER_EVENT);

		set_task(cvar_time_repeat, "task_create_event", TASKID_ACTIVE_EVENT);
		return PLUGIN_CONTINUE;
	}

	event_timer -= 1;

	new weapon_name[64];
	ArrayGetString(list_weapon_names, event_weapon, weapon_name, charsmax(weapon_name));

	formatex(event_message_up, charsmax(event_message_up), "Доступно бонусное оружие!^nВ этот раз выпал: %s", weapon_name)
	formatex(event_message_down, charsmax(event_message_down), "Чтобы использовать нажмите: ^4[G]^nОсталось времени: %dс", event_timer);
		
	set_hudmessage(250, 100, 0, -0.98, -0.66, 0, 6.00, 1.00, 0.20, 0.60);
	show_hudmessage(0, event_message_up);

	set_hudmessage(250, 100, 0, -0.98, -0.62, 0, 6.00, 1.00, 0.20, 0.60);
	show_hudmessage(0, event_message_down);

	return PLUGIN_HANDLED;
}

public _CmdHookDrop(id)
{
	if(!is_user_Alive(id))
	{
		return PLUGIN_HANDLED;
	}
	
	if(!event_active)
	{
		return PLUGIN_CONTINUE;
	}

	if(list_weapon == Invalid_Array)
	{
		return PLUGIN_CONTINUE;
	}

	user_event_weapon[id] = 1;
	
	static string[64];

	if(ArrayGetString(list_weapon, event_weapon, string, charsmax(string)))
	{
		rg_give_custom_item(id, string, GT_REPLACE );
	}

	return PLUGIN_HANDLED;
}

@CBasePlayer_Killed(const victim, const attacker, gib)
{
	if(!is_user_connected(victim))
	{
		return HC_CONTINUE;
	}

	if(!event_active)
	{
		return HC_CONTINUE;
	}

	if(!user_event_weapon[attacker])
	{
		return HC_CONTINUE;
	}

	if(user_event_weapon[attacker])
	{
		/* Again use button <<G>> */
		user_event_weapon[victim] = 0;
	}

	switch(event_bonus)
	{
		case 1:
		{
			set_entvar(attacker, var_health, Float:get_entvar(attacker, var_health) + cvar_reward_health);
		}
		case 2:
		{
			set_entvar(attacker, var_armorvalue, Float:get_entvar(attacker, var_armorvalue) + cvar_reward_armor);
		}
		case 3:
		{
			rg_add_account(attacker, cvar_reward_money);
		}
	}

	return HC_CONTINUE;
}

CreateCvars()
{
	pcvar_event_time	= raws_create_cvar(plugin_configuration_array, "bg_time_event", "30", _, "Время ивента бонусного оружия");
	pcvar_time_repeat	= raws_create_cvar(plugin_configuration_array, "bg_time_repeat", "60.0", _, "Через сколько ивент будет появляться от окончания прошлого");

	pcvar_reward_health = raws_create_cvar(plugin_configuration_array, "bg_reward_health", "5.0", _, "Сколько здоровья прибавлять при использовании бонусного оружия");
	pcvar_reward_armor  = raws_create_cvar(plugin_configuration_array, "bg_reward_armor", "15.0", _, "Сколько брони прибавлять при использовании бонусного оружия");
	pcvar_reward_money  = raws_create_cvar(plugin_configuration_array, "bg_reward_money", "50", _, "Сколько денег давать при использовании бонусного оружия");

	pcvar_list_weapon = raws_create_cvar(plugin_configuration_array, "bg_list_guns", "weapon_aug, weapong_galil, weapon_famas, weapon_mp5navy, weapon_m249, weapon_tmp, weapon_ump45, weapon_p90, weapon_awp, weapon_m4a1, weapon_ak47", 0, "Список оружия");

	pcvar_list_weapon_names = raws_create_cvar(plugin_configuration_array, "bg_list_guns_names", "AUG, GALIL, FAMAS, MP5, M249, TMP, UMP45, P90, AWP, M4A1, AK47", 0, "Список названий оружия");
}

LoadCvars()
{
	cvar_time_repeat 	= get_pcvar_float(pcvar_time_repeat);
	cvar_event_time  	= get_pcvar_num(pcvar_event_time);
	cvar_reward_health 	= get_pcvar_float(pcvar_reward_health);
	cvar_reward_armor 	= get_pcvar_float(pcvar_reward_armor);
	cvar_reward_money 	= get_pcvar_num(pcvar_reward_money);


	new i, cvar_value[256], left_part[256];
	
	i = 0;
	get_pcvar_string(pcvar_list_weapon, cvar_value, charsmax(cvar_value));
	while(!is_str_empty(cvar_value) && i < max_weapons)
	{
		strtok(cvar_value, left_part, charsmax(left_part), cvar_value, charsmax(cvar_value), ',', 0);
		trim(left_part);
		ArrayPushString(list_weapon, left_part);
		i++;
	}

	i = 0;
	get_pcvar_string(pcvar_list_weapon_names, cvar_value, charsmax(cvar_value));
	while(!is_str_empty(cvar_value) && i < max_weapons)
	{
		strtok(cvar_value, left_part, charsmax(left_part), cvar_value, charsmax(cvar_value), ',', 0);
		trim(left_part);
		ArrayPushString(list_weapon_names, left_part);
		i++;
	}
}