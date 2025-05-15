#if defined _raws_stocks_included
    #endinput
#endif

#define _raws_stocks_included

/**
	* 	Безопасное кэширование модели
	*	
	*
	*   @param path[]       Путь до файла
	*   @noreturn           
*/
stock precache_model_ex(const path[])
{
    if(!file_exists(path))
    {
        server_print("[%s] Failed load model", raws_include);
        server_print("[%s] Path: %s", raws_include, path);
        return 0;
    }

    return precache_model(path);
}

/**
	* 	Устанавливает максимальное здоровье игроку
	*	
	*
	*   @param id    	    id player
	*	@param value	    Flooat:health
	*	@param bSetHealth   Изменить текущее здоровье?
	*   @noreturn           
*/
stock set_max_health(const id, Float:value, bSetHealth = 0)
{
    set_entvar(id, var_max_health, value);
    
    if(bSetHealth)
    {
        set_entvar(id, var_health, value);
    }
}

/**
	* 	Создаёт спрайт между двумя точками
	*	
	*
	*   @param fStart    	Начало
	*	@param fEnd			Конец
	*	@param iSprite 		id спрайта
	*	@param iFrameStart 	Начальный кадр
	*	@param iFrameRate 	Частота кадров
	*   @param iLife    	Начало
	*	@param iWidth		Ширина спрайта
	*	@param iNoise 		Искажение
	*	@param iColor 		Цвет int:[R, G, B]
	*	@param iBrightness 	Яркость
	*	@param iScroll 		Скорость спрайта (прокрутки?)
	*   @return             -
*/
stock view_sprite_twopoints(Float:fStart[WORLD_POSITION], Float:fEnd[WORLD_POSITION], iSprite, iFrameStart = 0, iFrameRate = 0, iLife = 50, iWidth = 10, iNoise = 10, iColor[3] = {255, 255, 255}, iBrightness = 127, iScroll = 0)
{
    message_begin_f(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_BEAMPOINTS);
    write_coord_f(fStart[0]); 
    write_coord_f(fStart[1]); 
    write_coord_f(fStart[2]);
    write_coord_f(fEnd[0]); 
    write_coord_f(fEnd[1]); 
    write_coord_f(fEnd[2]); 
    write_short(iSprite);
    write_byte(iFrameStart); //framestart (5)                     [Default = 0]
    write_byte(iFrameRate); //Framerate (0.1s, 10 = 1fps) (2)    [Default = 0]
    write_byte(iLife); //Life (0.1s, 50 = 5sec)    (1)    [Default = 50]
    write_byte(iWidth); //Width (0.1s)             (60)   [Default = 10]
    write_byte(iNoise); //Noise                     (0)    [Default = 10]
    write_byte(iColor[0]); //Color[R] (58)
    write_byte(iColor[1]); //Color[G] (222)
    write_byte(iColor[2]); //Color[B] (58)
    write_byte(iBrightness); //Brightness (999)               [Default = 127]
    write_byte(iScroll); //Scroll (30) (0.1s)               [Default = 9]
    message_end( );
}

/**
	* 	Создаёт спрайт взрыва
	*	
	*
	*   @param sprite    	Начало
	*	@param origin			Конец
	*	@param scale 		id спрайта
	*	@param framerate 	Начальный кадр
	*   @noreturn             -
*/
stock create_sprite_explode(const sprite, const Float:origin[WORLD_POSITION] = {0.0, 0.0, 0.0}, scale = 10, framerate = 10)
{
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_EXPLOSION);
    write_coord_f(origin[X]);
    write_coord_f(origin[Y]);
    write_coord_f(origin[Z]);
    write_short(sprite);
    write_byte(scale);
    write_byte(framerate);
    write_byte(4);
    message_end();
}

/**
	* 	Создаёт спрайт частиц
	*	@note Данный сток только для частиц при попадании в объекты.
	*
	*   @param sprite    	    id sprite
	*	@param origin			Координаты
    *   @param count			Количество частиц
    *   @param lifetime			Время жизни
    *   @param scale			Масштаб
	*	@param velocity 		Скорость
	*	@param rnd_velocity 	Случайная скорость
	*   @noreturn             -
*/
stock create_sprite_particles(const sprite, const Float:origin[WORLD_POSITION] = {0.0, 0.0, 0.0}, count = 3, lifetime = 1, scale = 1, velocity = 1, rnd_velocity = 5)
{
    message_begin(MSG_ALL, SVC_TEMPENTITY);
    write_byte(TE_SPRITETRAIL);
    write_coord_f(origin[X] + random_num(- 15, 15) );
	write_coord_f(origin[Y] + random_num(- 15, 15));
	write_coord_f(origin[Z] + random_num(10, 30));
	write_coord_f(origin[X] - random_num(- 50, 50));
	write_coord_f(origin[Y] - random_num(- 50, 50));
	write_coord_f(origin[Z] + random_num(- 50, 50));
	write_short(sprite);
	write_byte(count);
	write_byte(lifetime);
	write_byte(scale);
	write_byte(velocity);
	write_byte(rnd_velocity);
	message_end(); 
}