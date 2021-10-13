void ai_scanattack( void( vector, vector ) attfunc )
{
  vector dir = normalize( (self.enemy.origin - 0.2*self.enemy.velocity) - self.origin );
  attfunc( self.origin, dir );
}
void ai_start_turn( vector wangles, float wspeed )
{
  self.wishangles = wangles;
  self.turnspeed = wspeed;
}
void ai_apply_turn()//run at the end of a think
{
  float aspd;
  float wspd = self.turnspeed*frametime;
  vector diff = (self.wishangles - self.angles);
  diff = vectormod( diff );
  aspd = vlen( diff );
  if( aspd > wspd )
    diff = diff*wspd/aspd;
    
  self.angles += diff;
}
float get_enemy_range()
{
  float dist = vlen( self.enemy.origin - self.origin );
  if( !self.enemy )
    return RANGE_NoEnemy;
  else if( dist < 210 )
    return RANGE_Melee;
  else if( dist < 300 )
    return RANGE_Near;
  else if( dist < 500 )
    return RANGE_Mid;
  else
    return RANGE_Far;
}
float test_walkmove( vector dir )
{
  vector tvec;
  tvec = 0.6*vlen([self.size_x, self.size_y, 0])*dir;
  traceline( self.origin, self.origin + tvec, FALSE, self );
  if( trace_fraction < 1.0 )
    {
      self.blocked_dir = dir;
      return 0;
    }
  else
    {
      tvec += self.origin;
      traceline( tvec, tvec + [ 0, 0, self.mins_z - 34 ], FALSE, self );
      if( trace_fraction == 1.0 )
	{
	  self.blocked_dir = dir;
	  return 0;
	}
      else
	return 1;
    }
}
void ai_start_walkmove( float spd, vector dir )
{
  self.blocked_dir = '0 0 0';
  dir_z = 0;
  self.wishspeed = spd;
  self.wishdir = dir;
}
void ai_execute_move()//run at the end of a think
{
  float fric = 1000;
  vector fricv = self.velocity - normalize(self.velocity)*frametime*fric;
  if( self.velocity*fricv < 0 )
    self.velocity = '0 0 0';
  else
    self.velocity = fricv;
  self.velocity += self.wishdir*range( self.wishspeed - self.wishdir*self.velocity, 0, self.wishspeed );
}
float ai_moveindir( float spd, vector dir ) //like the vel_ functions but safe from walking off edges
{
  if( test_walkmove( dir ) )
    {
      ai_start_walkmove( spd, dir );
      return 1;
    }
  else
    {
      self.velocity = self.velocity - (self.velocity*dir)*dir;
      self.action_finished = time;
      return 0;
    }
}
float ai_movetogoal( float spd )
{
  return ai_moveindir( spd, normalize(self.goalentity.origin - self.origin) );
}
float checkbottom_pos( entity tgt, vector offset )
{
  offset_z = 0;
  offset = offset + tgt.origin;
  traceline( offset, offset + [0, 0, self.mins_z - 2], FALSE, tgt );
  if( trace_fraction == 1 )
    return 0;
  else
    return 1;
}
float ai_checkbottom()
{
  if( checkbottom( self ) )
    return 1;
  if( checkbottom_pos(self, self.mins) )
    return 1;
  if( checkbottom_pos(self, self.maxs) )
    return 1;
  if( checkbottom_pos(self, [self.mins_x, self.maxs_y, 0]) )
    return 1;
  if( checkbottom_pos(self, [self.maxs_x, self.mins_y, 0]) )
    return 1;
  return 0;
}
