/*
    RAWS + AMXX
*/

#define is_str_empty(%0)        bool:(%0[0] == EOS)
#define is_str_comment(%0)		bool:( (%0[0] == '/' && %0[1] == '/') || %0[0] == ';')


enum _:BOUNDS
{
	MIN = 0,
	MAX
};

enum _:WORLD_POSITION
{
	Float:X,
	Float:Y,
	Float:Z
};

enum _:VALUE_CHANGE
{
	VC_ADD,
	VC_TAKE,
	VC_SET,
	MULT,
}

enum _:TIME_NAMES
{
	SECONDS,
	MINUTES,
	HOURS
};



stock const creator_prefix[]                        = "RAWS";
stock const creator_name[]							= "ISellGarage";

stock const fmt_seconds[][16] 	= {"секунд", "секунда", "секунды"};
stock const fmt_minutes[][16] 	= {"минут",  "минута",  "минуты"};
stock const fmt_hours[][16]		= {"часов",  "час",     "часы"};

const MESSAGE_MONEY									= 102;

const LEN_MAX_KEY									= 16;
const LEN_MAX_NAME                                  = 32;
const LEN_MAX_STRING_SMALL							= 32;
const LEN_MAX_STRING_SHORT							= 64;
const LEN_MAX_STRING_NORMAL							= 128;
const LEN_MAX_STRING_BIG							= 256;
const LEN_MAX_STRING_EXTRA							= 512;
const LEN_MAX_PATH                                  = 192;
const LEN_MAX_RESOURCE_PATH							= 256;
const LEN_MAX_MENU_TITLE							= 192;
const LEN_MAX_MENU_ITEM								= 192;
const LEN_MAX_MENU_KEY								= 16;

stock const server_folder_configs[]                 = "addons/amxmodx/configs";
stock const server_folder_models[]                  = "models";

const raws_teams = 4;

stock const raws_team_names[raws_teams][] = {"TEAM_UNASSIGNED", "TEAM_TERRORIST", "TEAM_CT", "TEAM_SPECTATOR"};
stock const Float:raws_team_colors[raws_teams][3] = { {0.0, 0.0, 0.0}, {200.0, 0.0, 0.0}, {0.0, 0.0, 200.0}, {0.0, 0.0, 0.0} };
