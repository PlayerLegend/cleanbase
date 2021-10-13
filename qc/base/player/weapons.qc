const float player_framelen = 0.1;
//==============================================================================
//    subs
//==============================================================================
void apply_weaponfields( entity tgt, float weapid )
{
  float i;
  tgt.weaponframe = 0;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    tgt.weapon_action[i] = weaponlist[weapid].action[i];
  tgt.ammotype = weaponlist[weapid].ammotype;
  tgt.weaponid = weapid;
}
void sub_player_attack_effects()
{
  if( (self.weaponid != WEAPID_noweapon) && (self.last_noise < time - 1) && (self.power_finished[POWER_Quad] > time) )
    {
      self.last_noise = time;
      sound( self, CHAN_VOICE, "items/damage3.wav", 1, ATTN_NORM );
    }
}
void hitparticles( entity target, vector org, vector dir )
{
  org = org - dir*4;
  switch( target.bloodtype )
    {
    default://world
    case BT_Dust:
      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_GUNSHOT);
      WriteCoord (MSG_BROADCAST, org_x);
      WriteCoord (MSG_BROADCAST, org_y);
      WriteCoord (MSG_BROADCAST, org_z);
      break;
    case BT_Blood:
      particle( org, -dir + 3*crandom()*self_up + 3*crandom()*self_right, 73, 20 + 30*random() );
      break;
    case BT_None:
      break;
    }
}
float traceattack( vector org, vector dir, float dist, float damage, float fl_damage, float id_damage )//hitscan bullet
{
  traceline( org, org + dir*dist, FALSE, self );
  if( trace_fraction == 1.0 )
    return 0;
  else
    {
      sub_damage( self, trace_ent, damage, fl_damage, id_damage );
      if( (trace_ent.health >= 1) && (other.movetype == MOVETYPE_WALK) )
	trace_ent.velocity += 20*dir*damage;
      hitparticles( trace_ent, trace_endpos, dir );
      return 1;
    }
};
float shotblast( vector org, vector dir, float dist, float damage, float shotcount, float scatter )//shotgun blast
{
  float rangle;
  vector rdir;
  float retval = 0;
  for( ; shotcount > 0; shotcount-- )
    {
      rangle = M_2mPI*random();
      rdir = normalize(dir + scatter*(self_right*cos(rangle) + self_up*sin(rangle))*random());
      retval += traceattack( org, rdir, dist, damage, 0, DAMID_Bullet );
    }
  return retval;
}
entity spawn_missile( entity misowner, vector org, vector dir, float sspeed, string model )//spawn_missile: spawns and returns a missile
{
  entity new = spawn();
  new.owner = misowner;
  new.angles = vectoangles( dir );
  new.speed = sspeed;
  new.velocity = dir*new.speed;
  new.solid = SOLID_BBOX;
  new.sub_pain = SUB_PAIN_Null;
  new.movetype = MOVETYPE_FLYMISSILE;
  new.weaponid = misowner.weaponid;
  setmodel( new, model );
  setorigin( new, org );
  return new;
}
void touch_explode()//If touched, explode. Does extra damage to touch-er
{
  sub_damage( self, other, 100, (DAMFL_Concussion | DAMFL_Fire), DAMID_Atebomb );
  area_damage( self.owner, 60, (DAMFL_Concussion), DAMID_Blastradius, self.origin, 128, 0.5, self );
  sub_explosion( self.origin );
  remove(self);
}
void touch_bullet()
{
  sub_damage( self.owner, other, self.damage, FL_Null, DAMID_Bullet );
  hitparticles( other, self.origin, normalize( self.velocity ) );
  remove(self);
}
//==============================================================================
//
//    No weapon
//
//==============================================================================
void weap_player_noweapon_alert()
{
  sound (self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM);
  centerprint( self, "No weapon!" );
}
void weap_player_noweapon_wield( entity tgt )
{
  tgt.extra_flags |= EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_noweapon );
  tgt.weaponmodel = "";
}
void weap_player_noweapon_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_noweapon].action[i] = weap_player_noweapon_alert;
  weaponlist[WEAPID_noweapon].wield = weap_player_noweapon_wield;
  weaponlist[WEAPID_noweapon].ammotype = AMMOTYPE_None;
}
//==============================================================================
//
//    Axe
//
//==============================================================================
void anim_player_axe_swing();//animation in animations.qc

