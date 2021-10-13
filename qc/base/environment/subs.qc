//==============================================================================
//
//    environment subs
//
//==============================================================================

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  misc
float reciprocator_traveltime( entity tgt )
{
  return vlen( self.goal_origin - self.origin )/self.speed;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//movement
void reverse_reciprocator()//reverses the start/end of a reciprocator.
{
  self.movedir = -self.movedir;
  setorigin( self, self.end_origin );
  self.end_origin = self.start_origin;
  self.start_origin = self.origin;
}
void reverse_motion()
{
  if( self.mid_origin )
    {
      if( self.goal_origin != self.mid_origin )
	self.goal_origin = self.mid_origin;
      else if( self.velocity )
	{
	  if( fabs(self.velocity*self.movedir) > COS_45 )
	    self.goal_origin = self.end_origin;
	  else
	    self.goal_origin = self.start_origin;
	}
      else
	{
	  if( vlen( self.origin - self.start_origin ) < vlen( self.origin - self.end_origin ) )
	    self.goal_origin = self.start_origin;
	  else
	    self.goal_origin = self.end_origin;
	}
    }
  else
    {
      if( self.goal_origin == self.end_origin )
	self.goal_origin = self.start_origin;
      else
	self.goal_origin = self.end_origin;
    }
}
float sub_bsppath( vector point, vector selforg )
{
  vector displ;
  float dist;
  vector dir;
  float est_nextthink;
  vector finalvel;
  
  displ = point - selforg;
  if( sqlen( displ ) < 1 )
    return 0;
  dist = vlen( displ );
  dir = normalize( displ );
  est_nextthink = dist/self.speed;
  finalvel = self.speed*dir;

  if( est_nextthink < ENV_SHORTTHINK )
    {
      est_nextthink = ENV_SHORTTHINK;
      finalvel = displ/ENV_SHORTTHINK;
    }
  self.velocity = finalvel;
  self.nextthink = self.ltime + est_nextthink;
  return 1;
}
float bsp_reciprocate()//move like a door, button, or plat
{
  float ret = -1;
  if( !sub_bsppath( self.goal_origin, self.origin ) )
    {
      self.velocity = '0 0 0';
      if( self.spawnflags & DOOR_TOGGLE )
	{
	  self.nextthink = ENV_STOPTHINK;
	  ret = 0;
	}
      else if( self.goal_origin == self.start_origin )
	{
	  self.nextthink = ENV_STOPTHINK;
	  ret = 0;
	  reverse_motion();
	}
      else
	{
	  self.nextthink = self.ltime + self.wait;
	  ret = 1;
	  reverse_motion();
	}
    }
  return ret;
}
void reverse_startend()
{
  vector tmp = self.start_origin;
  self.start_origin = self.end_origin;
  self.end_origin = tmp;

  setorigin( self, self.start_origin );
  self.goal_origin = self.end_origin;
}
void shift_startend( vector shift )
{
  self.start_origin += shift;
  self.end_origin += shift;

  setorigin( self, self.start_origin );
  self.goal_origin = self.end_origin;
}
float bsptouch( entity e1, entity e2 ) //entities must have run init_bspent to work
{
  if( e1.mins_x > e2.maxs_x || e1.mins_y > e2.maxs_y || e1.mins_z > e2.maxs_z ||
      e2.mins_x > e1.maxs_x || e2.mins_y > e1.maxs_y || e2.mins_z > e1.maxs_z )
    return FALSE;
  else
    return TRUE;
}
void setdefaults_trigger_bsp();
void touch_trigger();
void th_trigger();
void init_switching();
entity spawn_trigger( vector minsize, vector maxsize, string starget, string stargetname )
{
  entity stemp, trig = spawn();
  settarget( trig, starget );
  settargetname( trig, stargetname );
  stemp = self;
  self = trig;
  setdefaults_trigger_bsp();
  init_switching();
  self = stemp;
  trig.touch_include = TOUCHFL_Player;
  trig.classname = "trigger_bsp";
  trig.solid = SOLID_TRIGGER;
  trig.touch = touch_trigger;
  trig.think = th_trigger;
  trig.fl_evtype = (EVENT_Activate);
  setsize( trig, minsize, maxsize );
  return trig;
}
