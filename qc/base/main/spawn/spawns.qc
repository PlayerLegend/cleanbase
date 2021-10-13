//==============================================================================
//
//    spawn_spawns.qc: spawners for players/items
//
//==============================================================================

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//player spawns
void info_player_spawn_stage1()
{
  entity cursor;
  if( self.classname != "info_player_spawn" )
    {
      if( (coop && (self.classname != "info_player_coop") && find(world, classname, "info_player_coop")) ||
	  (deathmatch && (self.classname != "info_player_deathmatch") && find(world, classname, "info_player_deathmatch")) ||
	  (teamplay && (self.classname != "info_player_deathmatch") && find(world, classname, "info_player_deathmatch")) ||
	  (!coop && !teamplay && !deathmatch && (self.classname != "info_player_start"))
	  )
	{
	  remove(self);
	  return;
	}
    }
  if( !self.angles )
    self.angles_y = self.angle;
  if( g_l_playerspawns == world )
    g_l_playerspawns = self;
  else
    {
      cursor = g_l_playerspawns;
      while( cursor.l_main )
	cursor = cursor.l_main;
      cursor.l_main = self;
    }
  g_playerspawncount += 1;
  bprint(ftos(g_playerspawncount));
  bprint(" added to spawnlist\n");
}
void info_player_spawn()
{
  self.think = info_player_spawn_stage1;
  self.nextthink = TIME_POST_ENTSPAWN;
}
void info_player_start()
{
  self.think = SUB_Null;
  info_player_spawn();
}
void info_player_coop()
{
  self.think = SUB_Null;
  info_player_spawn();
}
void info_player_deathmatch()
{
  self.think = SUB_Null;
  info_player_spawn();
}
