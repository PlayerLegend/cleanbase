//==============================================================================
//
//    spawn_maplogic.qc: triggers, events
//
//==============================================================================


//level changer
void env_levelchanger()
{
  init_switching();
  self.think = th_levelchanger;
  self.nextthink = ENV_STOPTHINK;
}
//teleporter
void env_teleport_out_stage1()
{
  init_trigger();
  self.think = th_teleporter;
}
void env_teleport_out()
{
  self.classname = "env_teleport_out";
  if( self.angle )
    self.angles_y = self.angle;
  setdefaults_teleporter();
  setorigin( self, self.origin + '0 0 27' );
  
  precache_sound( "ambience/hum1.wav" );
  
  ambientsound( 0.5*(self.mins + self.maxs), "ambience/hum1.wav", 0.5, ATTN_STATIC );
  init_switching();
  self.think = env_teleport_out_stage1;
  self.nextthink = TIME_POST_ENTSPAWN;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//invisible trigger
void env_trigger_stage1()
{
  if( (self.model != "") || (self.classname == "spawned_trigger") )
    {
      self.touch = touch_trigger;
      if( self.health )
	{
	  self.damageratio = 1;
	  self.takedamage = DAMAGE_YES;
	  self.sub_pain = sub_shootable_pain;
	  self.solid = SOLID_BBOX;
	}
      else
	self.solid = SOLID_TRIGGER;
      setmodel( self, self.model );
      self.modelindex = 0;
      self.model = "";
    }
  init_trigger();
  self.think = th_trigger;
  self.nextthink = ENV_STOPTHINK;
}
void env_trigger()
{
  setdefaults_trigger_bsp();
  init_switching();
  self.nextthink = TIME_POST_ENTSPAWN;
  self.think = env_trigger_stage1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//trigger shortcuts - setup is done in setdefaults_trigger_bsp based
//                    on classname
void trigger_setval()
{
  self.classname = "trigger_setval";
  env_trigger();
}
void trigger_setvelocity()
{
  self.fl_setvals |= (SETVAL_Velocity);
  self.wait = ENV_SHORTTHINK;
  setdefaults_trigger_setvelocity();
  trigger_setval();
}
void trigger_push()
{
  trigger_setvelocity();
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  original quake functions

void info_teleport_destination()
{
  env_teleport_out();
}
void path_corner()
{
  if( !self.delay )
    self.delay = self.wait;
  self.set_target = self.target;//direct the train to your target
  self.target = "";//responds to trigger_activator
  self.fl_evtype = (EVENT_SetVal | EVENT_Activate);//change the train's target, wake the train up
  self.fl_setvals = (SETVAL_Target);//define what value to set
  env_trigger();
}
void trigger_hurt()
{
  env_trigger();
}
void trigger_multiple()
{
  env_trigger();
}
void trigger_once()
{
  self.wait = WAIT_FOREVER;
  env_trigger();
}
void trigger_onlyregistered()
{
  env_trigger();
}
void trigger_teleport()//default evtype is activate, will be pointed at a teleporter exit
{
  env_trigger();
}
void func_dm_only()
{
  if( !deathmatch )
    {
      remove(self);
      return;
    }
  self.classname = "env_trigger";
  env_trigger();
}
void trigger_counter()
{
  env_trigger();
}
void trigger_changelevel()
{
  init_bspent();
  self.targetname = unique_name();
  spawn_trigger( self.mins, self.maxs, self.targetname, "" );
  setsize( self, '0 0 0', '0 0 0' );
  self.modelindex = 0;
  self.solid = SOLID_NOT;
  env_levelchanger();
}
