enum _:ENTITY_DATA
{
    ED_ID,
    ED_OWNER,
    ED_LEVEL,
    ED_UPGRADER_1,
    ED_UPGRADER_2,
    ED_UPGRADER_3,
}


const max_build_entity = 1023;


stock entity_data[max_build_entity][ENTITY_DATA];

stock create_entity_ex(const classname[], const Float:origin[WORLD_POSITION], model[LEN_MAX_PATH], model_index, Float:size[BOUNDS][WORLD_POSITION], const solid = SOLID_NOT, const movetype = MOVETYPE_NONE)
{
    new entity = rg_create_entity("func_breakable");
	
	if(!entity)
	{
		return 0;
	}

	set_entvar(entity, var_classname, classname);	
	set_entvar(entity, var_origin, origin);
	set_entvar(entity, var_solid, solid);
	set_entvar(entity, var_movetype, movetype);
    set_entvar(entity, var_model, model);
	set_entvar(entity, var_modelindex, model_index);
	entity_set_size(entity, size[MIN], size[MAX]);

	return entity;
}

stock set_entity_id(const entity, id = 0)
{
    entity_data[entity][ED_ID] = id;
}

stock set_entity_owner(const entity, owner = 0)
{
    entity_data[entity][ED_OWNER] = owner;
}

stock set_entity_upgrader(const entity, upgrader = 0)
{
    entity_data[entity][ED_UPGRADER_1] = upgrader;
}

stock set_entity_upgrader_1(const entity, upgrader = 0)
{
    entity_data[entity][ED_UPGRADER_2] = upgrader;
}

stock set_entity_upgrader_2(const entity, upgrader = 0)
{
    entity_data[entity][ED_UPGRADER_3] = upgrader;
}

stock set_entity_level(const entity, level = 0)
{
    entity_data[entity][ED_LEVEL] = level;
}

stock set_entity_team(const entity, team)
{
    set_entvar(entity, var_team, team);
}

stock set_entity_target(const entity, target_id = 0)
{
	if(!is_user_alive(target_id))
	{
		return 0;
	}

	set_entvar(entity, var_enemy, target_id);

    return 1;
}

stock get_entity_owner(const entity)
{
    return entity_data[entity][ED_OWNER];
}

stock get_entity_upgrader(const entity)
{
    return entity_data[entity][ED_UPGRADER_1];
}

stock get_entity_upgrader_2(const entity)
{
    return entity_data[entity][ED_UPGRADER_2];
}

stock get_entity_upgrader_3(const entity)
{
    return entity_data[entity][ED_UPGRADER_3];
}

stock get_entity_level(const entity)
{
    return entity_data[entity][ED_LEVEL];
}

stock get_entity_team(const entity)
{
    return get_entvar(entity, var_team);
}

stock get_entity_target(const entity)
{
    return get_entvar(entity, var_enemy);
}

stock delete_entity(const entity)
{
    if(!is_entity(entity))
	{
		remove_entity(entity);
	}
	
	set_entvar(entity, var_flags, get_entvar(entity, var_flags) | FL_KILLME);
	set_entvar(entity, var_nextthink, 0.01);

    return 1;
}

stock delete_entity_by_classname(const classname[])
{
    new entity = NULLENT;
    static search_entity;

    while( (entity = rg_find_ent_by_class(entity, classname)) != 0)
    {
        delete_entity(entity);
    }
}