void weap_player_axe_hit( vector org, vector dir )
{
  if( traceattack( org, dir, 64, 20, 0, DAMID_Melee ) )
    {
      if( trace_ent.takedamage != DAMAGE_AIM )
	sound( self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM );//hit wall sound
    }
  else
    sound( self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM );//miss sound
}
void weap_player_axe_swing()
{
  self.ranim = 4*random();
  sub_player_attack_effects();
  if( self.ranim < 2 )
    self.weaponstartframe = 1;
  else
    self.weaponstartframe = 5;
  sub_resetanimdata( self );
  self.sub_animation = anim_player_axe_swing;//attack code is run in the animation
  self.weaponwait = time + 0.5;
  sound( self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM );
}
void weap_player_axe_wield( entity tgt )
{
  tgt.extra_flags &= ~EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_axe );
  tgt.weaponmodel = "progs/v_axe.mdl";
}
void weap_player_axe_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_axe].action[i] = SUB_Null;
  weaponlist[WEAPID_axe].action[WACT_Attack1] = weap_player_axe_swing;
  weaponlist[WEAPID_axe].wield = weap_player_axe_wield;
  weaponlist[WEAPID_axe].ammotype = AMMOTYPE_None;
}
//==============================================================================
//
//    Shotgun
//
//==============================================================================
void anim_player_shotgun_fire();
void weap_player_shotgun_fire()
{
  if( self.ammo[AMMOTYPE_Shells] < 1 )
    {
      sound (self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM);
      centerprint(self, "Out of gun juice!");
      self.extra_flags |= (EXTRAFL_SingleFire);
      return;
    }
  else
    self.extra_flags &= ~(EXTRAFL_SingleFire);
  sub_player_attack_effects();
  shotblast( self.origin + self.view_ofs, self_forward, 8192, 4, 6, 0.1 );
  sub_resetanimdata( self );
  sub_muzzleflash();
  self.punchangle_x = -2; //this causes a recoil effect
  self.sub_animation = anim_player_shotgun_fire;
  self.weaponwait = time + 0.5;
  self.ammo[AMMOTYPE_Shells] -= 1;
  sound( self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM );
}
void weap_player_shotgun_wield( entity tgt )
{
  tgt.extra_flags &= ~EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_shotgun );
  tgt.weaponmodel = "progs/v_shot.mdl";
}
void weap_player_shotgun_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_shotgun].action[i] = SUB_Null;
  weaponlist[WEAPID_shotgun].action[WACT_Attack1] = weap_player_shotgun_fire;
  weaponlist[WEAPID_shotgun].wield = weap_player_shotgun_wield;
  weaponlist[WEAPID_shotgun].ammotype = AMMOTYPE_Shells;
}
//==============================================================================
//
//    Super Shotgun
//
//==============================================================================
void weap_player_ssg_fire()
{
  if( self.ammo[AMMOTYPE_Shells] < 2 )
    {
      if( self.ammo[AMMOTYPE_Shells] == 2 )
	weap_player_shotgun_fire();
      else
	{
	  sound (self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM);
	  self.extra_flags |= EXTRAFL_SingleFire;
	  centerprint(self,"Your bullets are at their end!");
	}
      return;
    }
  else
    self.extra_flags &= ~EXTRAFL_SingleFire;
  sub_player_attack_effects();
  shotblast( self.origin + self.view_ofs, self_forward, 8192, 4, 14, 0.15 );
  sub_resetanimdata( self );
  sub_muzzleflash();
  self.punchangle_x = -4; //this causes a recoil effect
  self.sub_animation = anim_player_shotgun_fire;
  self.weaponwait = time + 0.7;
  self.ammo[AMMOTYPE_Shells] -= 2;
  sound( self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM );
}
void weap_player_ssg_wield( entity tgt )
{
  tgt.extra_flags &= ~EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_supershotgun );
  tgt.weaponmodel = "progs/v_shot2.mdl";
}
void weap_player_ssg_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_supershotgun].action[i] = SUB_Null;
  weaponlist[WEAPID_supershotgun].action[WACT_Attack1] = weap_player_ssg_fire;
  weaponlist[WEAPID_supershotgun].wield = weap_player_ssg_wield;
  weaponlist[WEAPID_supershotgun].ammotype = AMMOTYPE_Shells;
}

