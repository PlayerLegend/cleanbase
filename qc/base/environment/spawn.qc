//==============================================================================
//
//    spawn.qc - functions used by spawn functions
//
//==============================================================================

void check_remove()//entity determines if it should remove itself
{
  if( deathmatch && (self.spawnflags & NOT_IN_DEATHMATCH))
    remove( self );
  if( (world.skill == SKILL_EASY) && (self.spawnflags & NOT_ON_EASY) )
    remove( self );
  else if( (world.skill == SKILL_NORMAL) && (self.spawnflags & NOT_ON_NORMAL) )
    remove( self );
  else if( (world.skill == SKILL_HARD) && (self.spawnflags & NOT_ON_HARD) )
    remove( self );
}
//setup subs for door and door_secret respectively
void setup_startend()
{
  if( self.start_origin || self.end_origin )
    {
      self.movedir = normalize( self.end_origin - self.start_origin );
      if( !self.movedist )
	self.movedist = vlen( self.end_origin - self.start_origin );
    }
  else if( !self.movedir )
    {
      if( self.angle == -1 )
	self.movedir = '0 0 1';
      else if( self.angle == -2 )
	self.movedir = '0 0 -1';
      else
	{
	  makevectors( [0, self.angle, 0] );
	  self.movedir = v_forward;
	}
    }
  if( !self.movedist )
    self.movedist = fabs(self.movedir*self.size) - self.lip;
  
  self.start_origin = self.origin;
  self.end_origin = self.movedist*self.movedir + self.origin;
  if( self.spawnflags & DOOR_TOGGLE )
    reverse_motion();
}
void setup_startmidend()
{
  vector crossvec = '0 0 1';
  vector movedir2;
  float movedist2;
  setup_startend();
  if( self.mid_origin )
    return;
  if( self.spawnflags & SECRET_1ST_LEFT )
    movedir2 = normalize(crossprod( self.movedir, -crossvec ));
  else if( self.spawnflags & SECRET_1ST_DOWN )
    movedir2 = '0 0 -1';
  else
    movedir2 = normalize(crossprod( self.movedir, crossvec ));
  movedist2 = fabs(movedir2*self.size);
  self.end_origin += movedist2*movedir2;
  self.mid_origin = self.start_origin + movedist2*movedir2;
}
//door
//setdefaults: assign default values to unset fields
void setdefaults_general()
{
  if( !self.dmg )
    self.dmg = 2;
  if( !self.damage )
    self.damage = self.dmg;

  if( self.touch_include == 0 )
    self.touch_include = TOUCHFL_Player;
  else if( self.touch_include < 0 )
    self.touch_include = 0;

  if( world.cleanbase_version == 0 )
    {
      if( self.angles != '0 0 0' )
	{
	  if( self.classname != "env_teleport_out" )
	    {
	      self.angle = self.angles_y;
	      self.angles = '0 0 0';
	    }
	}
    }

  if( self.count < 0 )
    self.count = count_targeters();
}
void setdefaults_trigger_setvelocity()
{
  setdefaults_general();

  if( self.set_velocity == '0 0 0' )
    {
      if( self.angle == -1 )
	self.set_velocity = '0 0 10'*self.speed;
      else if( self.angle == -2 )
	self.set_velocity = '0 0 -10'*self.speed;
      else
	{
	  makevectors([ 0, self.angle, 0 ]);
	  self.set_velocity = v_forward*self.speed*10;
	}
    }
}
void setdefaults_train()
{
  setdefaults_general();

  if( !self.speed )
    self.speed = 100;

}
void door_clone( entity cdoor ) //merge important values between self and cdoor, used to link doors
{
  if( self.targetname == "" )
    settargetname( self, cdoor.targetname );
  else
    settargetname( cdoor, self.targetname );

  if( !self.wait )
    self.wait = cdoor.wait;
  else
    cdoor.wait = self.wait;

  if( !self.health )
    self.health = cdoor.health;
  else
    cdoor.health = self.health;
  if( !self.delay )
    self.delay = cdoor.delay;
  else
    cdoor.delay = self.delay;
}
void setdefaults_door_secret()
{
  setdefaults_general();

  if( self.spawnflags & SECRET_OPEN_ONCE )
    self.wait = WAIT_FOREVER;
  if( self.count < 0 )
    self.count = count_targeters();

  if( !self.speed )
    self.speed = 50;

  if( incrange( self.wait, 0, ENV_SHORTTHINK) )
    self.wait = 3;

  if( !(self.spawnflags & SECRET_NO_SHOOT) && (self.targetname == "") )
    {
      self.health = 1;
      self.max_health = 1;
      self.takedamage = DAMAGE_YES;
    }

  if( self.health && (self.targetname == "")  )
    {
      self.max_health = self.health;
      self.takedamage = DAMAGE_YES;
    }
  if( self.target != "" )
    {
      if( !self.fl_evtype )
	self.fl_evtype = (EVENT_Activate);
    }

  setup_startmidend();
}
void setdefaults_door()
{
  setdefaults_general();

  if( !self.speed )
    self.speed = 100;

  if( incrange( self.wait, 0, ENV_SHORTTHINK) )
    self.wait = 3;

  if( !self.lip )
    self.lip = 8;
  
  if( self.health )
    {
      self.max_health = self.health;
      self.takedamage = DAMAGE_YES;
    }
  if( self.target != "" )
    {
      if( !self.fl_evtype )
	self.fl_evtype = (EVENT_Activate);
    }

  if( !self.field_size )
    self.field_size = '60 60 8'*2;

  setup_startend();
  self.angles = '0 0 0';

  if( self.spawnflags & DOOR_START_OPEN )
    reverse_reciprocator();
  if( self.spawnflags & DOOR_TOGGLE )
    reverse_motion();
}
void setdefaults_button()
{
  setdefaults_general();

  if( !self.speed )
    self.speed = 40;

  if( !self.lip )
    self.lip = 4;

  if( incrange( self.wait, 0, ENV_SHORTTHINK ) )
    self.wait = 1;
  
  if( self.health )
    {
      self.max_health = self.health;
      self.takedamage = DAMAGE_YES;
    }

  if( !self.fl_evtype )
    self.fl_evtype = (EVENT_Activate);
  setup_startend();
}
void setdefaults_trigger_bsp()
{
  setdefaults_general();

  switch( self.classname )
    {
    case "trigger_kill":
      self.fl_evtype |= (EVENT_Kill);
      break;
    case "trigger_hurt":
      self.fl_evtype |= (EVENT_Damage);
      break;
    case "trigger_setval":
      self.fl_evtype |= (EVENT_SetVal);
      break;
    case "trigger_turnon":
      self.fl_evtype |= (EVENT_TurnOn);
      break;
    case "trigger_turnoff":
      self.fl_evtype |= (EVENT_TurnOff);
      break;
    case "trigger_toggleon":
      self.fl_evtype |= (EVENT_ToggleOn);
      break;
    default:
      self.fl_evtype |= (EVENT_Activate);
    }

  if( !self.wait )
    self.wait = 2*ENV_SHORTTHINK;
}
void setdefaults_plat()
{
  setdefaults_general();

  if( !self.field_size )
    self.field_size = '25 25 0';

  if( !self.speed )
    self.speed = 150;

  if( incrange( self.wait, 0, ENV_SHORTTHINK ) )
    self.wait = 2;

  if( !self.lip )
    self.lip = 8;

  if( self.height )
    self.movedist = self.height;

  self.angle = -1;
  setup_startend();
  shift_startend( [0,0,-self.movedist] );
}
void setdefaults_teleporter()
{
  setdefaults_general();

  setorigin( self, self.origin );
}
void init_switching() //run on anything that can be turned on or off
{
  self.event_flags |= (EVFL_Switchable);
  switch( self.classname )
    {
    default:
      self.onsound = "sound/misc/power.wav";
      self.offsound = "sound/misc/buzz1.wav";
      self.isoffsound = "sound/misc/menu2.wav";
      break;
    }
  if( !(self.extra_spawnflags & ESF_BeginOff) )
    event_turnon( self );
}
void init_bspent() //run on anything that is a solid bsp type entitiy
{
  check_remove();
  self.solid = SOLID_BSP;
  self.movetype = MOVETYPE_PUSH;
  setorigin( self, self.origin );	
  setmodel( self, self.model );
  self.damageratio = 1;
}
void init_reciprocator() //run on things that reciprocate, like buttons and doors, requires setup_startend or setup_startmidend to have been run
{
  if( self.mid_origin != '0 0 0' )
    self.goal_origin = self.mid_origin;
  self.nextthink = ENV_STOPTHINK;
  self.velocity = '0 0 0';
}
void init_trigger()
{
  settargetname( self, self.targetname );
  settarget( self, self.target );
  self.counter = 0;
}
void start_ambient_sound()
{
  string snd = "";
  float vol = 0.5, attn = ATTN_STATIC;
  switch( self.classname )
    {
    case "ambient_comp_hum":
      snd = "ambience/comp1.wav";
      vol = 1;
      break;
    case "ambient_drip":
      snd = "ambience/drip1.wav";
      break;
    case "ambient_drone":
      snd = "ambience/drone6.wav";
      break;
    case "ambient_fluoro_buzz"://check this and other buzz
      snd = "ambience/buzz1.wav";
      vol = 1;
      break;
    case "ambient_light_buzz":
      snd = "ambience/fl_hum1.wav";
      break;
    case "ambient_suck_wind":
      snd = "ambience/suck1.wav";
      vol = 1;
      break;
    case "ambient_swamp1":
      snd = "ambience/swamp1.wav";
      break;
    case "ambient_swamp2":
      snd = "ambience/swamp2.wav";
      break;
    case "ambient_thunder":
      snd = "ambience/thunder1.wav";
      break;
    }
  precache_sound( snd );
  ambientsound( self.origin, snd, vol, attn );
  self.think = SUB_Null;
}
void init_torch()
{
  string mdl = "";
  switch( self.classname )
    {
    default:
    case "light_torch_small_walltorch":
      mdl = "progs/flame.mdl";
      break;
    case "light_flame_large_yellow":
      mdl = "progs/flame2.mdl";
      self.frame = 1;//without this, it's a small flame. No idea how these animate
      break;
    case "light_flame_small_yellow":
      mdl = "progs/flame2.mdl";
      break;
    case "light_flame_small_white":
      mdl = "progs/flame2.mdl";
      break;
    }
  precache_model( mdl );
  setmodel( self, mdl );
  
  precache_sound ("ambience/fire1.wav");
  ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);

  makestatic( self );
}
