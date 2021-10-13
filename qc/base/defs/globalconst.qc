//==============================================================================
//
//    globalconst.qc - constants
//
//==============================================================================

weapon_t weaponlist[MAX_WEAPID];

float	FALSE					= 0;
float 	TRUE					= 1;

// math
const float M_PI = 3.14159265359;
const float M_2mPI = 2*M_PI;
const float M_PId2 = M_PI/2;
const float M_PId8 = M_PI/8;
const float DEG2RAD = M_PI/180;
const float RAD2DEG = 180/M_PI;
const float COS_45 = 0.70710678118654752440;

// time values
const float ENV_SHORTTHINK = 1.0/30;
const float ENV_STOPTHINK = -1;
const float TIME_POST_ENTSPAWN = ENV_SHORTTHINK; //all entities have spawned
const float TIME_POST_SPAWNREADY = TIME_POST_ENTSPAWN + ENV_SHORTTHINK; //spawners are ready
const float TIME_POST_EVENTSPAWN = TIME_POST_ENTSPAWN + ENV_SHORTTHINK; //event entities have been configured
const float TIME_POST_ENTLINK = TIME_POST_ENTSPAWN + ENV_SHORTTHINK; //doors/spawns/etc have been linked
const float TIME_WORLDSTART = TIME_POST_ENTLINK + ENV_SHORTTHINK;

// misc
const float WEAPON_IMPULSE_MIN = 1;
const float WEAPON_IMPULSE_MAX = 8;
float WEAP_SLOTS = (WEAPON_IMPULSE_MAX - WEAPON_IMPULSE_MIN) + 1;
const float WEAP_ACTIONS = 5;
const vector VEC_ORIGIN = '0 0 0';
const vector VEC_HULL_MIN = '-16 -16 -24';
const vector VEC_HULL_MAX = '16 16 32';
const vector VEC_HULL2_MIN = '-32 -32 -24';
const vector VEC_HULL2_MAX = '32 32 64';
const vector MISSILE_SIZE = '0 0 0';
const vector NAIL_SIZE = '0 0 0';

//general flag values
const float FL_Null = 0;//up to 24
const float FL_1 = 1;
const float FL_2 = 2;
const float FL_3 = 4;
const float FL_4 = 8;
const float FL_5 = 16;
const float FL_6 = 32;
const float FL_7 = 64;
const float FL_8 = 128;
const float FL_9 = 256;
const float FL_10 = 512;
const float FL_11 = 1024;
const float FL_12 = 2048;
const float FL_13 = 4096;
const float FL_14 = 8192;
const float FL_15 = 16384;
const float FL_16 = 32768;
const float FL_17 = 65536;
const float FL_18 = 131072;

// edict.flags
float	FL_FLY		    = FL_1;
float	FL_SWIM		    = FL_2;
float	FL_CLIENT           = FL_4;	// set for all client edicts
float	FL_INWATER	    = FL_5;	// for enter / leave water splash
float	FL_MONSTER	    = FL_6;
float	FL_GODMODE	    = FL_7;	// player cheat
float	FL_NOTARGET	    = FL_8;	// player cheat
float	FL_ITEM		    = FL_9;	// extra wide size for bonus items
float	FL_ONGROUND	    = FL_10;	// standing on something
float	FL_PARTIALGROUND    = FL_11;	// not all corners are valid
float	FL_WATERJUMP	    = FL_12;	// player jumping out of water
float	FL_JUMPRELEASED	    = FL_13;	// for jump debouncing

//damage flags - general damage info
const float DAMFL_Hit = FL_1;
const float DAMFL_Fire = FL_2;
const float DAMFL_Poison = FL_3;
const float DAMFL_Concussion = FL_4;

//spawnflags
float NOT_ON_EASY = 256;
float NOT_ON_NORMAL = 512;
float NOT_ON_HARD = 1024;
float NOT_IN_DEATHMATCH = 2048;
float DOOR_START_OPEN = FL_1;
float DOOR_DONT_LINK = FL_3;
float DOOR_GOLD_KEY = FL_4;
float DOOR_SILVER_KEY = FL_5;
float DOOR_TOGGLE = FL_6;