//==============================================================================
//
//    Nailgun
//
//==============================================================================
void anim_player_nailgun_fire();
entity launch_nail( vector org, vector dir )
{
  entity nail = spawn_missile( self, org, dir, 1000, "progs/s_spike.mdl" );
  nail.touch = touch_bullet;
  nail.think = SUB_Remove;
  nail.nextthink = time + 5;
  nail.damage = 7;
  setsize( nail, '0 0 0', '0 0 0' );
  return nail;
}
void weap_player_nailgun_fire()
{
  self.extra_flags |= EXTRAFL_SingleFire;
  if( self.ammo[AMMOTYPE_Nails] < 1 )
    {
      sound( self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM );
      centerprint(self,"Your nails have become empty!");
      return;
    }
  sub_resetanimdata( self );
  self.weaponframe = 1;
  self.weaponwait = time + 0.1;
  self.sub_animation = anim_player_nailgun_fire;
}
void weap_player_nailgun_wield( entity tgt )
{
  tgt.extra_flags |= EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_nailgun );
  tgt.weaponmodel = "progs/v_nail.mdl";
}
void weap_player_nailgun_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_nailgun].action[i] = SUB_Null;
  weaponlist[WEAPID_nailgun].action[WACT_Attack1] = weap_player_nailgun_fire;
  weaponlist[WEAPID_nailgun].wield = weap_player_nailgun_wield;
  weaponlist[WEAPID_nailgun].ammotype = AMMOTYPE_Nails;
}
//==============================================================================
//
//    Super Nailgun
//
//==============================================================================
void anim_player_supernailgun_fire();
void weap_player_supernailgun_fire()
{
  self.extra_flags |= EXTRAFL_SingleFire;
  if( self.ammo[AMMOTYPE_Nails] < 1 )
    {
      sound( self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM );
      centerprint( self, "There is nothing in your clip!" );
      return;
    }
  sub_resetanimdata( self );
  self.weaponframe = 1;
  self.weaponwait = time + 0.1;
  self.sub_animation = anim_player_supernailgun_fire;
}
void weap_player_supernailgun_wield( entity tgt )
{
  tgt.extra_flags |= EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_supernailgun );
  tgt.weaponmodel = "progs/v_nail2.mdl";
}
void weap_player_supernailgun_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_supernailgun].action[i] = SUB_Null;
  weaponlist[WEAPID_supernailgun].action[WACT_Attack1] = weap_player_supernailgun_fire;
  weaponlist[WEAPID_supernailgun].wield = weap_player_supernailgun_wield;
  weaponlist[WEAPID_supernailgun].ammotype = AMMOTYPE_Nails;
}
//==============================================================================
//
//    Grenade Launcher
//
//==============================================================================
void touch_grenade()
{
  if( other.takedamage == DAMAGE_AIM )
    touch_explode();
  else
    {
      sound( self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM ); // bounce sound
      if( self.velocity == '0 0 0' )
	self.avelocity = '0 0 0';
    }
}
void launch_grenade( vector org, vector dir )
{
  entity gren = spawn_missile( self, org, dir, 600, "progs/grenade.mdl" );
  gren.movetype = MOVETYPE_BOUNCE;
  gren.touch = touch_grenade;
  gren.think = touch_explode;
  gren.nextthink = time + 2.5;
  gren.avelocity = '300 300 300';
  setsize( gren, '0 0 0', '0 0 0' );
}
void weap_player_grenadelauncher_fire()
{
  if( self.ammo[AMMOTYPE_Rockets] < 1 )
    {
      sound( self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM );
      self.extra_flags |= EXTRAFL_SingleFire;
      centerprint(self,"You lost the grenades!");
      return;
    }
  else
    self.extra_flags &= ~EXTRAFL_SingleFire;
  sub_player_attack_effects();
  launch_grenade( self.origin + 8*self_forward + '0 0 16', normalize(5*self_forward + self_up) );
  sub_resetanimdata( self );
  sub_muzzleflash();
  self.punchangle_x = -2;
  self.sub_animation = anim_player_shotgun_fire;
  self.weaponwait = time + 0.6;
  self.ammo[AMMOTYPE_Rockets] -= 1;
  sound( self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM );
}
void weap_player_grenadelauncher_wield( entity tgt )
{
  tgt.extra_flags &= ~EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_grenadelauncher );
  tgt.weaponmodel = "progs/v_rock.mdl";
}
void weap_player_grenadelauncher_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_grenadelauncher].action[i] = SUB_Null;
  weaponlist[WEAPID_grenadelauncher].action[WACT_Attack1] = weap_player_grenadelauncher_fire;
  weaponlist[WEAPID_grenadelauncher].wield = weap_player_grenadelauncher_wield;
  weaponlist[WEAPID_grenadelauncher].ammotype = AMMOTYPE_Rockets;
}

