#if defined _raws_const_included
    #endinput
#endif

#define _raws_const_included

#define raws_init_debug()          !_debug && (_debug = (plugin_flags() & AMX_FLAG_DEBUG) ? 1 : 0)

/*
 * LOAD FILE TYPE
 * 0 - Сам открывает файл (fopen()) и возвращает index
 * 1 - Просто возвращает путь для открытия файла
 */

enum _:
{   LFT_TYPE_MANUAL = 0, 
    LFT_TYPE_DIR
};

enum _:SCREEN_POSITION
{
    Float:X,
    Float:Y
};

enum _:WORLD_POSITION
{
    Float:X,
    Float:Y,
    Float:Z
};

stock const raws_folder[]               = "RAWS";
stock const raws_folder_base[]          = "addons/amxmodx/configs/RAWS";
stock const amxx_folder_base[]          = "addons/amxmodx/configs";

stock const classname_breakable[]       = "func_breakable";

stock _debug;

/* HL Game Events */
const _MSGID_Money                      = 102; //get_user_msgid("Money")

/* Lens for array */
const LEN_MAX_PATH                      = 256; //full_path[LEN_MAX_PATH]
const LEN_MAX_NAME                      = 32; 
