//==============================================================================
//
//   trigger.qc - trigger framework
//
//==============================================================================

/*
  This file contains functions which act as a framework for general trigger-like behavior, allowing entities to activate and perform other actions on each other.
  Namely, this file is used by environment things, such as doors, buttons, trigger_multiple. Future additions, such as monsters, could make use of this as well, so it is kept in the general subs directory.
  Actions are in the 'events' section, the framework itself is in the 'trigger activation' section
 */
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  misc

float count_targeters()
{
  entity cursor;
  float val = 0;
  for( cursor = world; (cursor = find( cursor, target, self.targetname)); )
    val++;
  return val;
}
void print_trigger_message()
{
  if( self.count == 0 )
    return;
  if( self.counter >= self.count )
    {
      bprint("Sequence completed!\n");
      return;
    }
  if( self.counter == self.count - 1 )
    {
      bprint("There is 1 more to go.\n");
      return;
    }
  bprint("There are ");
  bprint(ftos(self.count - self.counter));
  bprint(" more to go.\n");
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  events

void event_damage( entity tgt )
{
  if( tgt.dmg && !tgt.damage )
    tgt.damage = tgt.dmg;
  sub_damage( world, tgt, self.damage, 0, DAMID_Mystery );
}
void event_kill( entity tgt )
{
  tgt.health = -1;
}
void event_setval( entity tgt )
{
  if( self.fl_setvals & SETVAL_Speed )
    tgt.speed = self.set_speed;
  if( self.fl_setvals & SETVAL_Damage )
    tgt.damage = self.damage;
  if( self.fl_setvals & SETVAL_Target )
    settarget( tgt, self.set_target );
  if( self.fl_setvals & SETVAL_Velocity )
    tgt.velocity = self.set_velocity;
}
void event_turnon( entity tgt )
{
  string snd;
  if( !(tgt.event_flags & EVFL_Switchable) )
    return;
  if( !(tgt.event_flags & EVFL_On) )
    {
      switch( tgt.oneffect )
	{
	default:
	  snd = tgt.onsound;
	  break;
	}
      sound( tgt, CHAN_VOICE, snd, 1, ATTN_NORM );
    }
  tgt.event_flags |= EVFL_On;
}
void event_turnoff( entity tgt )
{
  string snd;
  if( !(tgt.event_flags & EVFL_Switchable) )
    return;
  if( tgt.event_flags & EVFL_On )
    {
      switch( tgt.offeffect )
	{
	default:
	  tgt.velocity = '0 0 0';
	  snd = tgt.offsound;
	  break;
	}
      sound( tgt, CHAN_VOICE, snd, 1, ATTN_NORM );
    }
  tgt.event_flags &= ~EVFL_On;
  tgt.nextthink = -1;
}
void event_toggleon( entity tgt )
{
  if( tgt.event_flags & EVFL_On )
    event_turnoff( tgt );
  else
    event_turnon( tgt );
}
void event_activate( entity tgt )
{
  string snd;
  if( tgt.event_flags & EVFL_Activated ) //don't freeze tgt with spam
    return;
  if( !(tgt.event_flags & EVFL_On) )
    return;
  if( (tgt.event_flags & EVFL_Switchable) && !(tgt.event_flags & EVFL_On) )//if tgt is off, play an effect and stop
    {
      switch( tgt.isoffeffect )
	{
	default:
	  snd = tgt.isoffsound;
	}
      sound( tgt, CHAN_VOICE, snd, 1, ATTN_NORM );
      return;
    }
  tgt.event_flags |= EVFL_Activated;//turn on a flag so tgt can know it was activated
  if( self.delay < 0 )
    tgt.nextthink = ENV_STOPTHINK;
  else if( tgt != self )
    {
      tgt.trigger_activator = self.trigger_activator;
      if( (tgt.movetype == MOVETYPE_PUSH) )
	tgt.nextthink = tgt.ltime + ENV_SHORTTHINK + tgt.delay + self.delay;
      else
	tgt.nextthink = time + ENV_SHORTTHINK + tgt.delay + self.delay;
    }
  else
    {
      if( (tgt.movetype == MOVETYPE_PUSH) )
	{
	  if( !exrange((tgt.nextthink - tgt.ltime), 0, ENV_SHORTTHINK) )
	    tgt.nextthink = tgt.ltime + ENV_SHORTTHINK;
	}
      else
	{
	  if( !exrange((tgt.nextthink - time), 0, ENV_SHORTTHINK) )
	    tgt.nextthink = time + tgt.delay;
	}
    }
}
void event_setevent( entity tgt )
{
  tgt.fl_evtype = self.set_fl_evtype;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  trigger activation

void for_each_target( float chans, void( entity tgt ) dofunc )
{
  entity cnext = world, cursor = self.e_target;
  while( cursor )
    {
      cnext = cursor.l_targetname;
      if( (((!cursor.achan) && (!chans)) || (cursor.achan & chans)) && incrange( cursor.trigger_ready, 0, time ) )
	{
	  cursor.event_flags |= EVFL_Modified;
	  dofunc( cursor );
	}
      cursor = cnext;
    }
}
void for_activator( float chans, void( entity tgt ) dofunc )
{
  if( (((!self.trigger_activator.achan) && (!chans)) || (self.trigger_activator.achan & chans)) && incrange( self.trigger_activator.trigger_ready, 0, time ) )
    {
      self.trigger_activator.event_flags |= EVFL_Modified;
      dofunc( self.trigger_activator );
    }
}
//for_each is a function that applies a function based on .fl_evtype
void trigger_activate_foreach( float evtype, float chans, void( float, void( entity ) dofunc ) for_each )
{
  if( evtype & EVENT_Damage )
    for_each( chans, event_damage );
  
  if( evtype & EVENT_Kill )
    for_each( chans, event_kill );
  
  if( evtype & EVENT_SetVal )
    for_each( chans, event_setval );

  if( evtype & EVENT_TurnOn )//must come before EVENT_activate
    for_each( chans, event_turnon );
  
  if( evtype & EVENT_TurnOff )
    for_each( chans, event_turnoff );

  if( evtype & EVENT_ToggleOn )
    for_each( chans, event_toggleon );

  if( evtype & EVENT_Activate )
    for_each( chans, event_activate );
}
void trigger_activate( float evtype, float fl, float chans )
{
  if( !(fl & GENFL_IgnoreTriggerReady) && !incrange( self.trigger_ready, 0, time ) )
    return;
  if( !(self.event_flags & EVFL_On) )
    return;
  if( !(fl & GENFL_NoReadyModification) )
    {
      if( self.wait == WAIT_FOREVER )
	self.trigger_ready = -1;
      else if( self.wait == WAIT_AUTO )
	self.trigger_ready = predict_ready_time( self.e_target );//if a trigger has 0 wait, it will calculate it's wait based on a single target door
      else
	self.trigger_ready = time + self.wait;
    }
  self.counter++;
  print_trigger_message();
  if( self.counter < self.count )
    return;
  self.counter = 0;
  if( fl & GENFL_ActivateAuto )
    {
      if( self.e_target != world )
	trigger_activate_foreach( evtype, chans, for_each_target );
      else
	trigger_activate_foreach( evtype, chans, for_activator );
    }
  else
    {
      if( fl & GENFL_ActivateTargets )
	trigger_activate_foreach( evtype, chans, for_each_target );
      if( fl & GENFL_ActivateActivators )
	trigger_activate_foreach( evtype, chans, for_activator );
    }
}
void run_event( entity tgt, void( entity ) event_func ) //run an event outside of trigger_activate with proper safety checks
{
  if( !incrange( self.trigger_ready, 0, time ) )
    return;
  event_func( tgt );
}