//==============================================================================
//
//    Rocket launcher
//
//==============================================================================
void launch_rocket( vector org, vector dir )
{
  entity rocket = spawn_missile( self, org, dir, 1000, "progs/missile.mdl" );
  setsize( rocket, -MISSILE_SIZE, MISSILE_SIZE );
  rocket.touch = touch_explode;
  rocket.think = touch_explode;
  rocket.nextthink = time + 5;
}
void weap_player_rocketlauncher_fire()
{
  if( self.ammo[AMMOTYPE_Rockets] < 1 )
    {
      sound( self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM );
      self.extra_flags |= EXTRAFL_SingleFire;
      centerprint(self,"The rockets are gone!");
      return;
    }
  else
    self.extra_flags &= ~EXTRAFL_SingleFire;
  sub_player_attack_effects();
  launch_rocket( self.origin + 8*self_forward + '0 0 16', self_forward );
  sub_resetanimdata( self );
  sub_muzzleflash();
  self.punchangle_x = -2; //this causes a recoil effect
  self.sub_animation = anim_player_shotgun_fire;
  self.weaponwait = time + 0.7;
  self.ammo[AMMOTYPE_Rockets] -= 1;
  sound( self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM );
}

void weap_player_rocketlauncher_wield( entity tgt )
{
  tgt.extra_flags &= ~EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_rocketlauncher );
  tgt.weaponmodel = "progs/v_rock2.mdl";
}
void weap_player_rocketlauncher_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_rocketlauncher].action[i] = SUB_Null;
  weaponlist[WEAPID_rocketlauncher].action[WACT_Attack1] = weap_player_rocketlauncher_fire;
  weaponlist[WEAPID_rocketlauncher].wield = weap_player_rocketlauncher_wield;
  weaponlist[WEAPID_rocketlauncher].ammotype = AMMOTYPE_Rockets;
}
//==============================================================================
//
//    Lightning gun
//
//==============================================================================
void lightning_attack( vector org, vector dir )
{
  if( traceattack( org, dir, 600, 30, FL_Null, DAMID_Bullet ) && (trace_ent.movetype == MOVETYPE_WALK) )
    {
      trace_ent.velocity += dir*400;
    }
  sub_lightning( self, self.origin, trace_endpos );
}
void anim_player_lightning_fire();
void weap_player_lightning_fire()
{
  self.extra_flags |= EXTRAFL_SingleFire;
  if( self.ammo[AMMOTYPE_Cells] < 1 )
    {
      sound( self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM );
      centerprint( self, "Your energy cells have run low!" );
      return;
    }

  sound( self, CHAN_VOICE, "weapons/lstart.wav", 1, ATTN_NORM );

  sub_resetanimdata( self );
  self.weaponframe = 0;
  self.weaponwait = time + 0.1;
  self.sub_animation = anim_player_lightning_fire;
}
void weap_player_lightning_wield( entity tgt )
{
  tgt.extra_flags |= EXTRAFL_SingleFire;
  apply_weaponfields( tgt, WEAPID_lightning );
  tgt.weaponmodel = "progs/v_light.mdl";
}
void weap_player_lightning_init()
{
  float i;
  for( i = 0; i < WEAP_ACTIONS; i++ )
    weaponlist[WEAPID_lightning].action[i] = SUB_Null;
  weaponlist[WEAPID_lightning].action[WACT_Attack1] = weap_player_lightning_fire;
  weaponlist[WEAPID_lightning].wield = weap_player_lightning_wield;
  weaponlist[WEAPID_lightning].ammotype = AMMOTYPE_Cells;
}
