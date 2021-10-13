entity player_findspawn()
{
  float randnum = rint( ( self.origin_x + self.origin_y + self.origin_z + 100*random() ) % g_playerspawncount );
  entity cursor = g_l_playerspawns;
  if( g_playerspawncount > 2 )
    {
      while( fabs(randnum - self.lastspawn) < 1 )//re-roll until it's a different spawn
	randnum = rint( g_playerspawncount*random() );
    }
  self.lastspawn = randnum;
  
  while( cursor && (randnum > 1) )
    {
      randnum -= 1;
      cursor = cursor.l_main;
    }
  return cursor;
}
void player_spawnsetup()
{
  float i;
  entity spawnent = player_findspawn();
  entity tmp;
  if( !spawnent )
    {
      bprint("could not find spawn\n");
      self.think = player_spawnsetup;
      self.nextthink = time;
      return;
    }
  self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_WALK;
  setmodel( self, "progs/player.mdl" );
  self.vismodel_index = self.modelindex;
  setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );
  self.angles = spawnent.angles;
  self.fixangle = 1;

  self.cl_thinktype = CL_THINK_Normal;
  self.killedby = world;
  self.deadflag = DEAD_NO;
  self.think = SUB_Null;
  self.default_animation = anim_player_idle;
  self.sub_animation = SUB_Null;
  self.sub_pain = SUB_PAIN_Null;
  self.sub_die = player_sub_die;

  self.view_ofs = '0 0 22';

  self.classname = "player";
  self.health = 100;
  self.max_health = 100;
  self.max_superhealth = 250;
  self.maxammo[AMMOTYPE_Shells] = 100;
  self.maxammo[AMMOTYPE_Nails] = 200;
  self.maxammo[AMMOTYPE_Rockets] = 100;
  self.maxammo[AMMOTYPE_Cells] = 200;
  self.ammo[AMMOTYPE_Shells] = 25;
  self.bloodtype = BT_Blood;
  self.takedamage = DAMAGE_AIM;
  self.damageratio = 1.0;
  for( i = 2; i < WEAP_SLOTS; i++ )
    self.weaponslot[i] = WEAPID_noweapon;
  for( i = 0; i < MAX_POWERS; i++ )
    self.power_finished[i] = time;
  give_weapon( self, WEAPID_axe, 0 );
  give_weapon( self, WEAPID_shotgun, 1 );
  switch_to_slot( self, 0 );

  self.touch_identity = (spawnent.set_touch_identity | TOUCHFL_Player);
  self.achan = spawnent.set_achan;
  self.achan_incl = spawnent.set_achan_incl;
  if( spawnent.set_targetname != self.targetname )
    settargetname( self, spawnent.set_targetname );
  self.gravitydir = '0 0 -1';
  tmp = sub_telefrag( spawnent.origin, vlen( self.size )/1.9, self );
  if( tmp )
    {
      self.solid = SOLID_NOT;
      sub_damage( tmp, self, 500000, FL_Null, DAMID_Telefrag );
    }
  setorigin( self, spawnent.origin );
}

