//==============================================================================
//
//    Framework
//
//==============================================================================
void generic_perform_best_action();
void generic_scan()
{
  entity cursor;
  if( !self.enemy )
    {
      for( cursor = world; (cursor = find( cursor, classname, "player" )); )
	{
	  traceline( self.origin, cursor.origin, FALSE, cursor );
	  if( trace_fraction == 1.0 )
	    {
	      self.action_finished = time;
	      self.enemy = cursor;
	      return;
	    }
	}
    }
}
void th_ai_generic()
{
  self.nextthink = time;
  if( self.nextframe < time )
    {
      self.sub_scan();
      ai_frametime = standard_framelen;
      //pre think setup
      makevectors( self.angles );
      self_forward = v_forward;
      self_right = v_right;
      self_up = v_up;
      enemy_range = get_enemy_range();
      ai_start_walkmove( 0, '0 0 0' );
      if( self.enemy )
	{
	  enemy_speed = vlen( self.enemy.velocity );
	  traceline( self.origin, self.enemy.origin, FALSE, self.enemy );
	  enemy_trace_fraction = trace_fraction;
	}
      else
	{
	  enemy_speed = 0;
	  enemy_trace_fraction = 0;
	}
      if( enemy_trace_fraction == 1.0 )
	self.sight_time = fmax( 0, self.sight_time + ai_frametime );
      else
	self.sight_time = fmin( 0, self.sight_time - ai_frametime );
      if( self.goalentity )
	{
	  goal_dir = self.goalentity.origin - self.origin;
	  goal_dir_z = 0;
	  goal_dir = normalize( goal_dir );
	}
      else
	goal_dir = '0 0 0';

      //think
      if( self.sub_animation == SUB_Null )
	self.default_animation();
      else
	self.sub_animation();
      
      //choose think if applicable
      if( incrange( self.action_finished, 0, time ) )
	generic_perform_best_action();

      self.maxpain = 0;
      self.blocked_dir = '0 0 0';
    }
  //finish up
  ai_apply_turn();
  if( ai_checkbottom() )//checkbottom is unreliable
    ai_execute_move();
  self.velocity = self.velocity + self.gravitydir*cvar("sv_gravity")*frametime;
}
