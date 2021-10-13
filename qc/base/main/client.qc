//connectioning
void ClientKill()
{
  self.health = -1;
  self.deadflag = DEAD_DEAD;
}
void ClientConnect()
{
  dprint("client connected\n");
}
void ClientDisconnect()
{
}

//thinks
void PutClientInServer()
{
  self.think = player_spawnsetup;
  if( time < TIME_POST_SPAWNREADY )
    self.nextthink = TIME_POST_SPAWNREADY;
  else
    player_spawnsetup();
}
void PlayerPreThink()
{
  if( self.cl_thinktype == 0 )//To prevent thinks before client is spawned
    return;
  //per frame setup
  makevectors( self.v_angle );//use this rather than running makevectors on the player
  self_forward = v_forward;
  self_right = v_right;
  self_up = v_up;

  set_buttonflags();

  self.currentammo = self.ammo[weaponid_to_ammotype(self.weaponid)];
  self.ammo_shells = self.ammo[AMMOTYPE_Shells];
  self.ammo_nails = self.ammo[AMMOTYPE_Nails];
  self.ammo_rockets = self.ammo[AMMOTYPE_Rockets];
  self.ammo_cells = self.ammo[AMMOTYPE_Cells];
  

  //prethinks
  switch( self.cl_thinktype )
    {
    case CL_THINK_Normal:
      client_prethink_normal();
      break;
    case CL_THINK_Dead:
      client_prethink_dead();
      break;
    case CL_THINK_Spectator:
      client_prethink_spectator();
      break;
    default:
      dprint("Nonsense .cl_thinktype in client!");
      break;
    }
  
  //animation
  if( self.sub_animation != SUB_Null )
    self.sub_animation();
  else
    self.default_animation();
}
void PlayerPostThink()
{
  switch( self.cl_thinktype )
    {
    case CL_THINK_Normal:
      client_postthink_normal();
      break;
    case CL_THINK_Dead:
      client_postthink_dead();
      break;
    case CL_THINK_Spectator:
      client_postthink_spectator();
      break;
    default:
      break;
    }
  self.impulse = 0;
  self.maxpain = 0;
  self.painid = 0;
  self.painfl = 0;
  self.fl_heldbuttons |= self.fl_buttons;
  self.lastwaterlevel = self.waterlevel;
}
