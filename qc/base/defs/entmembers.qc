//================================================================
//
//    entmembers.qc: definitions of entity members
//
//================================================================

//linked lists
.list_t ll_up; //up in a double linked list
.list_t ll_down; //down in a double linked list
.entity l_main; //further in the main single linked list
.entity l_targetname; //further in the targetname single linked list

//world
.string wad, map;
.float worldtype, delay, wait, lip, light_lev, speed, style, skill;
.string killtarget;
.vector mangle;
.float cleanbase_version;

//general
.float wait_finished;// time when wait is over
.float gen_flags; //general flags, entity specific
.float touch_identity; //works with above
.float angle; //yaw angle

//client
.float last_noise;
.float power_finished[MAX_POWERS];// timers for powerups
.entity killedby; //set when killed
.float damageratio; //damage taken is multiplied by this
.float ammo[MAX_AMMOTYPE]; //ammo count
.float maxammo[MAX_AMMOTYPE]; //max value for corresponding .ammo[]
.float lastdrowndamage; //used to time drowning/lava/slime damage
/*.float button3;
.float button4;
.float button5;
.float button6;
.float button7;
.float button8;
.float button9;
.float button10;
.float button11;
.float button12;
.float button13;
.float button14;
.float button15;
.float button16;*///for FTE or darkplaces
.float ammotype; //used for ammo/max_ammo
.float breathtime; //seconds value, increases when out of water, decreases while in water, is set to zero when going from in water to out of water and vice versa
.float lastwaterlevel; //waterlevel from previous frame
.float lastspawn; //last spawn number
.float max_health; //maximum health
.float max_superhealth;  //maximum superhealth
.float cl_thinktype; //governs how PlayerPrethink and PlayerPostthink are run
.float startframe, finalframe; //the first and last frames in an entity's animation
.float nextframe;  //the time when the frame will be changed
.float ranim;        //used to select a random animation
.float weaponstartframe;//The start frame of the viewmodel's animation. Like .startframe, but for .weaponframe
.void() weapon_action[WEAP_ACTIONS];//function pointers to weapon actions
.float weaponwait;//time when the player's weapon will be useable/switchable again
.float weaponslot[WEAP_SLOTS];//contains a weapon id for that weapon slot
.float weaponslotnum;//the current weapon slot, applicable .weaponslot
.void() sub_animation;//the currently playing playermodel animation
.float animcount; //number of times an animation has played
.void() default_animation;//playermodel animation to play if sub_animation is set to SUB_Null
.float weaponid;//the currently selected weapon's id
.float currentammo;//ammo displayed on hud

// trigger details
.float achan; //bitfield, activation channel, activated by entities with like achan_incl, 0 values are activated only by other 0 values
.float achan_incl; // described above, like achan but for activator rather than activatee
.float touch_include;  //bitfield, allows .touch functions to determine if two things should touch. see enums.qc for values
.vector field_size; //if set, this will be the size of the automatically spawned trigger on applicable things
.float trigger_ready; //time when the trigger can be activated again
// things for event_setval to use
.float set_fl_evtype, set_achan, set_achan_incl, set_speed, set_touch_identity;
.vector set_velocity;
.string set_target, set_targetname;
.float fl_setvals; //when using EVENT_SetVal, what values to set
.entity trigger_activator; //activated by this
.entity e_target; //entity list reflected by .target
.float event_flags; //Flags to configure event related behavior
.float damage, dmg; //trigger hurt and crush damage, these should equal each other or one should be zero, they are redundant. .damage should be the value used most everywhere
.float fl_evtype; //bitfield, describes the events that will be executed when trigger_activate is run
.float delay; //activation delay
.float fl_buttons;//this mirrors the button values as a set of flags
.float fl_heldbuttons;//these flags are turned on when needed, not automatically. if at any time a button is not held, it's flag is turned off
.float extra_flags;//for mods, the reason being that some regular .flags values matter to the engine

//bsp mobiles
.float move_state;
.float movedist; //move distance
.vector movedir; //Move direction
.vector goal_origin, start_origin, mid_origin, end_origin; //used for reciprocating things, door/button/plat
.string onsound, offsound, isoffsound;//onsound is played when turned on, offsound is played when turned off, and isoffsound is played if activated while off
.float oneffect, offeffect, isoffeffect; //these are passed to switch statements to determine what effects to do when turned off, turned on, or activated while off.
.float extra_spawnflags;//used for new things to be sure that there aren't any conflicts with regular spawnflags
.float counter;//used to count up to .count
.float count;//static value from map
.float height;//used by env_plat

//items
.float vismodel_index; //used to remember modelindex when an entity is made invisible

//murders and executions
.float bloodtype;//describes how the entity bleeds
.float maxpain;//the most damage that was taken from a single source, reset every frame
.float painid;//the pain id of maxpain
.float painfl;//flags describing the pain type gotten from maxpain
.void( entity taker, float damageval, float fl_damage, float id_damage ) sub_pain;//run when the entity is hurt
.void() sub_die;//run when the entity dies

//ai stuff
.float aitype;
.float max_actions;
.float current_action;
.float action_finished;
.vector gravitydir;
.vector blocked_dir;
.vector move_dir;
.void() sub_scan;
.float last_attacked;
.float last_action;
.float sight_time;
.vector wishdir;
.float wishspeed;
.vector wishangles;
.float turnspeed;
