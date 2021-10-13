//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  item framework, .touch and .think
void th_item()//will make item visible/touchable/reset what needs to be reset
{
  self.modelindex = self.vismodel_index;
  self.solid = SOLID_TRIGGER;
  self.nextthink = ENV_STOPTHINK;
}
void use_item() //make the item invisible until it's wait is over
{
  self.think = th_item;
  self.nextthink = time + self.wait;
  self.vismodel_index = self.modelindex;
  self.modelindex = 0;
  self.solid = SOLID_NOT;//not a trigger
  stuffcmd( other, "bf\n" );//note: without the \n this doesn't work in FTE
  sound( other, CHAN_ITEM, self.noise, 1, ATTN_NORM );
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  effects - called by .touch
void touch_ammo()
{
  float effect = 0;
  float i;
  force_retouch = 2;
  if( other.movetype != MOVETYPE_WALK )
    return;
  if( other.health < 1 )
    return;
  if( other.classname != "player" )
    return;
  for( i = 0; i < MAX_AMMOTYPE; i++ )
    {
      if( self.ammo[i] && !has_maxammo( other, i ) )
	{
	  effect = 1;
	  give_ammo( other, i, self.ammo[i] );
	}
    }
  if( effect == 0 )
    return;
  else
    use_item();
}
void touch_health()
{
  force_retouch = 2;
  if( other.movetype != MOVETYPE_WALK )
    return;
  if( other.health < 1 )
    return;
  if( other.classname != "player" )
    return;
  if( self.spawnflags & H_MEGA )
    {
      if( other.health >= other.max_superhealth )
	return;
      other.health = fmin( other.max_superhealth, other.health + self.health );
    }
  else
    {
      if( other.health >= other.max_health )
	return;
      other.health = fmin( other.max_health, other.health + self.health );
    }
  use_item();
}
void touch_weapon()
{
  force_retouch = 2;
  float amtype = weaponid_to_ammotype( self.weaponid );
  if( other.movetype != MOVETYPE_WALK )
    return;
  if( other.health < 1 )
    return;
  if( other.classname != "player" )
    return;
  if( has_weapon( other, self.weaponid ) && has_maxammo( other, amtype ) )
    return;
  switch( amtype )
    {
    case AMMOTYPE_Cells:
      give_ammo( other, amtype, 10 );
      break;
    case AMMOTYPE_Nails:
      give_ammo( other, amtype, 30 );
      break;
    default:
      give_ammo( other, amtype, 5 );
    }
  give_weapon( other, self.weaponid, ideal_slot( self.weaponid ) );
  use_item();
}
void touch_powerup()
{
  if( other.movetype != MOVETYPE_WALK )
    return;
  if( other.health < 1 )
    return;
  if( other.classname != "player" )
    return;

  other.power_finished[self.weaponid] = time + 30; // hax: the weaponid contains the POWER_ type of the item

  use_item();
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// spawning
void floor_check()
{
  vector coords = self.origin;
  if( !droptofloor( 0, 8192 ) )
    {
      bprint(self.classname);
      bprint(": item fell out of the world at ");
      bprint(vtos(coords));
      bprint("\n");
      remove(self);
    }
}
// ammo giver
void setdefaults_item_ammo()
{
  if( !self.wait )
    self.wait = 20;
  if( self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells == 0 )
    self.ammo_shells = 20;
}
void init_item_ammo()
{
  string mdl = "";
  float am = 0;
  float i;
  copy_ammovals_to_array();
  for( i = 0; i < MAX_AMMOTYPE; i++ )
    {
      if( am && self.ammo[i] )
	{
	  mdl = "progs/backpack.mdl";
	  break;
	}
      am += self.ammo[i];
    }
  if( mdl == "" )
    {
      if( self.ammo[AMMOTYPE_Nails] )
	{
	  if( self.ammo[AMMOTYPE_Nails] <= 25 )
	    mdl = "maps/b_nail0.bsp";
	  else
	    mdl = "maps/b_nail1.bsp";
	}
      else if( self.ammo[AMMOTYPE_Rockets] )
	{
	  if( self.ammo[AMMOTYPE_Rockets] <= 5 )
	    mdl = "maps/b_rock0.bsp";
	  else
	    mdl = "maps/b_rock1.bsp";
	}
      else if( self.ammo[AMMOTYPE_Cells] )
	{
	  if( self.ammo[AMMOTYPE_Cells] <= 6 )
	    mdl = "maps/b_batt0.bsp";
	  else
	    mdl = "maps/b_batt1.bsp";
	}
      else if( self.ammo[AMMOTYPE_Shells] )
	{
	  if( self.ammo[AMMOTYPE_Shells] <= 20 )
	    mdl = "maps/b_shell0.bsp";
	  else
	    mdl = "maps/b_shell1.bsp";
	}
      else
	mdl = "progs/backpack.mdl";
    }
  self.think = th_item;
  self.touch = touch_ammo;
  precache_model( mdl );
  setmodel( self, mdl );
  //self.vis_model = mdl;
  setmodel( self, mdl );
  self.vismodel_index = self.modelindex;
  self.solid = SOLID_TRIGGER;
  self.noise = "weapons/lock4.wav";
  setsize( self, '0 0 0', '32 32 56' );
  floor_check();
}
// health giver
void setdefaults_item_health()
{
  if( !self.wait )
    self.wait = 20;
  if( !self.health )
    {
      if( self.spawnflags & H_ROTTEN )
	self.health = 10;
      else if( self.spawnflags & H_MEGA )
	self.health = 100;
      else
	self.health = 25;
    }
}
void init_item_health()
{
  if( self.health < 25 )
    {
      precache_model( "maps/b_bh10.bsp" );
      setmodel( self, "maps/b_bh10.bsp" );
      precache_sound( "items/r_item1.wav" );
      self.noise = "items/r_item1.wav";
    }
  else if( self.health < 100 )
    {
      precache_model("maps/b_bh25.bsp");
      setmodel( self, "maps/b_bh25.bsp" );
      precache_sound( "items/health1.wav" );
      self.noise = "items/health1.wav";
    }
  else
    {
      precache_model("maps/b_bh100.bsp");
      setmodel( self, "maps/b_bh100.bsp" );
      precache_sound( "items/r_item2.wav" );
      self.noise = "items/r_item2.wav";
    }
  self.solid = SOLID_TRIGGER;
  setsize( self, '0 0 0', '32 32 56' );
  //self.vis_model = self.model;
  self.vismodel_index = self.modelindex;
  self.think = th_item;
  self.touch = touch_health;
  floor_check();
}
// weapon giver
void setdefaults_item_weapon()
{
  switch( self.classname )
    {
    default:
      break;
    case "weapon_supershotgun":
      self.weaponid = WEAPID_supershotgun;
      break;
    case "weapon_nailgun":
      self.weaponid = WEAPID_nailgun;
      break;
    case "weapon_supernailgun":
      self.weaponid = WEAPID_supernailgun;
      break;
    case "weapon_grenadelauncher":
      self.weaponid = WEAPID_grenadelauncher;
      break;
    case "weapon_rocketlauncher":
      self.weaponid = WEAPID_rocketlauncher;
      break;
    case "weapon_lightning":
      self.weaponid = WEAPID_lightning;
      break;
    }

  if( !self.wait )
    self.wait = 20;
}
void init_item_weapon()
{
  string wmodel = "";
  switch( self.weaponid )
    {
    case WEAPID_nailgun:
      wmodel = "progs/g_nail.mdl";
      break;
    case WEAPID_supernailgun:
      wmodel = "progs/g_nail2.mdl";
      break;
    case WEAPID_grenadelauncher:
      wmodel = "progs/g_rock.mdl";
      break;
    case WEAPID_rocketlauncher:
      wmodel = "progs/g_rock2.mdl";
      break;
    case WEAPID_lightning:
      wmodel = "progs/g_light.mdl";
      break;
    case WEAPID_supershotgun:
    default:
      wmodel = "progs/g_shot.mdl";
      break;
    }
  precache_model( wmodel );
  setmodel( self, wmodel );
  self.solid = SOLID_TRIGGER;
  setsize( self, '-16 -16 0', '16 16 56' );
  self.vismodel_index = self.modelindex;
  self.think = th_item;
  self.touch = touch_weapon;
  self.noise = "weapons/pkup.wav";
  floor_check();
}
// powerup
void setdefaults_item_powerup()
{
  switch( self.classname )
    {
    case "item_artifact_envirosuit":
      self.weaponid = POWER_Envsuit;
      self.model = "progs/suit.mdl";
      self.noise = "items/suit.wav";
      self.wait = 60;
      break;
    case "item_artifact_invisibility":
      self.weaponid = POWER_Invis;
      self.model = "progs/invisibl.mdl";
      self.noise = "items/inv1.wav";
      self.wait = 2*60;
      break;
    case "item_artifact_super_damage":
      self.weaponid = POWER_Quad;
      self.model = "progs/quaddama.mdl";
      self.noise = "items/damage.wav";
      self.wait = 2*60;
      break;
    case "item_artifact_invulnerability":
      self.weaponid = POWER_Pent;
      self.model = "progs/invuler.mdl";
      self.noise = "items/protect.wav";
      self.wait = 5*60;
      break;
    }
}
void init_item_powerup()
{
  precache_model( self.model );
  setmodel( self, self.model );
  self.solid = SOLID_TRIGGER;
  setsize (self, '-16 -16 -24', '16 16 32');
  self.vismodel_index = self.modelindex;
  self.think = th_item;
  self.touch = touch_powerup;
  floor_check();
}
