#include <base/amxmodx>
#include <base/reapi>

#include <raws>

//Plugin created: 23 Май 2025 (12:34:31)
stock const plugin_name[]					= "Switch Spectator";
stock const plugin_version[]				= "1.0";
stock const plugin_author[]					= "ISellGarage";

stock const cmds_ss[][] = {"say /spec", "say /spectator"};

public plugin_init()
{
    register_plugin(plugin_name, plugin_version, plugin_author);

    register_clcmd("say /spec", "_CmdSwitchSpectator");
    register_clcmd("say /spectator", "_CmdSwitchSpectator");
}

public _CmdSwitchSpectator(const id)
{
    switch_spectator(id);

    return PLUGIN_HANDLED;
}

stock switch_spectator(const id)
{
    new team = get_member(id, m_iTeam);

    if(is_user_alive(id))
    {
        user_silentkill(id);
    }

    switch(team)
    {
        case TEAM_SPECTATOR:
        {
            new team_random = random_num(1, 2);
            rg_set_user_team(id, team_random, MODEL_AUTO, true, true);

            rg_round_respawn(id);
        }
        case TEAM_TERRORIST..TEAM_CT:
        {
            rg_set_user_team(id, TEAM_SPECTATOR, MODEL_AUTO, true, true);
        }
    }

    return 1;
}