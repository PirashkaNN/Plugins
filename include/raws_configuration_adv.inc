/**
 * Создаёт файл конфигурации
 *
 * @note Файл создаётся в стандартной папке 'RAWS'
 *
 * @param filename          Название файла (filename.cfg or auth.ini)
 *
 * @noreturn               0 - файл существует в папке, pointer file
 */
stock raws_create_file(const path[], const Array:array)
{
    if(array == Invalid_Array)
    {
        _debug && log_amx("[%s] Not create file %s. Array invalid", raws_include);
        return 0;
    }    

    //check exists
    if(file_exists(path))
    {
        return 0;
    }

    new file = fopen(path, "w");

    server_print("Full path: %s", path)

    fputs(file, "; The file was created using the RAWS include.^n^n");

    fclose(file);

    new buffer[512];
    new size = ArraySize(array);

    for(new i; i < size; i++)
	{
		if(ArrayGetString(array, i, buffer, charsmax(buffer)))
		{
			write_file(path, buffer);
		}
    }
}

/**
 * Создаёт папку
 *
 * @param folder            Название папки
 *
 * @noreturn                Возвращает полный путь до папки
 */
stock raws_create_folder(const folder[])
{
    new full_path[256];
    formatex(full_path, charsmax(full_path), "%s/%s", amxx_folder_base, folder);

    if(dir_exists(full_path))
    {
        /* if(!create)
        {
            _debug && log_amx("[%s] Folder %s exists.", raws_include, folder);
        } */

        _debug && log_amx("[%s] Not create folder %s. Folder exists.", raws_include, folder);
        return 0;
    }

    mkdir(full_path);
    _debug && log_amx("[%s] Folder '%s' created. ", raws_include, folder);

    return 1;
}

/**
 * Создаёт файл конфигурации
 *
 * @note Файл создаётся в стандартной папке 'RAWS'
 *
 * @param filename          Название файла (filename.cfg or auth.ini)
 *
 * @noreturn               0 - файл существует в папке, pointer file
 */
/* stock raws_create_file(const filename[])
{
    new full_path[256];
    formatex(full_path, charsmax(full_path), "%s/%s/%s", amxx_folder_base, filename, filename)
    

    //check exists
    if(file_exists(full_path))
    {
        _debug && log_amx("[%s] Not create file %s. File exists in 'RAWS' folder.", raws_include, filename);

        return full_path
    }

    new file = fopen(full_path, "w");

    fputs(file, "; The file was created using the RAWS include.");

    fclose(file);

    return full_path;
} */