float SECRET_OPEN_ONCE = 1;
float SECRET_1ST_LEFT = 2; 
float SECRET_1ST_DOWN = 4; 
float SECRET_NO_SHOOT = 8; 
float SECRET_YES_SHOOT = 16;

float TELEPORTER_PLAYER_ONLY = 1;
float TELEPORTER_SILENT = 2;

float PLAT_LOW_TRIGGER = 1;

float H_ROTTEN = 1;
float H_MEGA = 2;

//touch identity flags
const float TOUCHFL_None = FL_Null;
const float TOUCHFL_Player = FL_1;  //Everything else is extra

//event types
const float EVENT_Not = FL_Null;
const float EVENT_Damage = FL_1;
const float EVENT_Kill = FL_2;
const float EVENT_SetVal = FL_3;
const float EVENT_TurnOn = FL_4;
const float EVENT_TurnOff = FL_5;
const float EVENT_Activate = FL_7;
const float EVENT_ToggleOn = FL_8;

//event flags
const float EVFL_On = FL_1;
const float EVFL_Switchable = FL_2;
const float EVFL_Activated = FL_3;
const float EVFL_Modified = FL_4;

//general flags, entity specific, used in .gen_flags
const float GENFL_AnimPlayOnce = FL_1;
const float GENFL_ActivateTargets = FL_1;//used for trigger_activate
const float GENFL_ActivateActivators = FL_2;//used for trigger_activate
const float GENFL_ActivateAuto = FL_3;//automatically choose to activate on targets or activators
const float GENFL_NoReadyModification = FL_4;//do not set self.trigger_ready
const float GENFL_IgnoreTriggerReady = FL_5;//activate even if self.trigger_ready is not ready
const float GENFL_TriggerReadyFollowsReciprocator = FL_6;//trigger ready will be set based on reciprocator target's predicted ready time, rather than self's wait

// setval types
const float SETVAL_None = FL_Null;
const float SETVAL_Speed = FL_1;
const float SETVAL_Target = FL_2;
const float SETVAL_Damage = FL_3;
const float SETVAL_Velocity = FL_4;

// extra_spawnflags
const float ESF_BeginOff = FL_1;

// for the buttons bitfield
const float BUTTON_0  = FL_1;
const float BUTTON_1  = FL_2;
const float BUTTON_2  = FL_3;
const float BUTTON_3  = FL_4;
const float BUTTON_4  = FL_5;
const float BUTTON_5  = FL_6;
const float BUTTON_6  = FL_7;
const float BUTTON_7  = FL_8;
const float BUTTON_8  = FL_9;
const float BUTTON_9  = FL_10;
const float BUTTON_10 = FL_11;
const float BUTTON_11 = FL_12;
const float BUTTON_12 = FL_13;
const float BUTTON_13 = FL_14;
const float BUTTON_14 = FL_15;
const float BUTTON_15 = FL_16;
const float BUTTON_16 = FL_17;

// extra_flags
const float EXTRAFL_SingleFire = FL_1;//if on, fire once per click

// messages
float   MSG_BROADCAST           = 0;            // unreliable to all
float   MSG_ONE                 = 1;            // reliable to one (msg_entity)
float   MSG_ALL                 = 2;            // reliable to all
float   MSG_INIT                = 3;            // write to the init string
float   MSG_MULTICAST           = 4;            // for multicast() call

// multicast sets
float   MULTICAST_ALL   = 0;            // every client
float   MULTICAST_PHS   = 1;            // within hearing
float   MULTICAST_PVS   = 2;            // within sight
float   MULTICAST_ALL_R = 3;            // every client, reliable
float   MULTICAST_PHS_R = 4;            // within hearing, reliable
float   MULTICAST_PVS_R = 5;            // within sight, reliable

