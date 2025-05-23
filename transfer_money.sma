#include <base/amxmodx>
#include <base/reapi>

#include <raws>

//Plugin created: 23 Май 2025 (16:04:32)
stock const plugin_name[]					= "Transfer Money";
stock const plugin_version[]				= "1.0";
stock const plugin_author[]					= "ISellGarage";

new tm_save_id[33]                          = 0;

public plugin_init()
{
    register_plugin(plugin_name, plugin_version, plugin_author);

    register_clcmd("say /transfer", "_CmdDonateMenu");

    register_clcmd("__transfer_mode", "_MessageModeTransfer");
}

public _CmdDonateMenu(id)
{
    create_players_menu(id);

    return PLUGIN_HANDLED;
}

public create_players_menu(id)
{
    new menu = menu_create("[ TEST PLAYER MENU ]", "handler_player_menu");

    new players[32], num;
    get_players(players, num);

    new player;
    new money;
    new key[6];

    for(new i = 0; i < num; i++)
    {
        player = players[i];
        money = get_member(player, m_iAccount);

        if(player == id)
        {
            continue;
        }
    
        num_to_str(i, key, charsmax(key));

        menu_additem(menu, fmt("%n - %d", player, money), key);
    }

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menu, MPROP_EXITNAME, "Выход");
    menu_display(id, menu, 0);

    return PLUGIN_HANDLED;
}

public handler_player_menu(id, menu, items)
{
    if(items == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[6], access, callback, name[32];
    menu_item_getinfo(menu, items, access, data, charsmax(data), name, charsmax(name), .callback = callback);

    new search_name[32];
    new search_money[6];
    strtok2(name, search_name, charsmax(search_name), search_money, charsmax(search_money), '-');

    trim(search_name);
    trim(search_money);

    new selected_id = get_user_index(search_name);

    server_print("[%s] Player %s (%n / %d) have %d$", plugin_name, search_name, selected_id, selected_id, search_money);

    if(!is_user_connected(selected_id))
    {
        server_print("[%s] Player %n not connected...", plugin_name, selected_id)
        return PLUGIN_HANDLED;
    }

    tm_save_id[id] = selected_id;

    create_transfer_menu(id);
    
    return PLUGIN_HANDLED;
}

public create_transfer_menu(id)
{
    new menu = menu_create("[ TEST TRANSFER MENU ]", "handler_transfer_menu");

    menu_additem(menu, "Передать 500$", "1");
    menu_additem(menu, "Передать 1000$", "2");
    menu_additem(menu, "Передать 2000$", "3");
    menu_additem(menu, "Передать 5000$", "4");
    menu_additem(menu, "Передать 10000$", "5");
    menu_addblank2(menu);
    menu_additem(menu, "Своё значение", "6");

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menu, MPROP_EXITNAME, "Выход");
    menu_display(id, menu, 0);

    return PLUGIN_HANDLED;
}

public handler_transfer_menu(id, menu, items)
{
    if(items == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[6], access, callback;
    menu_item_getinfo(menu, items, access, data, charsmax(data), .callback = callback);

    new key = str_to_num(data);

    new receiver = tm_save_id[id];

    if(key == 6)
    {
        client_cmd(id, "messagemode __transfer_mode");
        return PLUGIN_HANDLED;
    }

    new exchange_values[] = {0, 500, 1000, 2000, 5000, 10000};

    transfer_money(id, receiver, exchange_values[key]);


    return PLUGIN_HANDLED;
}

public _MessageModeTransfer(id)
{
    new arguments[64];
    read_args(arguments, charsmax(arguments));

    remove_quotes(arguments);

    if(is_str_empty(arguments))
    {
        return PLUGIN_HANDLED;
    }

    if(!is_str_num(arguments))
    {
        /* server_print("[%s] Error string! Only nums!", plugin_name); */
        return PLUGIN_HANDLED;
    }

    new receiver = tm_save_id[id];

    transfer_money(id, receiver, str_to_num(arguments));

    return PLUGIN_CONTINUE;
}

stock transfer_money(const sender, const receiver, value)
{
    new sender_money;
    sender_money = get_member(sender, m_iAccount);

    if(sender_money < value)
    {
        return 0;
    }

    rg_add_account(sender, sender_money - value, AS_SET);
    rg_add_account(receiver, value, AS_ADD);

    return 1;
}