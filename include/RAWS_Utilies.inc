/**
 * Получает координаты по прицелу
 *
 * @param index					id клиента
 * @param origin				массив для записи
 *
 * @return						1 - удачно
 */
/* stock fm_get_aim_origin(index, Float:origin[3]) {
	new Float:start[3], Float:view_ofs[3];
	get_entvar(index, var_origin, start);
	get_entvar(index, var_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);

	new Float:dest[3];
	get_entvar(index, var_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);

	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);

	return 1;
} */

/**
 * Устанавливает тип рендера ... .... ....
 *
 * @param pEntity				id клиента
 * @param fx					массив для записи
 *
 * @return						1 - удачно
 */
stock set_user_rendering(const pEntity, const fx = kRenderFxNone, const Float:flColor[] = {0.0, 0.0, 0.0}, const render = kRenderNormal, const Float:iAmount = 0.0)
{
	set_entvar(pEntity, var_renderfx, fx);
	set_entvar(pEntity, var_rendermode, render);
	set_entvar(pEntity, var_rendercolor, flColor);
	set_entvar(pEntity, var_renderamt, iAmount);
}

/**
 * Устанавливает тип рендера ... .... ....
 *
 * @param pEntity				id клиента
 * @param fx					массив для записи
 *
 * @return						1 - удачно
 */
stock set_user_health(const id, Float:health, method)
{
	switch(method)
	{
		case VC_ADD:
		{
			set_entvar(id, var_health, Float:get_entvar(id, var_health) + health);
		}
		case VC_TAKE:
		{
			set_entvar(id, var_health, Float:get_entvar(id, var_health) - health);
		}
		case VC_SET:
		{
			set_entvar(id, var_health, health);
		}
		//Roflan ebalo
		/* case MULT:
		{
			set_entvar(id, var_health, Float:get_entvar(id, var_health * health));
		} */
	}
}

stock Float:get_user_health(const id)
{
	return get_entvar(id, var_health);
}

stock set_user_money(const id, money = 0, method = VC_ADD)
{
	switch(method)
	{
		case VC_ADD:
		{
			rg_add_account(id, money, AS_ADD);
		}
		case VC_TAKE:
		{
			rg_add_account(id, -money, AS_ADD);
		}
		case VC_SET:
		{
			rg_add_account(id, money, AS_SET);
		}
		//Roflan ebalo
		/* case MULT:
		{
			set_entvar(id, var_health, Float:get_entvar(id, var_health * health));
		} */
	}

	return 1;
}

stock get_user_money(const id)
{
	return get_member(id, m_iAccount);
}

/**
 * Проверка на убийство в голову
 *
 * @param id				id клиента
 *
 * @return					0 - не в голову, 1 - в голову
 */
stock is_headshot(const id)
{
	return get_member(id, m_bHeadshotKilled)
}

/**
 * Конвертирует время в минуты и часы.
 *
 * @param time				переменная с временем
 * @param convert_type		В какое время конвертируем
 *
 * @return					time
 */
stock time_convert(const time, const TIME_NAMES:convert_type)
{
	new convert, temp_time;

	temp_time = time;

	switch(convert_type)
	{
		case MINUTES:
		{
			convert = 60;
		}
		case HOURS:
		{
			convert = 3600;
		}
	}

	temp_time = temp_time / convert;

	return temp_time;
}

stock register_clcmds(array[][], function[], flag, description[])
{
	for(new i; i < array_size - 1; i++)
	{
		register_clcmd(array[i], function, flag, description);
	}
}
