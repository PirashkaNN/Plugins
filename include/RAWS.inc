#include <RAWS_Const>
#include <RAWS_Entity>
#include <RAWS_Utilies>

stock rehlds;
stock regamedll;

/*
	# - Заготовленные переменные
	* creator_prefix - Префикс проекта-разработчика
	* creator_name - Никнейм разработчика
	* LEN_MAX_NAME - Максимальная длина имени (32)
	* LEN_MAX_PATH - Максимальная длина пути к файлам (192)
	* LEN_MAX_STRING - Максимальная длина строки (256)
	* server_folder_configs - Путь до папки configs.
	* server_folder_models - Путь до папки models/
	и т.д.
*/

stock _IsCheckReHLDS()
{
	rehlds = is_rehlds();
	regamedll = is_regamedll();

	server_print("[%s] Is ReHLDS? %s", creator_prefix, rehlds ? "Yes" : "No");
	server_print("[%s] Have ReGameDLL? %s", creator_prefix, regamedll ? "Yes" : "No");
}

stock _GetServerTime()
{
	


}

/**
 * Вывод информации в консоль сервера об плагине
 *
 *
 * @param name            Имя плагина
 * @param version         Версия плагина
 * @param author          Автор плагина
 * @param mode            Режим плагина
 * @param contact   	  Контакты автора
 *
 * @noreturn
 */
stock raws_information(const name[], const version[], const author[], const mode[], contact[] = "none")
{
	server_print("");
	server_print("[%s] Red And White Servers (%s) ", creator_prefix, mode);
	server_print("[%s] Plugin: '%s' ", creator_prefix, name);
	server_print("[%s] Plugin version: '%s' ", creator_prefix, version);
	server_print("[%s] Plugin Author: '%s' ", creator_prefix, author);
	server_print("[%s] Contact: %s", creator_prefix, contact);
	server_print("");
}

/**
 * Копия отправки сообщений в чат, но с предустановкой префикса.
 *
 *
 * @param id            id игрока или всех (0)
 * @param prefix        Префикс
 * @param text          Текст
 * @param ...       	Переменные для форматирования
 *
 * @noreturn
 */
