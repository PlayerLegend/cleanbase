void anim_player_stand()
{
  if( !incrange( self.nextframe, 0, time ) )
    return;

  self.weaponframe = 0;
  if( self.weaponid == WEAPID_axe )
    sub_animate( $axstnd1, $axstnd12, player_framelen, FL_Null );
  else
    sub_animate( $stand1, $stand5, player_framelen, FL_Null );
}
void anim_player_run()
{
  if( !incrange( self.nextframe, 0, time ) )
    return;

  self.weaponframe = 0;
  if( self.weaponid == WEAPID_axe )
    sub_animate( $axrun1, $axrun6, player_framelen, FL_Null );
  else
    sub_animate( $rockrun1, $rockrun6, player_framelen, FL_Null );
}
void anim_player_idle()
{
  if( (fabs(self.velocity_x) > 16) || (fabs(self.velocity_y) > 16) )
    anim_player_run();
  else
    anim_player_stand();
}
void anim_player_axe_swing()
{
  float fid;

  if( !incrange( self.nextframe, 0, time ) )
    return;

  //animate
  if( self.ranim < 1 )
    sub_animate( $axatt1, $axatt6, player_framelen, GENFL_AnimPlayOnce );
  else if( self.ranim < 2 )
    sub_animate( $axattb1, $axattb6, player_framelen, GENFL_AnimPlayOnce );
  else if( self.ranim < 3 )
    sub_animate( $axattc1, $axattc6, player_framelen, GENFL_AnimPlayOnce );
  else
    sub_animate( $axattd1, $axattd6, player_framelen, GENFL_AnimPlayOnce );
  //do per-frame actions
  fid = 6 - (self.finalframe - self.frame);
  if( fid == 3 )
    weap_player_axe_hit( self.origin + self.view_ofs, self_forward );
  if( fid < 5 )
    self.weaponframe = self.weaponstartframe + fid - 1;
  else
    self.weaponframe = 0;
}
void anim_player_die()
{
  if( !incrange( self.nextframe, 0, time ) )
    return;

  if( self.weaponid == WEAPID_axe )
    sub_animate( $axdeth1, $axdeth9, player_framelen, GENFL_AnimPlayOnce );
  else if( self.ranim < 1 )
    sub_animate( $deatha1, $deatha11, player_framelen, GENFL_AnimPlayOnce );
  else if( self.ranim < 2 )
    sub_animate( $deathb1, $deathb9, player_framelen, GENFL_AnimPlayOnce );
  else if( self.ranim < 3 )
    sub_animate( $deathc1, $deathc15, player_framelen, GENFL_AnimPlayOnce );
  else if( self.ranim < 4 )
    sub_animate( $deathd1, $deathd9, player_framelen, GENFL_AnimPlayOnce );
  else
    sub_animate( $deathe1, $deathe9, player_framelen, GENFL_AnimPlayOnce );
}
void anim_player_shotgun_fire()
{
  if( !incrange( self.nextframe, 0, time ) )
    return;

  sub_animate( $shotatt1, $shotatt6, player_framelen, GENFL_AnimPlayOnce );
  self.weaponframe = self.frame - self.startframe;
}
void anim_player_flinch()
{
  if( self.weaponid == WEAPID_axe )
    sub_animate( $axpain1, $axpain6, player_framelen, GENFL_AnimPlayOnce );
  else
    sub_animate( $pain1, $pain6, player_framelen, GENFL_AnimPlayOnce );
}
void anim_player_nailgun_fire()
{
  if( !incrange( self.nextframe, 0, time ) )
    return;

  if( (!self.button0) || (self.weaponid != WEAPID_nailgun) || (self.ammo[AMMOTYPE_Nails] < 1) )
    {
      self.extra_flags &= ~EXTRAFL_SingleFire;//cause the fire function to be re-run so that the out of nails message is displayed
      self.sub_animation = SUB_Null;
      return;
    }

  sub_animate( $nailatt1, $nailatt2, player_framelen, FL_Null );
  if( self.frame == $nailatt1 )
    {
      launch_nail( self.origin + self_right*4 + '0 0 16' + self_forward*16, self_forward );
    }
  else
    {
      launch_nail( self.origin - self_right*4 + '0 0 16' + self_forward*16, self_forward );
    }
  self.ammo[AMMOTYPE_Nails] -= 1;
  sound( self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM );

  self.weaponframe += 1;
  if( self.weaponframe > 8 )
    self.weaponframe = 1;

  sub_muzzleflash();            
  self.punchangle_x = -2;
  sub_player_attack_effects();
}

void anim_player_supernailgun_fire()
{
  entity nail;

  if( !incrange( self.nextframe, 0, time ) )
    return;
  
  if( (!self.button0) || (self.weaponid != WEAPID_supernailgun) || (self.ammo[AMMOTYPE_Nails] < 1) )
    {
      self.weaponframe -= 1; //the viewmodel might do strange things when turning back if this isn't done
      self.extra_flags &= ~EXTRAFL_SingleFire;//cause the fire function to be re-run so that the out of nails message is displayed
      self.sub_animation = SUB_Null;
      return;
    }

  sub_animate( $nailatt1, $nailatt2, player_framelen, FL_Null );

  nail = launch_nail( self.origin + '0 0 16' + self_forward*16, self_forward );
  if( self.ammo[AMMOTYPE_Nails] < 2 )
    {
      sound( self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM );
      self.ammo[AMMOTYPE_Nails] -= 1;
    }
  else
    {
      sound( self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM );
      nail.damage *= 2;
      self.ammo[AMMOTYPE_Nails] -= 2;
    }
  self.weaponframe += 1;
  if( self.weaponframe > 8 )
    self.weaponframe = 1;

  sub_muzzleflash();       
  self.punchangle_x = -2;
  sub_player_attack_effects();
}
void anim_player_lightning_fire()
{
  entity cursor;
  if( !incrange( self.nextframe, 0, time ) )
    return;

  if( (!self.button0) || (self.weaponid != WEAPID_lightning) || (self.ammo[AMMOTYPE_Cells] < 1) )
    {
      self.extra_flags &= ~EXTRAFL_SingleFire;
      self.sub_animation = SUB_Null;
      return;
    }

  if( self.waterlevel > WLEV_Feet )
    {
      cursor = findradius( self.origin, 1024 );
      while( cursor )
	{
	  if( (cursor.takedamage == DAMAGE_AIM) && (cursor.waterlevel > WLEV_Feet) )
	    {
	      sub_damage( self, cursor, self.ammo[AMMOTYPE_Cells]*30, FL_Null, DAMID_Bullet );
	    }
	  cursor = cursor.chain; 
	}
      return;
    }

  sub_animate( $light1, $light2, player_framelen, FL_Null );
  
  self.weaponframe = self.weaponframe + 1;
  if( self.weaponframe == 5 )
    self.weaponframe = 1;
  
  lightning_attack( self.origin + '0 0 16', self_forward );
  if( (self.frame == $light1) && ((self.animcount % 3) == 0) )
    sound( self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM );

  self.ammo[AMMOTYPE_Cells] -= 1;
  sub_player_attack_effects();
}
