void switch_to_slot( entity tgt, float slotnum )
{
  tgt.weaponslotnum = slotnum;
  weaponlist[tgt.weaponslot[slotnum]].wield( tgt );
}
void impulse_switchweapon() //switches weapons based on impulse
{
  if( (self.impulse < WEAPON_IMPULSE_MIN) || (self.impulse > WEAPON_IMPULSE_MAX) || (!incrange(self.weaponwait, 0, time)) || (self.weaponslotnum == (self.impulse - WEAPON_IMPULSE_MIN)) )
    return;
  switch_to_slot( self, self.impulse - WEAPON_IMPULSE_MIN);
}
void give_weapon( entity tgt, float weapid, float slot ) //give tgt a weapon
{
  tgt.weaponslot[slot] = weapid;
  if( slot == tgt.weaponslotnum )
    weaponlist[weapid].wield( tgt );
}
float ideal_slot( float weapid ) //returns the best slot for a weapon id
{
  return range( weapid - 1, 0, MAX_WEAPID );
}
