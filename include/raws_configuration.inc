#if defined _raws_configuration_included
    #endinput
#endif

#define _raws_configuration_included

stock raws_create_configuration(const folder[], const file[], Array:array_pointer, rebuild_file = 0)
{
    /* Проверка на пути до папки и файла */
    if(is_str_empty(folder) || is_str_empty(file))
    {
        server_print("[RAWS Configuration] create_configuration() > Путь до папки или название файла отсутствуют");
        server_print("[RAWS Configuration] Folder: [%s] / File [%s]", folder, file);
        return 0; /* Останавливаем работу стока */
    }

    /* Если отсутствует папка, то мы её создаём! */
    if(!dir_exists(folder))
    {
        mkdir(folder);
        server_print("[RAWS Configuration] Папка для конфигурации отсутствует, создаём...");
    }

    new full_path[256];
    formatex(full_path, charsmax(full_path), "%s/%s", folder, file);

    if(file_exists(full_path))
    {
        if(rebuild_file)
        {
            delete_file(file);
        }

        execute_configuration(folder, file);
        return 1;
    }

    __create_file(folder, file, array_pointer);

    return 1;
}

stock __create_file(const folder[], const file[], Array:array_pointer)
{
    new full_path[256];
    formatex(full_path, charsmax(full_path), "%s/%s", folder, file);

    new file_pointer = fopen(full_path, "wt");
    
    if(array_pointer == Invalid_Array)
    {
        server_print("[RAWS Configuration] create_configuration() > Array Error!");
        return 0;
    }

    new size_data = ArraySize(array_pointer);
    new text_data[512];

    for(new i; i < size_data; i++)
    {
        ArrayGetString(array_pointer, i, text_data, charsmax(text_data));
        fputs(file_pointer, text_data);
    }

    fclose(file_pointer);
    return 1;
}

stock raws_create_cvar(Array:array_pointer = Invalid_Array, const cvar_name[], const cvar_value[], cvar_flags, const cvar_desc[])
{
    new file_text[512];
    if(cvar_exists(cvar_name))
    {
        new temp_value[64];
        get_cvar_string(cvar_name, temp_value, charsmax(temp_value));

        if(equal(cvar_value, temp_value))
        {
            formatex(file_text, charsmax(file_text), ";%s^n%s ^"%s^"^n^n", cvar_desc, cvar_name, cvar_value);
        }
        else
        {
            formatex(file_text, charsmax(file_text), ";%s^n%s ^"%s^"^n^n", cvar_desc, cvar_name, temp_value);
        }
    }
    else 
    {
        formatex(file_text, charsmax(file_text), ";%s^n%s ^"%s^"^n^n", cvar_desc, cvar_name, cvar_value);
    }

    if(array_pointer != Invalid_Array)
    {
        __writting_array(array_pointer, file_text);
    }

    return create_cvar(cvar_name, cvar_value, cvar_flags, cvar_desc);
}

stock raws_read_cvar(const cvar_name[], output[], len, find_file = 0, folder[] = "", file[] = "")
{
    new cvar_pointer = get_cvar_pointer(cvar_name);

    switch(find_file)
    {
        case 0: //Значение квара на запущенном сервере
        {
            new cvar_value[512];
            get_pcvar_string(cvar_pointer, cvar_value, len);
            formatex(output, len, cvar_value);
        }
        case 1: //Значение квара из конфига
        {
            if(is_str_empty(folder) || is_str_empty(file))
            {
                server_print("[RAWS Configuration] raws_read_cvar() > Путь до папки или название файла отсутствуют");
                server_print("[RAWS Configuration] Folder: [%s] / File [%s]", folder, file);
                return 0;
            }

            new full_path[256];
            formatex(full_path, charsmax(full_path), "%s/%s", folder, file);

            new file_pointer = fopen(full_path, "rt");

            if(!file_pointer)
            {
                server_print("[RAWS Configuration] raws_read_cvar() > file_pointer error");
                return 0;
            }

            new text[512];
            new temp_value[512], temp_name[512];

            while(!feof(file_pointer))
            {
                fgets(file_pointer, text, charsmax(text));

                if(is_str_empty(text) || is_str_commentary(text))
                {
                    continue;
                }

                parse(text, temp_name, charsmax(temp_name), temp_value, charsmax(temp_value));

                if(!equal(cvar_name, temp_name))
                {
                    continue;
                }
                

                formatex(output, len, temp_value);
            }
        }
    }

    return cvar_pointer;
}

stock __writting_array(Array:array_pointer, data[])
{
    if(array_pointer == Invalid_Array)
    {
        array_pointer = ArrayCreate(512, 512);

        server_print("[RAWS Configuration] __Writing_array > Array not created! Create and start write");
    }

    ArrayPushString(array_pointer, data);
}

stock execute_configuration(const folder[], const file[])
{
    if(is_str_empty(folder) || is_str_empty(file))
    {
        server_print("[RAWS Configuration] execute_configuration() > Путь до папки или название файла отсутствуют");
        server_print("[RAWS Configuration] Folder: [%s] / File [%s]", folder, file);
        return 0; /* Останавливаем работу стока */
    }

    new full_path[256];
    formatex(full_path, charsmax(full_path), "%s/%s", folder, file);

    server_cmd("exec %s", full_path);
}