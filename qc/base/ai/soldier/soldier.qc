//==============================================================================
//
//    Actions
//
//==============================================================================
// standing . . .
void anim_soldier_stand()
{
  sub_animate( $stand1, $stand8, standard_framelen, FL_Null );
}
void ai_soldier_stand()
{
  self.sub_animation = anim_soldier_stand;
  self.action_finished = 1;
}
float ai_soldier_evaluate_stand()
{
  return AI_Unimportant;
}

// move to goalentity
void anim_soldier_run_to_goalentity()
{
  ai_start_turn( vectoangles(goal_dir), 90 );
  sub_animate( $run1, $run8, standard_framelen, FL_Null );
  ai_movetogoal( 100 );
}
void anim_soldier_walk_to_goalentity()
{
  ai_start_turn( vectoangles(goal_dir), 45 );
  sub_animate( $prowl_1, $prowl_24, standard_framelen, FL_Null );
  ai_movetogoal( 35 );
}
void anim_soldier_move_to_goalentity()
{
  if( self.enemy )
    anim_soldier_run_to_goalentity();
  else
    anim_soldier_walk_to_goalentity();
}
void ai_soldier_move_to_goalentity()
{
  self.sub_animation = anim_soldier_move_to_goalentity;
  self.action_finished = time + 1;
}
float ai_soldier_evaluate_move_to_goalentity()
{
  if( !self.goalentity )
    return AI_Impossible;
  if( (self.goalentity == self.enemy) && (enemy_trace_fraction != 1.0) )
    return AI_Impossible;
  if( (self.blocked_dir*(self.goalentity.origin - self.origin)) > 0 )
    return AI_Impossible;
  if( self.goalentity == self.enemy )
    {
      if( enemy_range == RANGE_Far )
	return AI_Urgent;
      //else if( exrange( self_forward*goal_dir, COS_45, hitscan_ai_shoot_dot ) )
      //return AI_Important;
      else
	return AI_Maybe;
    }
  else if( !self.enemy )
    return AI_Important;
  else
    return AI_Maybe;
}
// move in a random direction, usually when blocked
void anim_soldier_random_move()
{
  if( self.move_dir == '0 0 0' )
    self.move_dir = normalize( [crandom(), crandom(), 0] + 0.4*goal_dir);
  ai_start_turn( vectoangles(self.move_dir), 90 );
  if( !self.enemy )
    sub_animate( $prowl_1, $prowl_24, standard_framelen, FL_Null );
  else
    sub_animate( $run1, $run8, standard_framelen, FL_Null );
  if( test_walkmove( self.move_dir ) )
    {
      if( !self.enemy )
	{
	  if( self.animcount > 3 )
	    self.action_finished = time;
	  ai_start_walkmove( 35, self.move_dir );
	}
      else
	{
	  if( enemy_trace_fraction == 1.0 )
	    {
	      if( self.animcount > 1 )
		self.action_finished = time;
	    }
	  else
	    {
	      if( self.animcount > 4 )
		self.action_finished = time;
	    }
	  ai_start_walkmove( 100, self.move_dir );
	}
    }
  else
    {
      //      self.velocity = '0 0 0';
      self.wishdir = '0 0 0';
      if( (trace_plane_normal_x != 0) || (trace_plane_normal_y != 0) )
	{
	  self.move_dir = normalize(crossprod(trace_plane_normal, '0 0 1'));
	  if( self.enemy )
	    {
	      if( self.move_dir*(self.enemy.origin - self.origin) < 0 )
		self.move_dir = -self.move_dir;
	    }
	  else
	    {
	      if( random() > 0.5 )
		self.move_dir = -self.move_dir;
	    }
	}
      else
	{
	  //self.move_dir = '0 0 0';
	  self.move_dir = normalize( [random(), random(), 0] - self.move_dir );
	}
    }
}
void ai_soldier_random_move()
{
  self.move_dir = -self.blocked_dir;
  //sub_resetanimdata( self );
  self.animcount = 0;
  self.nextframe = 0;
  self.sub_animation = anim_soldier_random_move;
  self.action_finished = -1;
}
float ai_soldier_evaluate_random_move()
{
  //  return AI_Vital;
  if( enemy_trace_fraction == 1.0 )
    {
      if( (enemy_speed > 200) && (enemy_range < RANGE_Near) )
	return AI_Important;
    }
  else if( self.enemy )
    {
      if( self.goalentity == self.enemy )
	return AI_Urgent;
      else
	return AI_Maybe;
    }
  //else if( self.blocked_dir != '0 0 0' )
  //return AI_Important;
  else
    return AI_Unimportant;
}
// choose goalentity
void ai_soldier_choose_goalentity()
{
  if( !self.enemy )
    self.goalentity = self.e_target;
  else if( ((enemy_trace_fraction != 1.0) || (enemy_range == RANGE_Far)) && self.e_target )
    self.goalentity = self.e_target;
  else if( self.enemy )
    self.goalentity = self.enemy;
  else
    self.goalentity = self.e_target;
  self.action_finished = time;
}
float ai_soldier_evaluate_choose_goalentity()
{
  if( (!self.enemy) && (!self.goalentity) )
    return AI_Impossible;
  if( !self.goalentity )
    return AI_Urgent;
  if( (self.goalentity == self.enemy) )
    {
      if( self.e_target && ((enemy_trace_fraction != 1.0) || (enemy_range == RANGE_Far)) )
	{
	  if( random() < 0.5 )
	    return AI_Important;
	  else
	    return AI_Unimportant;
	}
      else
	return AI_Impossible;
    }
  else
    {
      if( (enemy_range < RANGE_Far) && (enemy_trace_fraction == 1.0) )
	return AI_Urgent;
      else
	return AI_Impossible;
    }
}
// attack enemy
void anim_soldier_shotgun_fire()
{
  float fid;
  sub_animate( $shoot1, $shoot9, standard_framelen, FL_Null );
  fid = 9 - (self.finalframe - self.frame);
  if( fid == 3 )
    {
      ai_scanattack( ai_soldier_shotgun_attack );
      sound( self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM );
    }
  else if( self.frame == $shoot9 )
    self.action_finished = time + ai_frametime;
}
void ai_soldier_attack_enemy()
{
  //sub_resetanimdata( self );
  self.animcount = 0;
  self.nextframe = 0;
  self.sub_animation = anim_soldier_shotgun_fire;
  self.enemy.last_attacked = time;
  self.action_finished = -1;
}
float ai_soldier_evaluate_attack_enemy()
{
  if( (!self.enemy) || (enemy_trace_fraction != 1) )
    return AI_Impossible;
  if( self_forward*goal_dir < hitscan_ai_shoot_dot )
    return AI_Impossible;
  switch( enemy_range )
    {
    case RANGE_Near:
    case RANGE_Melee:
      if( (self.health/self.max_health) < 0.5 )
	return AI_Vital;
      else
	return AI_Urgent;
    case RANGE_Mid:
      if( ((time - self.enemy.last_attacked) < 1) )
	return AI_Important;
      else
	return AI_Urgent;
    case RANGE_Far:
    default:
      return AI_Maybe;
    }
}
// turn to goalentity
void anim_soldier_turn_to_goalentity()
{
  ai_start_turn( vectoangles(goal_dir), 180 );
  anim_soldier_stand();
}
void ai_soldier_turn_to_goalentity()
{
  self.sub_animation = anim_soldier_turn_to_goalentity;
  self.action_finished = time + 0.3;
}
float ai_soldier_evaluate_turn_to_goalentity()
{
  float dot = self_forward*goal_dir;
  if( !self.goalentity )
    return AI_Impossible;
  //else if(TRUE)
  //return AI_Vital;
  if( (dot > 0) && (self.goalentity == self.enemy) && ((self.enemy.velocity*self_forward) < 0.5*enemy_speed) )
    return AI_Urgent;
  else if( dot < hitscan_ai_shoot_dot )
    {
      if( (self.goalentity == self.enemy) && (enemy_trace_fraction == 1.0) )
	return AI_Important;
      else
	return AI_Maybe;
    }
  else
    return AI_Unimportant;
}
// die
void anim_soldier_die()
{
  if( self.ranim < 0.5 )
    sub_animate( $death1, $death10, standard_framelen, FL_Null );
  else
    sub_animate( $deathc1, $deathc11, standard_framelen, FL_Null );

  if( (self.frame == $death10) || (self.frame == $deathc11) )
    self.think = SUB_Null;
}
float ai_soldier_evaluate_die()
{
  return AI_Impossible;
}
void ai_soldier_die()
{
  self.velocity += 150*[crandom(),crandom(),2];
  self.movetype = MOVETYPE_TOSS;
  self.solid = SOLID_NOT;
  self.ranim = random();
  self.sub_animation = anim_soldier_die;
  self.action_finished = -1;
}
// pain
void anim_soldier_pain()
{
  if( self.ranim < 1 )
    sub_animate( $pain1, $pain6, standard_framelen, FL_Null );
  else if( self.ranim < 2 )
    sub_animate( $painb1, $painb14, standard_framelen, FL_Null );
  else
    sub_animate( $painc1, $painc13, standard_framelen, FL_Null );
  if( (self.frame == $pain6) || (self.frame == $painb14) || (self.frame == $painc13) )
    self.action_finished = time;
}
float ai_soldier_evaluate_pain()
{
  return AI_Impossible;
}
void ai_soldier_pain()
{
  self.ranim = 3*random();
  self.sub_animation = anim_soldier_pain;
  self.action_finished = -1;
}
//action defs
aiaction_t action_soldier_die = { ai_soldier_die, ai_soldier_evaluate_die };
aiaction_t action_soldier_turn_to_goalentity = { ai_soldier_turn_to_goalentity, ai_soldier_evaluate_turn_to_goalentity };
aiaction_t action_soldier_attack_enemy = { ai_soldier_attack_enemy, ai_soldier_evaluate_attack_enemy };
aiaction_t action_soldier_choose_goalentity = { ai_soldier_choose_goalentity, ai_soldier_evaluate_choose_goalentity };
aiaction_t action_soldier_random_move = { ai_soldier_random_move, ai_soldier_evaluate_random_move };
aiaction_t action_soldier_move_to_goalentity = { ai_soldier_move_to_goalentity, ai_soldier_evaluate_move_to_goalentity };//definitions must be in one line, no escaping line returns
aiaction_t action_soldier_stand = { ai_soldier_stand, ai_soldier_evaluate_stand };
aiaction_t action_soldier_pain = { ai_soldier_pain, ai_soldier_evaluate_pain };
//==============================================================================
//
//    Framework
//
//==============================================================================
aiaction_t ai_soldier_actions[] = { //first action will be default
  action_soldier_stand,//first action is default, must always return AT LEAST AI_Unimportant
  action_soldier_die,
  action_soldier_pain,
  action_soldier_attack_enemy,
  action_soldier_turn_to_goalentity,
  action_soldier_random_move,
  action_soldier_choose_goalentity, 
  action_soldier_move_to_goalentity,
};
float MAX_SOLDIER_ACTIONS = 8; //this MUST equal the number of values in ai_soldier_actions

float soldier_get_best_action()
{
  float i;
  float actcount = 0;
  float eval = AI_Unimportant, best_eval = AI_Unimportant, best_action = 0;
  if( self.health < 1 )
    return 1; //action_soldier_die
  if( self.maxpain )
    {
      self.maxpain = 0;
      return 2; //action_soldier_pain
    }
  for( i = 0; i < MAX_SOLDIER_ACTIONS; i++ )
    {
      eval = ai_soldier_actions[i].evaluate();
      if( (eval > best_eval) || ((eval == best_eval) && (MAX_SOLDIER_ACTIONS*random() > 1) && (i != self.last_action)) )
	{
	  best_eval = eval;
	  best_action = i;
	}
    }
  return best_action;
}
void ai_soldier_sub_pain( entity taker, float damageval, float fl_damage, float id_damage )
{
  taker.action_finished = time;
  taker.nextframe = time;
  taker.maxpain = 1;
}
