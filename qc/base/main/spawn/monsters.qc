void monster_army()
{
  setorigin( self, self.origin );
  setmodel( self, "progs/soldier.mdl" );
  self.aitype = AITYPE_soldier;
  self.sub_animation = SUB_Null;
  self.default_animation = anim_soldier_stand;
  self.think = th_ai_generic;
  self.nextthink = time + random();
  self.sub_scan = generic_scan;
  self.sub_die = ai_soldier_die;
  self.sub_pain = ai_soldier_sub_pain;
  self.health = 25;
  self.max_health = 25;
  self.bloodtype = BT_Blood;
  self.takedamage = DAMAGE_AIM;
  self.damageratio = 1;

  self.movetype = MOVETYPE_WALK;
  self.solid = SOLID_SLIDEBOX;
  setsize( self, VEC_HULL_MIN, VEC_HULL_MAX );

  self.gravitydir = '0 0 -1';
}