stock raws_send_to_chat(const id, const prefix[], const text[], any:...)
{
	new buffer[192];
	vformat(buffer, charsmax(buffer), text, 3);

	client_print_color(id, print_team_default, "%s ^1%s", prefix, buffer);
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
stock raws_create_cvar(const Array:a_data, const name[], const value[], flags = FCVAR_NONE, const description[] = "")
{
	new line[LEN_MAX_STRING_BIG];
	new temp_value[64];
	new cvar = get_cvar_pointer(name);
	if(cvar_exists(name))
	{
		get_pcvar_string(cvar, temp_value, charsmax(temp_value));

		if(equal(value, temp_value))
		{
			formatex(line, charsmax(line), "//%s^n ^"%s^" ^"%s^"^n", description, name, value);
		}
		else 
		{
			formatex(line, charsmax(line), "//%s^n ^"%s^" ^"%s^"^n", description, name, temp_value);
		}
	}
	else 
	{
		formatex(line, charsmax(line), "//%s^n ^"%s^" ^"%s^"^n", description, name, value);
	}

	if(a_data == Invalid_Array)
	{
		ArrayCreate(512, 512);
	}
	ArrayPushString(a_data, line);

	server_print("[%s] Cvar '%s', value '%s'", creator_prefix, name, value);

	return create_cvar(name, value, flags, description);
}

/**
 * Создаёт папку для конфигов плагина
 *
 *
 * @param path            	Путь до конфига
 * @param a_data        	Array из которого переписываются данные
 * @param update          	Обновить ли конфиг?
 *
 * @return					0 - файл есть, 1 - успешно, 2 - файл обновлён
 */
stock raws_create_folder(const folder_name[] = creator_name)
{
	new path[LEN_MAX_PATH];
	formatex(path, charsmax(path), "%s/%s/", server_folder_configs, folder_name);

	if(!dir_exists(path))
	{
		mkdir(path);
	}

	return path;
}

/**
 * Создаёт конфиг плагина и записывает в него данные из Array
 *
 *
 * @param path            	Путь до конфига
 * @param a_data        	Array из которого переписываются данные
 * @param update          	Обновить ли конфиг?
 *
 * @return					0 - файл есть, 1 - успешно, 2 - файл обновлён
 */
stock raws_create_configuration(path[], Array:a_data, bool:update = false)
{
	if(file_exists(path) && update)
	{
		delete_file(path);
		raws_create_configuration(path, a_data);
		return 2;
	}
	else if(file_exists(path))
	{
		return 0;
	}

	new file = fopen(path, "w");

	new size = ArraySize(a_data);

	new buffer_data[512];
	for(new i; i < size; i++)
	{
		if(ArrayGetString(a_data, i, buffer_data, charsmax(buffer_data)))
		{
			write_file(path, buffer_data);
		}

		fclose(file);
	}
	return 1;
}

/**
 * Кэширует файл, но с проверкой перед кэшем
 *
 * @param path				Путь до файла
 *
 * @return					0 - не найден файл, id кэшированного файла
 */
stock raws_precache_model(const path[LEN_MAX_PATH])
{
	if(!file_exists(path))
	{
		server_print("[%s - INCLUDE] Error! Precache file not founded!", creator_prefix);
		server_print("[%s - INCLUDE] %s", creator_prefix, path);
		return 0;
	}

	return precache_model(path);
}

/**
 * Проверяет есть ли у игрока единственный указанный флаг
 *
 * @param id				id игрока
 * @param flag				буква флага
 *
 * @return					0 - нету, 1 - есть
 */
stock raws_user_flag(const id, flag)
{
	return (get_user_flags(id) & flag)
}

/**
 * Проверяет есть ли у игрока определённые флаги
 *
 * @param id				id игрока
 * @param flags				Массив флагов
 *
 * @return					0 - нету, 1 - есть
 */
stock raws_user_flags(const id, flags)
{
	return ((get_user_flags(id) & flags) == flags);
}

/**
 * Квар с флагами в битсумму флага.
 *
 * @param cvar				Pointer cvar
 *
 * @return					bitsumm flags
 */
stock cvar_to_flags(const cvar)
{
	new cvar_value[16];
	get_pcvar_string(cvar, cvar_value, charsmax(cvar_value));

	return read_flags(cvar_value);
}

stock menu_additem_array(menu, name[][], size, callback)
{
	new i, key[16];
	for(i = 0; i < size; i++)
	{
		num_to_str(i, key, charsmax(key));
		menu_additem(menu, name[i], key, .callback = callback);
	}
}

stock time_to_ending(const time, string[LEN_MAX_STRING_NORMAL])
{
    if(3600 < time)
    {
        time_to_string_ending(time, string, fmt_hours[0], fmt_hours[1], fmt_hours[2]);
    }
    else if(60 < time < 3599)
    {
        time_to_string_ending(time, string, fmt_minutes[0], fmt_minutes[1], fmt_minutes[2]);
    }
    else if(0 < time < 59)
    {
        time_to_string_ending(time, string, fmt_seconds[0], fmt_seconds[1], fmt_seconds[2]);
    }
}

stock time_to_string_ending(value, buffer[], const plural[], const nominative[], const singular[])
{
	new num_to_100 = value % 100;
	new num_to_10 = value % 10;

	if( (5 <= num_to_100 <= 20) || num_to_10 == 0 || (5 <= num_to_10 <= 9) )
	{
		formatex(buffer, charsmax(buffer), plural);
	}
	else if(num_to_10 == 1) 
	{
		formatex(buffer, charsmax(buffer), nominative);
	}
	else if(2 <= num_to_10 <= 4)
	{
		formatex(buffer, charsmax(buffer), singular);
	}
}