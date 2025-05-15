#include <base/amxmodx>
#include <base/reapi>

#include <raws>

new const plugin_name[]                 = "Kill Screen Fade";
new const plugin_version[]              = "1.0";
new const plugin_author[]               = "ISellGarage";

stock user_sf_color[33][COLORS];
stock user_sf_alpha[33] = 128;
stock Float:user_sf_time[33] = 1.0;
stock user_mode_value[33];
stock user_menu_add[33] = 0;

public plugin_init()
{
    register_plugin(plugin_name, plugin_version, plugin_author);

    plugin_notification(plugin_name, plugin_version, plugin_author);

    RegisterHookChain(RG_CBasePlayer_Killed, "@CBasePlayer_Killed", true);

    register_clcmd("say /fade", "_CmdMenuFade");
    register_clcmd("raws_fade", "_CmdMenuFade");
}

public client_putinserver(id)
{
    user_sf_color[id] = {0, 100, 0};
    user_sf_alpha[id] = 128;
    user_sf_time[id] = 1.0;
}

@CBasePlayer_Killed(const victim, const attacker, const gib)
{

    send_screen_fade(attacker, user_sf_color[attacker], user_sf_time[attacker], 1.0, user_sf_alpha[attacker]);

    return HC_CONTINUE;
}

public _CmdMenuFade(id)
{
    create_menu_fade(id);

    return PLUGIN_HANDLED;
}

create_menu_fade(const id)
{
    new menu = menu_create("[ F A D E ]", "handler_fade_menu");

    menu_additem(menu, fmt("Яркость: %d", user_sf_alpha[id]), "1");
    menu_additem(menu, fmt("Время: %.1f", user_sf_time[id]), "2");
    menu_addblank(menu, 0);
    menu_additem(menu, fmt("Красный: %d", user_sf_color[id][R]), "3");
    menu_additem(menu, fmt("Зелёный: %d", user_sf_color[id][G]), "4");
    menu_additem(menu, fmt("Синий: %d", user_sf_color[id][B]), "5");
    menu_addblank(menu, 0);
    menu_additem(menu, fmt("Вы \r%s\w значение", user_mode_value[id] ? "прибавляете" : "отнимаете"), "6");
    menu_additem(menu, fmt("\r%s\w по %d", user_mode_value[id] ? "Добавлять" : "Отнимать", user_menu_add[id]), "7");
    

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menu, MPROP_EXITNAME, "Выход");
    menu_display(id, menu, 0);

    return PLUGIN_HANDLED;
}

public handler_fade_menu(id, menu, items)
{
    if(items == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new data[6], access, callback;
    menu_item_getinfo(menu, items, access, data, charsmax(data), .callback = callback);

    new key = str_to_num(data);

    new Float:user_menu_float[33];
    static count;
    static value[3] = {5, 10, 25};

    switch(key)
    {
        case 1:
        {
            switch(user_mode_value[id])
            {
                case 1:
                {
                    if(user_sf_alpha[id] + user_menu_add[id] > 255)
                    {
                        user_sf_alpha[id] = 0;
                    }
                    else 
                    {
                        user_sf_alpha[id] += user_menu_add[id];
                    }
                }
                case 0:
                {
                    if(user_sf_alpha[id] - user_menu_add[id] < 0)
                    {
                        user_sf_alpha[id] = 0;
                    }
                    else 
                    {
                        user_sf_alpha[id] -= user_menu_add[id];
                    }
                }
            }
            send_screen_fade(id, user_sf_color[id], user_sf_time[id], 1.0, user_sf_alpha[id]);
        }
        
        case 2:
        {
            switch(user_mode_value[id])
            {
                case 1:
                {

                    user_menu_float[id] = user_menu_add[id] / 10.0;
                    if(user_sf_time[id] + user_menu_float[id] > 5.0)
                    {
                        user_sf_time[id] = 0.0;
                    }
                    else 
                    {
                        user_sf_time[id] += user_menu_float[id];
                    }
                }
                case 0:
                {
                    user_menu_float[id] = user_menu_add[id] / 10.0;
                    if(user_sf_time[id] - user_menu_float[id] < 0.0)
                    {
                        user_sf_time[id] = 0.0;
                    }
                    else 
                    {
                        user_sf_time[id] -= user_menu_float[id];
                    } 
                }
            }
            send_screen_fade(id, user_sf_color[id], user_sf_time[id], 1.0, user_sf_alpha[id]);
        }
        case 3:
        {
            switch(user_mode_value[id])
            {
                case 1:
                {
                    if(user_sf_color[id][R] + user_menu_add[id] > 255)
                    {
                        user_sf_color[id][R] = 0;
                    }
                    else 
                    {
                        user_sf_color[id][R] += user_menu_add[id];
                    }
                }
                case 0:
                {
                    if(user_sf_color[id][R] - user_menu_add[id] < 0)
                    {
                        user_sf_color[id][R] = 0;
                    }
                    else 
                    {
                        user_sf_color[id][R] -= user_menu_add[id];
                    }
                }
            }
            send_screen_fade(id, user_sf_color[id], user_sf_time[id], 1.0, user_sf_alpha[id]);
        }
        case 4:
        {
            switch(user_mode_value[id])
            {
                case 1:
                {

                    if(user_sf_color[id][G] + user_menu_add[id] > 255)
                    {
                        user_sf_color[id][G] = 0;
                    }
                    else 
                    {
                        user_sf_color[id][G] += user_menu_add[id];
                    }
                }
                case 0:
                {
                    if(user_sf_color[id][G] - user_menu_add[id] < 0)
                    {
                        user_sf_color[id][G] = 0;
                    }
                    else 
                    {
                        user_sf_color[id][G] -= user_menu_add[id];
                    }
                }
            }
            send_screen_fade(id, user_sf_color[id], user_sf_time[id], 1.0, user_sf_alpha[id]);
        }
        case 5:
        {
            switch(user_mode_value[id])
            {
                case 1:
                {
                    if(user_sf_color[id][B] + user_menu_add[id] > 255)
                    {
                        user_sf_color[id][B] = 0;
                    }
                    else 
                    {
                        user_sf_color[id][B] += user_menu_add[id];
                    }
                }
                case 0:
                {
                    if(user_sf_color[id][B] - user_menu_add[id] < 0)
                    {
                        user_sf_color[id][B] = 0;
                    }
                    else 
                    {
                        user_sf_color[id][B] -= user_menu_add[id];
                    }
                }
            }

            send_screen_fade(id, user_sf_color[id], user_sf_time[id], 1.0, user_sf_alpha[id]);
        }
        case 6:
        {
            user_mode_value[id] = !user_mode_value[id];
        }
        case 7:
        {
            if(count == 3)
            {
                count = 0;
            }

            user_menu_add[id] = value[count];

            count++;
        }
    }

    create_menu_fade(id);
    return PLUGIN_HANDLED;
}
