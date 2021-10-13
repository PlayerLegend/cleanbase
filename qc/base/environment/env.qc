//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  used for a bunch of things
void sub_shootable_pain( entity taker, float damageval, float fl_damage, float id_damage )
{
  entity stemp = self;
  self = taker;//taker will be the button
  if( self.health < 1 )
    {
      self.health = self.max_health;
      self.trigger_activator = stemp;
      run_event( self, event_activate );
    }
  self = stemp;
}
void block_reciprocator()
{
  sub_autohurt();
  if( other.health >= 1 )
    {
      reverse_motion();
      self.think();
    }
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_levelchanger
void th_levelchanger()
{
  if( self.event_flags & EVFL_Activated )
    changelevel( self.map );
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_trigger
void th_trigger()
{
  if( self.event_flags & EVFL_Activated )
    {
      self.event_flags &= ~EVFL_Activated;
      trigger_activate( self.fl_evtype, GENFL_ActivateAuto, self.achan_incl );
    }
}
void touch_trigger()
{
  force_retouch = 2;
  if( !other.movetype || (other.movetype == MOVETYPE_PUSH) )
    return;
  if( !(other.touch_identity & self.touch_include) )
    return;
  self.trigger_activator = other;
  trigger_activate( self.fl_evtype, GENFL_ActivateAuto, self.achan_incl );
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_teleporter
void th_teleporter()
{
  self.event_flags &= ~EVFL_Activated;
  if( self.trigger_activator ) //be sure it won't modify world
    {
      float ran = 4*random();
      entity tact = self.trigger_activator;
      entity tmp;

      makevectors(self.angles);
      self_forward = v_forward;
      self_right = v_right;
      self_up = v_up;
      makevectors([-3*tact.angles_x, tact.angles_y, tact.angles_z]);

      tmp = sub_telefrag( self.origin, vlen( self.trigger_activator.size )/1.9 , self.trigger_activator );
      if( tmp )
	{
	  tact.solid = SOLID_NOT;
	  sub_damage( tmp, tact, 500000, FL_Null, DAMID_Telefrag );
	}
      setorigin( tact, self.origin );
      tact.velocity = 
	(self_forward*(fabs(v_forward*tact.velocity) + 100) +
	 self_right*(v_right*tact.velocity) +
	 self_up*(v_up*tact.velocity));
      tact.angles = self.angles;
      tact.fixangle = 1;
      
      WriteByte( MSG_BROADCAST, SVC_TEMPENTITY );
      WriteByte( MSG_BROADCAST, TE_TELEPORT );
      WriteCoord( MSG_BROADCAST, self.origin_x );
      WriteCoord( MSG_BROADCAST, self.origin_y );
      WriteCoord( MSG_BROADCAST, self.origin_z );

      if( ran < 1 )
	sound( self, CHAN_VOICE, "misc/r_tele1.wav", 1, ATTN_NORM );
      else if( ran < 2 )
	sound( self, CHAN_VOICE, "misc/r_tele2.wav", 1, ATTN_NORM );
      else if( ran < 3 )
	sound( self, CHAN_VOICE, "misc/r_tele3.wav", 1, ATTN_NORM );
      else if( ran < 4 )
	sound( self, CHAN_VOICE, "misc/r_tele4.wav", 1, ATTN_NORM );
      else
	sound( self, CHAN_VOICE, "misc/r_tele5.wav", 1, ATTN_NORM );
    }
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_train
void th_train()
{
  self.event_flags &= ~EVFL_Activated;
  
  if( !sub_bsppath( self.e_target.origin - self.mins, self.origin ) )
    {
      self.velocity = '0 0 0';
      self.trigger_activator = self;
      trigger_activate( self.fl_evtype, (GENFL_ActivateAuto | GENFL_NoReadyModification), self.achan_incl );
    }
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_door
void th_door()
{
  if( self.event_flags & EVFL_Activated )
    {
      self.event_flags &= ~EVFL_Activated;
      trigger_activate( self.fl_evtype, (GENFL_ActivateAuto | GENFL_NoReadyModification), self.achan_incl );
      self.trigger_ready = predict_ready_time( self ) - ENV_SHORTTHINK;//subtract ENV_SHORTTHINK to give triggers time to act on the door before it returns
      if( !(self.spawnflags & DOOR_TOGGLE) )
	self.goal_origin = self.end_origin;
      else
	reverse_motion();
    }
  bsp_reciprocate();
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_door_secret
void th_door_secret()
{
  if( self.event_flags & EVFL_Activated )
    {
      self.event_flags &= ~EVFL_Activated;
      trigger_activate( self.fl_evtype, (GENFL_ActivateAuto | GENFL_NoReadyModification), self.achan_incl );
      
      self.trigger_ready = predict_ready_time( self ) - ENV_SHORTTHINK;
      if( self.move_state == 2 )
	{
	  self.move_state = 1;
	  self.goal_origin = self.end_origin;
	}
      else if( self.move_state > 2 )
	{
	  self.move_state = 0;
	  self.goal_origin = self.mid_origin;
	}
    }
  if( !sub_bsppath( self.goal_origin, self.origin ) )//this functions like a more complicated bsp reciprocate
    {
      self.velocity = '0 0 0';
      switch( self.move_state )
	{
	case 0://at mid_origin, moving to end
	  self.move_state = 1;
	  self.goal_origin = self.end_origin;
	  self.nextthink = self.ltime + 1;
	  break;
	case 1://at end_origin, moving back to mid
	  self.move_state = 2;
	  self.goal_origin = self.mid_origin;
	  self.nextthink = self.ltime + self.wait + ENV_SHORTTHINK;
	  break;
	case 2://at mid_origin, moving to start
	  self.move_state = 3;
	  self.goal_origin = self.start_origin;
	  self.nextthink = self.ltime + 1;
	  break;
	default://at start, movement is finished, set up for moving again and go to sleep
	  self.move_state = 0;
	  self.goal_origin = self.mid_origin;
	  self.nextthink = ENV_STOPTHINK;
	  break;
	}
    }
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_button
void th_button()
{
  if( self.event_flags & EVFL_Activated )
    {
      self.event_flags &= ~EVFL_Activated;
      self.trigger_ready = predict_ready_time( self ) - ENV_SHORTTHINK;
      self.goal_origin = self.end_origin;
    }
  if( bsp_reciprocate() == 1 )
    trigger_activate( self.fl_evtype, (GENFL_ActivateAuto | GENFL_IgnoreTriggerReady | GENFL_NoReadyModification), self.achan_incl );
}
void touch_button()
{
  force_retouch = 2;
  if( !(other.touch_identity & self.touch_include) )
    return;
  if( self.trigger_ready <= time )
    {
      self.trigger_activator = other;
      run_event( self, event_activate );
    }
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  env_plat
void th_plat()
{
  if( self.event_flags & EVFL_Activated )
    {
      self.event_flags &= ~EVFL_Activated;
      if( self.wait < 0 )
	self.trigger_ready = -1;
      else
	self.trigger_ready = predict_ready_time( self ) - ENV_SHORTTHINK;
      self.goal_origin = self.end_origin;
    }
  if( bsp_reciprocate() == 1 )
    trigger_activate( self.fl_evtype, (GENFL_ActivateAuto | GENFL_IgnoreTriggerReady | GENFL_NoReadyModification), self.achan_incl );
}