// protocol bytes
float	SVC_BAD			= 0;
float	SVC_NOP			= 1;
float	SVC_DISCONNECT		= 2;
float	SVC_UPDATESTAT		= 3;
float	SVC_VERSION		= 4;
float	SVC_SETVIEW		= 5;
float	SVC_SOUND		= 6;
float	SVC_TIME		= 7;
float	SVC_PRINT		= 8;
float	SVC_STUFFTEXT		= 9;
float	SVC_SETANGLE		= 10;
float	SVC_SERVERINFO		= 11;
float	SVC_LIGHTSTYLE		= 12;
float	SVC_UPDATENAME		= 13;
float	SVC_UPDATEFRAGS		= 14;
float	SVC_CLIENTDATA		= 15;
float	SVC_STOPSOUND		= 16;
float	SVC_UPDATECOLORS	= 17;
float	SVC_PARTICLE		= 18;
float	SVC_DAMAGE		= 19;
float	SVC_SPAWNSTATIC		= 20;
float	SVC_SPAWNBINARY		= 21;
float	SVC_SPAWNBASELINE	= 22;
float	SVC_TEMPENTITY		= 23;
float	SVC_SETPAUSE		= 24;
float	SVC_SIGNONNUM		= 25;
float	SVC_CENTERPRINT		= 26;
float	SVC_KILLEDMONSTER	= 27;
float	SVC_FOUNDSECRET		= 28;
float	SVC_SPAWNSTATICSOUND	= 29;	// 1998-08-08 Complete SVC list by Zhenga
float	SVC_INTERMISSION	= 30;
float	SVC_FINALE		= 31;
float	SVC_CDTRACK		= 32;
float	SVC_SELLSCREEN		= 33;
//float	SVC_CUTSCENE		= 34;	// 1998-08-08 Complete SVC list by Zhenga

float   SVC_SMALLKICK           = 34;
float   SVC_BIGKICK                     = 35;
float   SVC_MUZZLEFLASH         = 39;

//temporary entity types
float	TE_SPIKE		= 0;
float	TE_SUPERSPIKE   	= 1;
float	TE_GUNSHOT		= 2;
float	TE_EXPLOSION    	= 3;
float	TE_TAREXPLOSION	        = 4;
float	TE_LIGHTNING1    	= 5;
float	TE_LIGHTNING2   	= 6;
float	TE_WIZSPIKE		= 7;
float	TE_KNIGHTSPIKE   	= 8;
float	TE_LIGHTNING3   	= 9;
float	TE_LAVASPLASH   	= 10;
float	TE_TELEPORT		= 11;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;

float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

// update types
float	UPDATE_GENERAL	= 0;
float	UPDATE_STATIC	= 1;
float	UPDATE_BINARY	= 2;
float	UPDATE_TEMP	= 3;

// entity effects
float	EF_BRIGHTFIELD	= 1;
float	EF_MUZZLEFLASH 	= 2;
float	EF_BRIGHTLIGHT 	= 4;
float	EF_DIMLIGHT 	= 8;
float   EF_FLAG1                = 16;
float   EF_FLAG2                = 32;
float 	EF_BLUE		=	64;	// Blue Globe effect for Quad
float	EF_RED		=	128;	// Red Globe effect for Pentagram


// messages
float	MSG_BROADCAST	= 0;		// unreliable to all
float	MSG_ONE			= 1;		// reliable to one (msg_entity)
float	MSG_ALL			= 2;		// reliable to all
float	MSG_INIT		= 3;		// write to the init string

//wait times
const float WAIT_FOREVER = -1;
const float WAIT_AUTO = -2;

//skills
float SKILL_EASY = 0;
float SKILL_NORMAL = 1;
float SKILL_HARD = 2;

//water levels
const float WLEV_Out = 0;
const float WLEV_Feet = 1;
const float WLEV_Waist = 2;
const float WLEV_Eyes = 3;

// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
float   MOVETYPE_ANGLENOCLIP    = 1;
float   MOVETYPE_ANGLECLIP              = 2;
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_BOUNCEMISSILE	= 11;	// bounce with extra size

// edict.solid values
float	SOLID_NOT				= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX				= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block

// deadflag values

float	DEAD_NO					= 0;
float	DEAD_DYING				= 1;
float	DEAD_DEAD				= 2;
float	DEAD_RESPAWNABLE		= 3;

// takedamage values

float	DAMAGE_NO				= 0;
float	DAMAGE_YES				= 1;
float	DAMAGE_AIM				= 2;

// point content values

float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float   CONTENT_SKY                     = -6;

// frame lengths
const float standard_framelen = 0.1;
const float hitscan_ai_shoot_dot = 0.9;

// impulses
const float IMPULSE_ItemCheat = 9;
