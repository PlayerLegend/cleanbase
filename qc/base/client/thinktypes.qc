//prethinks
void client_prethink_spectator()
{
  
}
void client_prethink_normal()
{
  if( self.health > self.max_health )
    {
      self.health -= 0.5*frametime;
    }
  normal_button_actions();
  normal_impulse_actions();

}
void client_prethink_dead()
{
  if( self.view_ofs_z > -8 )
    self.view_ofs_z -= 1.5;
  if( self.button0 && (self.weaponwait < time) )
    {
      player_spawnsetup();
      return;
    }
}
//postthinks
void client_postthink_normal()
{
  liquid_checks();
  if( self.deadflag )
    {
      player_obituary();
      self.sub_die();
      if( self.killedby )
	logfrag( self, self.killedby );
      return;
    }
  client_powerup_effects();
  player_feelpain();
}
void client_postthink_dead()
{
  player_feelpain();
}
void client_postthink_spectator()
{
}
