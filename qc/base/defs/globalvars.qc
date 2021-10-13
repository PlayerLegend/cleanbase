//================================================================
//
//    globalvars.qc: definitions of global variables
//
//================================================================
//note: global variables should start with g_

//list things
list_t g_list_new;          //A new list begotten by some function
list_t g_list_extracted;    //A member extracted from a list, should be list_null'ed 

//static entity lists, single linked
entity g_l_playerspawns;

//stats
float g_playerspawncount;  //number of available spawns
float g_framenum;  //frame number

//these are v_forward, v_right, and v_up for the player
vector self_forward;
vector self_right;
vector self_up;

float enemy_trace_fraction;//set at the beginning of ai thinks, traceline from self to enemy, 0 if no enemy
float enemy_range;
vector goal_dir;
float ai_frametime;
float enemy_speed;
