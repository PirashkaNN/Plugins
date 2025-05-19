#if defined _raws_included
    #endinput
#endif

#define _raws_included

stock const raws_include[]              = "RaWs";
stock const raws_version[]              = "1.0";
stock const raws_author[]               = "@ISellGarage";

#include <raws_const>

#include <raws_stocks>

#include <raws_configuration_adv>

/**
 * Проверяет на пустую строку
 *
 *
 * @param string            Строка для проверки
 *
 * @return                  0 / 1                
 */
stock is_str_empty(const string[])
{
    return string[0] ? 0 : 1;
}

/**
 * Проверяет на закомментированную строку
 *
 *
 * @param string            Строка для проверки
 *
 * @return                  0 / 1                
 */
stock is_str_commentary(const string[])
{
    return ( (string[0] == '/' || string[1] == '/') || string[0] == ';') ? 1 : 0;
}

stock is_origin_null(const Float:origin[WORLD_POSITION] = {0.0, 0.0, 0.0})
{
    if(origin[X] == 0.0 && origin[Y] == 0.0 && origin[Z] == 0.0)
    {
        return 1;
    }

    return 0;
}

/**
 * Выводит в консоль информацию об плагине
 *
 * @note type:
 * @note 0 - Сам открывает файл (fopen()) и возвращает index
 * @note 1 - Просто возвращает путь для открытия файла
 *
 * @param filename          Название файла (filename.cfg or auth.ini)
 * @param type              Тип открытия файла
 *
 * @noreturn               
 */
stock raws_load_file(const filename[], const type = 0, buffer[] = "", len)
{
    new full_path[256];
    formatex(full_path, charsmax(full_path), "%s/%s", raws_folder_base, filename);

    switch(type)
    {
        case LFT_TYPE_MANUAL:
        {
            new file = fopen(full_path, "rt"); //rt - open exists file

            if(!file)
            {
                _debug && log_amx("[%s] File %s not opened", raws_include, filename);

                return 0;
            }

            //not closed?
            return file;
        }
        case LFT_TYPE_DIR:
        {
            //just return path
            formatex(buffer, len, full_path);
        }
    }

    //if type != 0 or 1
    return 0;
}

/**
 * Создаёт квар и записывает его в Array
 *
 *
 * @param a_data            Array
 * @param name        		Имя квара
 * @param value          	Значение квара
 * @param flags       		Флаги квара
  * @param description      Описание квара
 *
 * @return					Возвращает id квара
 */
stock raws_create_cvar(const Array:array, const cvar_name[], const cvar_value[], flags = FCVAR_NONE, const description[] = "")
{
    new pCvar = get_cvar_pointer(cvar_name);
	new temp_cvar_value[256];

    new configuration_text[256];

    //have?
	if(cvar_exists(cvar_name))
	{
		get_pcvar_string(pCvar, temp_cvar_value, charsmax(temp_cvar_value));

		if(equal(cvar_value, temp_cvar_value))
		{
			formatex(configuration_text, charsmax(configuration_text), "//%s^n ^"%s^" ^"%s^"^n", description, cvar_name, cvar_value);
		}
		else 
		{
			formatex(configuration_text, charsmax(configuration_text), "//%s^n ^"%s^" ^"%s^"^n", description, cvar_name, temp_cvar_value);
		}
	}
	else 
	{
		formatex(configuration_text, charsmax(configuration_text), "//%s^n ^"%s^" ^"%s^"^n", description, cvar_name, cvar_value);
	}

	if(array == Invalid_Array)
    {
        _debug && log_amx("[%s] Cvar error! Array not created! (cvar: %s)", raws_include, cvar_name);
        return 0;
    }

	ArrayPushString(array, configuration_text);

	_debug && log_amx("[%s] Cvar '%s' created. Value '%s' ", raws_include, cvar_name, cvar_value);

	return create_cvar(cvar_name, cvar_value, flags, description);
}

/**
 * Выводит в консоль информацию об плагине
 *
 *
 * @param name              Имя плагина
 * @param version           Версия плагина
 * @param author            Автор плагина
 *
 * @noreturn               
 */
stock plugin_notification(const name[], const version[], const author[], const URL[] = "None", const contact[] = "None", isplugin = 0)
{
    server_print("");
    server_print("--------------------");
    server_print("Red And White Servers");
    server_print("%s name: %s", isplugin ? "Plugin" : "Mod", name);
    server_print("%s version: %s", isplugin ? "Plugin" : "Mod", version);
    server_print("%s author: %s", isplugin ? "Plugin" : "Mod", author);
    server_print("URL author: %s", URL);
    server_print("Contact author: %s", contact);
    server_print("--------------------");
    server_print("");
}

/* Used code */
/* https://amx-x.ru/viewtopic.php?p=292355 */
stock send_screen_fade(id, color[COLORS] = {0, 0, 0}, Float:flFxTime = 1.0, Float:flHoldTime = 1.0, alpha = 0)
{
    const FFADE_IN = 0x0000;
    message_begin(MSG_ONE_UNRELIABLE, _MSGID_ScreenFade, .player = id)
    /* message_begin(MSG_ONE, _MSGID_ScreenFade, .player = id); */
    write_short(FixedUnsigned16(flFxTime, 1<<12));
    write_short(FixedUnsigned16(flHoldTime, 1<<12));
    write_short(FFADE_IN);
    write_byte(color[R]);
    write_byte(color[G]);
    write_byte(color[B]);
    write_byte(alpha);
    message_end();
}

stock FixedUnsigned16(Float:flValue, iScale)
{
    new iOutput

    iOutput = floatround(flValue * iScale)

    if(iOutput < 0)
        iOutput = 0

    if(iOutput > 0xFFFF)
        iOutput = 0xFFFF

    return iOutput
}