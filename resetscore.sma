#include <base/amxmodx>
#include <base/reapi>

#include <raws>

stock const plugin_name[]               = "Reset Score";
stock const plugin_version[]            = "1.0";
stock const plugin_author[]             = "ISellGarage";

stock const TASKID_SHOW_INFO            = 54222;
stock const resetscore_sound_wav[]      = "sound/buttons/bell1.wav";

new const cmds_rs[][] = {"say /rs", "say rs", "say кы", "say /кы", "raws_resetscore"};

new cvar_sound_effect, sound_effect;
new cvar_show_message, show_message;
new cvar_show_info, show_info;
new cvar_show_info_time, Float:show_info_time;

public plugin_init()
{
    register_plugin(plugin_name, plugin_version, plugin_author);

    for(new i; i < sizeof(cmds_rs); i++)
    {
        register_clcmd(cmds_rs[i], "_CmdResetScore");
    }

    cvar_sound_effect       = create_cvar("rs_sound_effect",    "1",     _, "Use sound effect?");
    cvar_show_message       = create_cvar("rs_show_message",    "1",     _, "Show message reset?");
    cvar_show_info          = create_cvar("rs_show_info",       "1",     _, "Show plugin information");
    cvar_show_info_time     = create_cvar("rs_show_info_time",  "120.0", _,"Time show information");

    sound_effect = get_pcvar_num(cvar_sound_effect);
    show_message = get_pcvar_num(cvar_show_message);
    show_info = get_pcvar_num(cvar_show_info);
    show_info_time = get_pcvar_float(cvar_show_info_time);

    if(show_info)
    {
        set_task(show_info_time, "task_show_info", TASKID_SHOW_INFO, .flags = "b");
    }
}

public task_show_info()
{
    client_print_color(0, print_team_default, "^1[^3%s^1] Вы можете сбросить свой счёт командами:", plugin_name);
    client_print_color(0, print_team_default, "^1[^3%s^1] ^4/rs^1, ^4/resetscore^1, ^4rs ^1и их ошибочными вариантами!", plugin_name);
}

public _CmdResetScore(id)
{
    resetscore(id);
    
    return PLUGIN_HANDLED;
}

stock resetscore(const id)
{
    if(sound_effect)
    {
        client_cmd(id, "spk %s", resetscore_sound_wav);
    }

    set_entvar(id, var_frags, 0.0);
    set_member(id, m_iDeaths, 0);

    message_begin(MSG_BROADCAST, _MSGID_ScoreInfo);
    write_byte(id);
    write_short(0);
    write_short(0);
    write_short(0);
    write_short(get_member(id, m_iTeam));
    message_end();

    if(show_message)
    {
        client_print_color(id, print_team_default, "^1[^3%s^1] %n, вы успешно сбросили ваш счёт!", plugin_name, id);
    }
}

