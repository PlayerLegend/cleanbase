void item_health()
{
  setdefaults_item_health();
  init_item_health();
}
void item_weapondrop()
{
  setdefaults_item_weapon();
  init_item_weapon();
}
void item_ammo()
{
  setdefaults_item_ammo();
  init_item_ammo();
}
void item_powerup()
{
  setdefaults_item_powerup();
  init_item_powerup();
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// compat

float WEAPON_BIG2 = 1;
float WEAPON_SHOTGUN = 1;
float WEAPON_ROCKET = 2;
float WEAPON_SPIKES = 4;
float WEAPON_BIG = 8;
void weapon_supershotgun()
{
  item_weapondrop();
}
void weapon_nailgun()
{
  item_weapondrop();
}
void weapon_supernailgun()
{
  item_weapondrop();
}
void weapon_grenadelauncher()
{
  item_weapondrop();
}
void weapon_rocketlauncher()
{
  item_weapondrop();
}
void weapon_lightning()
{
  item_weapondrop();
}
//ammo
void item_shells()
{
  if( self.spawnflags & WEAPON_BIG2 )
    self.ammo_shells = 40;
  else
    self.ammo_shells = 20;
  item_ammo();
}
void item_spikes()
{
  if( self.spawnflags & WEAPON_BIG2 )
    self.ammo_nails = 50;
  else
    self.ammo_nails = 25;
  item_ammo();
}
void item_rockets()
{
  if( self.spawnflags & WEAPON_BIG2 )
    self.ammo_rockets = 10;
  else
    self.ammo_rockets = 5;
  item_ammo();
}
void item_cells()
{
  if( self.spawnflags & WEAPON_BIG2 )
    self.ammo_cells = 12;
  else
    self.ammo_cells = 6;
  item_ammo();
}
void item_weapon() //it's actually ammo, see item_weapondrop for weapons
{
  if( self.spawnflags & WEAPON_SHOTGUN )
    {
      item_shells();
      return;
    }
  self.spawnflags &= ~1;
  if( self.spawnflags & WEAPON_BIG )
    self.spawnflags |= WEAPON_BIG2;
  if( self.spawnflags & WEAPON_ROCKET )
    item_rockets();
  if( self.spawnflags & WEAPON_SPIKES )
    item_spikes();
}
void item_artifact_envirosuit()
{
  item_powerup();
}
void item_artifact_invisibility()
{
  item_powerup();
}
void item_artifact_super_damage()
{
  item_powerup();
}
void item_artifact_invulnerability()
{
  item_powerup();
}
