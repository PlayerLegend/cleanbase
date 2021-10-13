void player_feelpain()//pain noises and flinch
{
  float rval;
  if( !self.maxpain )
    return;
  if( self.sub_animation == SUB_Null )
    self.sub_animation = anim_player_flinch;
  switch( self.painid )
    {
    case DAMID_Drown:
      if( random() > 0.5 )
	sound( self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM );
      else
	sound( self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM );
      break;
    case DAMID_Slime:
    case DAMID_Lava:
      if( random() > 0.5 )
	sound( self, CHAN_BODY, "player/lburn1.wav", 1, ATTN_NORM );
      else
	sound( self, CHAN_BODY, "player/lburn2.wav", 1, ATTN_NORM );
      break;
    case DAMID_Melee:
      sound( self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM );
      break;
    case DAMID_Bullet:
    default:
      rval = random();
      if( rval < 1 )
	sound( self, CHAN_VOICE, "player/pain1.wav", 1, ATTN_NORM );
      else if( rval < 2 )
	sound( self, CHAN_VOICE, "player/pain2.wav", 1, ATTN_NORM );
      else if( rval < 3 )
	sound( self, CHAN_VOICE, "player/pain3.wav", 1, ATTN_NORM );
      else if( rval < 4 )
	sound( self, CHAN_VOICE, "player/pain4.wav", 1, ATTN_NORM );
      else if( rval < 5 )
	sound( self, CHAN_VOICE, "player/pain5.wav", 1, ATTN_NORM );
      else
	sound( self, CHAN_VOICE, "player/pain6.wav", 1, ATTN_NORM );
      break;
    }
}
void player_sub_die()//called to die
{
  self.cl_thinktype = CL_THINK_Dead;
  self.weaponwait = time + 1; //used as respawn time
  self.velocity += 150*[crandom(),crandom(),2];
  self.movetype = MOVETYPE_TOSS;
  self.solid = SOLID_NOT;
  self.ranim = 5*random();
  self.animcount = 0;
  if( self.health > 0 )
    self.health = 0;
  self.sub_animation = anim_player_die;
  self.default_animation = SUB_Null;
}
void player_jump()//called to jump
{
  if( self.velocity * self_up > 270 )
    return;
  if( !(self.flags & FL_ONGROUND) )
    return;
  else if( self.waterlevel < 2 )//less than waist high
    {
      self.flags &= ~FL_ONGROUND;
      self.velocity_z += 270;
    }
}
void normal_button_actions()//performs actions based on pressed buttons
{
  if( self.button2 )
    player_jump();
  if( self.button0 && incrange( self.weaponwait, 0, time) )
    {
      if( !(self.extra_flags & EXTRAFL_SingleFire) )
	self.weapon_action[WACT_Attack1]();
      else if((self.extra_flags & EXTRAFL_SingleFire) && !(self.fl_heldbuttons & BUTTON_0))
	self.weapon_action[WACT_Attack1]();
    }
    
}
void give_weapon( entity tgt, float weapid, float slot ); //give tgt a weapon
float ideal_slot( float weapid );
void give_everything( entity tgt )
{
  float i;
  for( i = WEAPID_supershotgun; i < MAX_WEAPID; i++ )
    give_weapon( self, i, ideal_slot( i ) );

  self.ammo[AMMOTYPE_Shells] = 100;
  self.ammo[AMMOTYPE_Nails] = 200;
  self.ammo[AMMOTYPE_Rockets] = 100;
  self.ammo[AMMOTYPE_Cells] = 200;
}
void impulse_switchweapon();
void normal_impulse_actions() //collection of impulse checks
{
  impulse_switchweapon();

  if( (self.impulse == IMPULSE_ItemCheat) && cvar("sv_cheats") )
    give_everything( self );
    
}
void liquid_checks()//check for liquid damage
{
  switch( self.watertype )
    {
    case CONTENT_EMPTY:
      if( self.lastwaterlevel != 0 )
	sound( self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM );
      break;
    default:
      if( self.lastwaterlevel != self.waterlevel )
	{
	  if( self.lastwaterlevel == WLEV_Eyes )
	    {
	      if( self.breathtime < -9 )
		sound( self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM );
	      else
		sound( self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM );
	    }
	  else if( self.lastwaterlevel == WLEV_Out )
	    sound( self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM );
	}
      if( (self.breathtime < -12) && ((time - self.lastdrowndamage) > 1) )
	{
	  sub_damage( world, self, 4, (FL_Null), DAMID_Drown );
	  self.lastdrowndamage = time;
	}
      break;
    case CONTENT_SLIME:
      if( (time - self.lastdrowndamage) > 0.8 )
	{
	  if( self.lastwaterlevel == WLEV_Out )
	    sound( self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM );
	  sub_damage( world, self, 4*self.waterlevel, (DAMFL_Poison), DAMID_Slime );
	  self.lastdrowndamage = time;
	}
      break;
    case CONTENT_LAVA:
      if( (time - self.lastdrowndamage) > 0.25 )
	{
	  if( self.lastwaterlevel == WLEV_Out )
	    sound( self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM );
	  sub_damage( world, self, 9*self.waterlevel, (DAMFL_Fire), DAMID_Lava );
	  self.lastdrowndamage = time;
	}
      break;
    }
  if( self.waterlevel != WLEV_Eyes )
    self.breathtime = fmax( 0, self.breathtime + frametime );
  else
    self.breathtime = fmin( 0, self.breathtime - frametime );
}
void set_buttonflags()// sets up a flags field which reflects pressed buttons, uncomment what is needed
{
  self.fl_buttons = 0;
  if( self.button0 )
    self.fl_buttons |= BUTTON_0;
  //if( self.button1 )
  //  self.fl_buttons |= BUTTON_1;
  if( self.button2 )
    self.fl_buttons |= BUTTON_2;
  /*if( self.button3 )
    self.fl_buttons |= BUTTON_3;
  if( self.button4 )
    self.fl_buttons |= BUTTON_4;
  if( self.button5 )
    self.fl_buttons |= BUTTON_5;
  if( self.button6 )
    self.fl_buttons |= BUTTON_6;
  if( self.button7 )
    self.fl_buttons |= BUTTON_7;
  if( self.button8 )
    self.fl_buttons |= BUTTON_8;
  if( self.button9 )
    self.fl_buttons |= BUTTON_9;
  if( self.button10 )
    self.fl_buttons |= BUTTON_10;
  if( self.button11 )
    self.fl_buttons |= BUTTON_11;
  if( self.button12 )
    self.fl_buttons |= BUTTON_12;
  if( self.button13 )
    self.fl_buttons |= BUTTON_13;
  if( self.button14 )
    self.fl_buttons |= BUTTON_14;
  if( self.button15 )
    self.fl_buttons |= BUTTON_15;
  if( self.button16 )
    self.fl_buttons |= BUTTON_16;*/

  self.fl_heldbuttons = (self.fl_heldbuttons & self.fl_buttons);//keeps only buttons which are currently held
}
void player_obituary() //death messages
{
  float ran;
  bprint(ftos(self.painid));
  bprint("\n");
  switch( self.painid )
    {
    case DAMID_Drown:
      ran = 4*random();
      if( ran < 1 )
	{
	  bprint("Mermaid man could not save ");
	  bprint(self.netname);
	  bprint(" today.\n");
	}
      else if( ran < 2.5 )
	{
	  bprint(self.netname);
	  bprint(" fed the rotfish.\n");
	}
      else
	{
	  bprint(self.netname);
	  bprint(" forgot to swim.\n");
	}
      break;
    case DAMID_Slime:
      ran = 4*random();
      if( ran < 3 )
	{
	  bprint(self.netname);
	  bprint(" chokes it down.\n");
	}
      else
	{
	  bprint(self.netname);
	  bprint(" couldn't find the slimegirls.\n");
	}
      break;
    case DAMID_Lava:
      ran = 3*random();
      if( ran < 1 )
	{
	  bprint(self.netname);
	  bprint(" takes after the T-800.\n");
	}
      else if( ran < 2 )
	{
	  bprint(self.netname);
	  bprint(" accidently sacrifices himself.\n");
	}
      else
	{
	  bprint(self.netname);
	  bprint(" did not return from the fire.\n");
	}
      break;
    case DAMID_Melee:
      ran = 4*random();
      if( self.killedby.netname == "" )
	{
	  bprint("An undescribable horror cleaved ");
	  bprint(self.netname);
	  bprint("'s head in two.\n");
	}
      else if( ran < 1 )
	{
	  bprint(self.netname);
	  bprint(" lost his head to ");
	  bprint(self.killedby.netname);
	  bprint(".\n");
	}
      else if( ran < 2 )
	{
	  bprint(self.netname);
	  bprint(" was shortened by ");
	  bprint(self.killedby.netname);
	  bprint(".\n");
	}
      else if( ran < 3 )
	{
	  bprint(self.netname);
	  bprint(" feels ");
	  bprint(self.killedby.netname);
	  bprint("'s edge.\n");
	}
      else
	{
	  bprint(self.killedby.netname);
	  bprint(" performed an emergency operation on ");
	  bprint(self.netname);
	  bprint(".\n");
	}
      break;
    case DAMID_Bullet:
      switch( self.killedby.weaponid )
	{
	case WEAPID_shotgun:
	  bprint(self.killedby.netname);
	  bprint(" swept ");
	  bprint(self.netname);
	  bprint(" away.\n");
	  break;
	case WEAPID_supershotgun:
	  bprint(self.netname);
	  bprint(" smoked two pipes of ");
	  bprint(self.killedby.netname);
	  bprint("'s shotgun.\n");
	  break;
	}
      break;
    case DAMID_Atebomb:
      switch( self.killedby.weaponid )
	{
	default://todo
	  bprint(self.netname);
	  bprint(" ate a rocket from ");
	  bprint(self.killedby.netname);
	  bprint("\n");
	  break;
	}
      break;
    case DAMID_Blastradius:
      if( self.killedby == self )
	{
	  if( random() < 0.5 )
	    {
	      bprint(self.netname);
	      bprint(" misfired.\n");
	    }
	  else
	    {
	      bprint(self.netname);
	      bprint(" self destructs.\n");
	    }
	  break;
	}
      switch( self.killedby.weaponid )
	{
	case WEAPID_grenadelauncher:
	  bprint(self.netname);
	  bprint(" surfed on ");
	  bprint(self.killedby.netname);
	  bprint("'s grenade\n");
	case WEAPID_rocketlauncher:
	default:
	  bprint(self.netname);
	  bprint(" was turned to soup by ");
	  bprint(self.killedby.netname);
	  bprint("'s rocket barrage.\n");
	  break;
	}
      break;
    case DAMID_Telefrag:
      if( random() < 0.2 )
	{
	  bprint(self.killedby.netname);
	  bprint(" learns ");
	  bprint(self.netname);
	  bprint(" some teleporter safety.\n");
	}
      else
	{
	  bprint(self.netname);
	  bprint(" was telefragged by ");
	  bprint(self.killedby.netname);
	  bprint(".\n");
	}
      break;
    default:
      bprint(self.netname);
      bprint(" was killed by a mysterious thing.\n");
      break;
    }
}
void client_powerup_effects()
{
  float psuit, psha, pquad, pinv;
  psuit = self.power_finished[POWER_Envsuit] - time;
  psha = self.power_finished[POWER_Invis] - time;
  pquad = self.power_finished[POWER_Quad] - time;
  pinv = self.power_finished[POWER_Pent] - time;

  if( (pquad > 0) || (pinv > 0) )
    self.effects |= EF_DIMLIGHT;
  else
    self.effects &= ~EF_DIMLIGHT;


  if( pquad > 0 )
    {
      if( incrange( self.power_finished[POWER_Quad] - time - 3, 0, frametime ) )
	{
	  sound( self, CHAN_VOICE, "items/damage2.wav", 1, ATTN_NORM );
	  stuffcmd( self, "bf\n" );//note: without the \n this doesn't work in FTE
	}
      self.effects |= EF_BLUE;
    }
  else
    self.effects &= ~EF_BLUE;

  if( pinv > 0 )
    {
      if( incrange( self.power_finished[POWER_Pent] - time - 3, 0, frametime ) )
	{
	  sound( self, CHAN_VOICE, "items/protect.wav", 1, ATTN_NORM );
	  stuffcmd( self, "bf\n" );
	}
      self.effects |= EF_RED;
    }
  else
    self.effects &= ~EF_RED;


  if( psha > 0 )
    {
      if( self.modelindex == self.vismodel_index )
	setmodel( self, "progs/eyes.mdl" );
    }
  else
    {
      if( self.modelindex != self.vismodel_index )
	setmodel( self, "progs/player.mdl" );
    }
}
