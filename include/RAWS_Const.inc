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

enum _:COLORS 
{
    R,
    G,
    B
};

enum _:MODEL_TYPE
{
    MT_W,
    MT_P,
    MT_V
};

stock const raws_folder[]               = "RAWS";
stock const raws_folder_base[]          = "addons/amxmodx/configs/RAWS";
stock const amxx_folder_base[]          = "addons/amxmodx/configs";
stock _debug;

stock const classname_breakable[]       = "func_breakable";

stock const str_time_units_secs[][]     = {"секунд", "секунда", "секунды"};
stock const str_time_units_mins[][]     = {"минут", "минута", "минуты"};
stock const str_time_units_hours[][]    = {"часов", "час", "часы"};


/* HL Game Events */
const _MSGID_Money                      = 102;  //get_user_msgid("Money")
const _MSGID_ScreenFade                 = 98;   //get_user_msgid("ScreenFade")
const _MSGID_ScoreInfo                  = 85;   //get_user_msgid("ScoreInfo")

/* Lens for array */
const LEN_MAX_PATH                      = 256; //full_path[LEN_MAX_PATH]
const LEN_MAX_NAME                      = 32; 
