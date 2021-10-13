//==============================================================================
//
//    spawn_bspmobs.qc: moving bsp entities
//
//==============================================================================

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//train
void env_train_stage1()//requires entities spawned
{
  setdefaults_train();
  self.blocked = SUB_Null;
  self.think = th_train;
  self.nextthink = TIME_WORLDSTART;
  init_trigger();
  self.fl_evtype |= (EVENT_Activate);
  //compat
  setorigin( self, self.e_target.origin - self.mins );
  if( self.targetname != "" )
    self.nextthink = ENV_STOPTHINK;
}
void env_train()
{
  init_bspent();
  init_switching();
  self.think = env_train_stage1;
  self.nextthink = TIME_POST_EVENTSPAWN;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//secret door
void env_door_secret_stage1()
{
  self.blocked = block_reciprocator;
  self.sub_pain = sub_shootable_pain;
  self.think = th_door_secret;
  init_trigger();
}
void env_door_secret()
{
  init_switching();
  self.classname = "env_door_secret";
  init_bspent();
  setdefaults_door_secret();
  init_reciprocator();
  self.think = env_door_secret_stage1;
  self.nextthink = TIME_POST_ENTSPAWN;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//door
void env_door_stage2()//requires doors linked
{
  self.blocked = block_reciprocator;
  self.sub_pain = sub_shootable_pain;
  self.think = th_door;
  init_trigger();
}
void env_door_stage1()//requires entitites spawned
{
  entity cursor, trig;
  vector dmins = self.mins, dmaxs = self.maxs;
  if( !(self.spawnflags & DOOR_DONT_LINK ) ) //link touching doors
    {
      for( cursor = world; (cursor = find( cursor, classname, "env_door")); )
	{
	  if( bsptouch(self, cursor) && (self != cursor) && !(cursor.spawnflags & DOOR_DONT_LINK) )
	    door_clone( cursor );
	}
    }
  if( self.targetname == "" )//none of the collected doors had a targetname, work based on proximity
    {
      settargetname( self, unique_name() );//unique targetname
      for( cursor = world; (cursor = find( cursor, classname, "env_door")); )//collect with new targetname
	{
	  if( bsptouch(self, cursor) && (self != cursor) && !(cursor.spawnflags & DOOR_DONT_LINK) )
	    {
	      door_clone( cursor );
	      if( cursor.mins_x < dmins_x )//get a total size for the door
		dmins_x = cursor.mins_x;
	      if( cursor.mins_y < dmins_y )
		dmins_y = cursor.mins_y;
	      if( cursor.mins_y < dmins_y )
		dmins_y = cursor.mins_y;
	      
	      if( cursor.maxs_x > dmaxs_x )
		dmaxs_x = cursor.maxs_x;
	      if( cursor.maxs_y > dmaxs_y )
		dmaxs_y = cursor.maxs_y;
	      if( cursor.maxs_y > dmaxs_y )
		dmaxs_y = cursor.maxs_y;
	    }
	}
      
      trig = spawn_trigger( dmins - (0.5*self.field_size), dmaxs + (0.5*self.field_size), self.targetname, "" );
      trig.achan_incl = self.achan;
      trig.touch_include = self.touch_include;
      trig.wait = WAIT_AUTO;//trigger calculates wait
    }
  self.think = env_door_stage2;
  self.nextthink = TIME_POST_ENTLINK;
}
void env_door()
{
  self.classname = "env_door";
  init_bspent();//must be run for bsptouch to work
  setdefaults_door();
  init_switching();
  init_reciprocator();
  self.think = env_door_stage1;
  self.nextthink = TIME_POST_ENTSPAWN;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//button
void env_button_stage1()//requires entities spawned
{
  init_trigger();
  self.touch = touch_button;
  self.blocked = reverse_motion;
  self.think = th_button;
  self.sub_pain = sub_shootable_pain;
  self.nextthink = ENV_STOPTHINK;
}
void env_button()
{
  init_switching();
  self.classname = "env_button";
  init_bspent();
  setdefaults_button();
  init_reciprocator();

  self.think = env_button_stage1;
  self.nextthink = TIME_POST_ENTSPAWN;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//plat
void env_plat_stage1()
{
  init_trigger();
  init_reciprocator();
  self.think = th_plat;
  self.blocked = block_reciprocator;
}
void env_plat()
{
  entity trig;
  vector max, min;
  init_switching();
  self.classname = "env_plat";
  init_bspent();
  setdefaults_plat();
  if( self.targetname == "" )//spawn a trigger
    {
      settargetname( self, unique_name() );
      
      trig = spawn();
      min = self.mins + self.field_size + self.origin;
      if( self.spawnflags & PLAT_LOW_TRIGGER )
	max = self.origin + self.maxs + '0 0 16';
      else
	max = self.origin + self.maxs + (self.end_origin - self.start_origin) - self.field_size + '0 0 8';
      trig = spawn_trigger( min, max, self.targetname, "" );

      trig.achan_incl = self.achan;
      trig.touch_include = self.touch_include;
      trig.wait = WAIT_AUTO; //trigger calculates wait
    }
  self.think = env_plat_stage1;
  self.nextthink = TIME_POST_ENTSPAWN;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  original quake functions
void func_button()
{
  env_button();
}
void func_door()
{
  env_door();
}
void func_door_secret()
{
  env_door_secret();
}
void func_train()
{
  self.classname = "env_train";
  env_train();
}
void func_plat()
{
  self.nextthink = random();
  self.think = env_plat;
  //env_plat();
}
