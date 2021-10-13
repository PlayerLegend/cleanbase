//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// patchwork for bugs
entity find( entity start, .string fld, string match )
{
  if( match == "" )
    return world;
  else
    return find_unsafe( start, fld, match );
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//math
float fmax( float f1, float f2 ) { return (f1 > f2)?f1:f2; }
float fmin( float f1, float f2 ) { return (f1 < f2)?f1:f2; }
float square( float f ) { return f*f; };
float sqlen( vector v ) { return v*v; }
float crandom() {return random() - 0.5;}
vector vabs( vector v )
{
  return [ fabs(v_x), fabs(v_y), fabs(v_z) ];
}
vector vmax( vector v1, vector v2 )
{
  return [ fmax( v1_x, v2_x ), fmax( v1_y, v2_y ), fmax( v1_z, v2_z ) ];
}
vector crossprod( vector v1, vector v2 )
{
  return [ v1_y*v2_z - v1_z*v2_y, -(v1_x*v2_z - v1_z*v2_x), v1_x*v2_y - v1_y*v2_x ];
}
float anglemod( float f )
{
  while( f < 180 )
    f += 360;
  while( f > 180 )
    f -= 360;
  return f;
}
vector vectormod( vector v )
{
  return [ anglemod( v_x ), anglemod( v_y ), anglemod( v_z ) ];
}
float sin( float rad )
{
  if( rad < 0 )
    rad = M_2mPI - fabs( rad % M_2mPI );
  else
    rad = rad % M_2mPI;
  rad = -rad + M_PI;
  return M_PId8*rad*(M_PI - fabs(rad));
}
float cos( float rad )
{
  return sin( rad + M_PId2 );
}
float range( float val, float min, float max )
{
  if( val < min )
    return min;
  else if( val > max )
    return max;
  else
    return val;
}
vector vectorrange( vector v, vector minv, vector maxv )
{
  return [ range(v_x, minv_x, maxv_x), range(v_y, minv_y, maxv_y), range(v_z, minv_z, maxv_z) ];
}
float incrange( float val, float min, float max )
{
  if( (val <= max) && (val >= min) )
    return 1;
  else
    return 0;
}
float exrange( float val, float min, float max )
{
  if( (val < max) && (val > min) )
    return 1;
  else
    return 0;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  targets

// targetname changing
entity make_targetlist( string name ) //group all entities with targetname 'name' into list .l_targetname
{
  entity first = find( world, targetname, name );
  entity cursor = first;
  entity lcursor = first;

  while( (cursor = find( cursor, targetname, name )) )
    {
      lcursor.l_targetname = cursor;
      lcursor = cursor;
    }
  return first;
}
void apply_targetlist( entity firstmem )//sets .e_target for all entities looking for firstmem & similar
{
  entity cursor = world;
  while( (cursor = find( cursor, target, firstmem.targetname )) )
    cursor.e_target = firstmem;
}
void settargetname( entity tgt, string name )//sets tgt's targetname to name and moves tgt to a list of ents with same targetname, if name == "", removes from list
{
  string oldname;
  if( tgt.targetname == name )
    apply_targetlist( make_targetlist( name ) );
  oldname = tgt.targetname;
  tgt.targetname = name;

  if( oldname != "" )
    apply_targetlist( make_targetlist( oldname ) );
  if( name != "" )
    apply_targetlist( make_targetlist( name ) );  
}
// target changing
void settarget( entity tgt, string name )
{
  tgt.target = name;
  tgt.e_target = find( world, targetname, name );
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   misc
void remove( entity tgt )
{
  settargetname( tgt, "" );//remove from target lists
  //.activators list doesn't care about removals
  unsafe_remove( tgt );
}
void SUB_Remove()
{
  remove( self );
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  null primitives
void SUB_Null() = {};
void SUB_PAIN_Null( entity taker, float damage, float fl_damage, float id_damage ){};
float SUB_Null_float() = {return -1;};
aiaction_t NULL_ACTION = { SUB_Null, SUB_Null_float };

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  animation
void sub_animate( float beginframe, float endframe, float framewait, float animflags )
{
  if( self.nextframe > time )
    return;
  self.startframe = beginframe;
  self.finalframe = endframe;
  self.nextframe = time + framewait;
  self.frame += 1;
  if( (self.frame < beginframe) || (self.frame > endframe) )
    self.frame = beginframe;
  if( self.frame == endframe )
    {
      self.animcount += 1;
      if( animflags & GENFL_AnimPlayOnce )
	self.sub_animation = SUB_Null;
    }
  return;
}
void sub_resetanimdata( entity tgt )
{
  tgt.animcount = 0;//new animation
  tgt.nextframe = 0;//make sure there's no leftover wait
  tgt.frame = -1;//make sure the animation plays again, even if you're part way through it
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// combat
void sub_muzzleflash()
{
  WriteByte( MSG_MULTICAST, SVC_MUZZLEFLASH );
  WriteEntity( MSG_MULTICAST, self );
  multicast( self.origin, MULTICAST_PVS );
}
float sub_damage( entity attacker, entity target, float rawdamage, float fl_damage, float id_damage )
{
  float damage = rawdamage;

  if( !target.takedamage )
    return 0;

  if( !target.damageratio )
    bprint("warn: target does not have a damageratio set\n");

  if( target.power_finished[POWER_Pent] > time )//do no damage and play pent sound
    {
      sound( target, CHAN_VOICE, "items/protect.wav", 1, ATTN_NORM );
      return 0;
    }
  
  if( attacker.power_finished[POWER_Quad] > time )
    {
      damage *= 4;
    }
  
  damage *= target.damageratio;

  target.health -= damage;

  if( target.painid == id_damage )
    target.maxpain += damage;
  else if( target.maxpain < damage )
    {
      target.maxpain = damage;
      target.painid = id_damage;
      target.painfl = fl_damage;
    }

  if( (target.health < 1) && !target.deadflag )
    {
      target.killedby = attacker;
      target.deadflag = DEAD_DEAD;
    }

  target.sub_pain( target, damage, fl_damage, id_damage );

  return damage;
}
float area_damage( entity attacker, float rawdamage, float fl_damage, float id_damage, vector org, float rad, float owner_damage_ratio, entity ignore )
{
  entity tmp, cursor = findradius( org, rad );//tmp is used to keep this working if an entity removes itself when damaged
  float d;
  float totdamage = 0;
  while( cursor )
    {
      traceline( org, cursor.origin, TRUE, cursor );
      tmp = cursor.chain;
      if( (cursor != ignore) && (trace_fraction == 1.0) )
	{
	  if( cursor == attacker )	
	    {
	      d = owner_damage_ratio*rawdamage*(1 - vlen(cursor.origin - org)/rad);
	      totdamage += sub_damage( attacker, cursor, d, fl_damage, id_damage );
	    }
	  else
	    {
	      d = rawdamage*vlen(cursor.origin - org)/rad;
	      totdamage += sub_damage( attacker, cursor, d, fl_damage, id_damage );
	    }
	  if( cursor.movetype == MOVETYPE_WALK )
	    cursor.velocity += 20*normalize(cursor.origin - org)*d;
	}
      cursor = tmp;
    }
  return totdamage;
}
void sub_autohurt()
{
  sub_damage( world, other, self.damage, 0, DAMID_Mystery );
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// misc
void sub_explosion( vector org )
{
  WriteByte( MSG_MULTICAST, SVC_TEMPENTITY );
  WriteByte( MSG_MULTICAST, TE_EXPLOSION );
  WriteCoord( MSG_MULTICAST, org_x );
  WriteCoord( MSG_MULTICAST, org_y );
  WriteCoord( MSG_MULTICAST, org_z );
  multicast( org, MULTICAST_PHS );
}
void sub_lightning( entity owner, vector v1, vector v2 )
{
  WriteByte( MSG_BROADCAST, SVC_TEMPENTITY );
  WriteByte( MSG_BROADCAST, TE_LIGHTNING2 );
  
  WriteEntity( MSG_BROADCAST, owner );
  
  WriteCoord( MSG_BROADCAST, v1_x );
  WriteCoord( MSG_BROADCAST, v1_y );
  WriteCoord( MSG_BROADCAST, v1_z );
  
  WriteCoord( MSG_BROADCAST, v2_x );
  WriteCoord( MSG_BROADCAST, v2_y );
  WriteCoord( MSG_BROADCAST, v2_z );
}
float sub_toggleflag( float field, float flag )
{
  if( field & flag )
    return field & (~flag);
  else
    return field | flag;
}
float has_weapon( entity tgt, float weapid )
{
  float i;
  for( i = 0; i < WEAP_SLOTS; i++ )
    {
      if( tgt.weaponslot[i] == weapid )
	return 1;
    }
  return 0;
}
float weaponid_to_ammotype( float weapid )
{
  return weaponlist[weapid].ammotype;
}
void give_ammo( entity tgt, float amtype, float ammount )
{
  tgt.ammo[amtype] = fmin( tgt.ammo[amtype] + ammount, tgt.maxammo[amtype] );
}
float has_maxammo( entity tgt, float amtype )
{
  if( tgt.ammo[amtype] < tgt.maxammo[amtype] )
    return 0;
  else
    return 1;
}
void copy_ammovals_to_array()//used when spawning ammo boxes
{
  self.ammo[AMMOTYPE_Shells] = self.ammo_shells;
  self.ammo[AMMOTYPE_Nails] = self.ammo_nails;
  self.ammo[AMMOTYPE_Rockets] = self.ammo_rockets;
  self.ammo[AMMOTYPE_Cells] = self.ammo_cells;
}
string unique_name()
{
  return vtos( self.mins + self.origin + self.maxs + [random(),0,random()] );
}
void th_door();
void th_plat();
void th_button();
void th_door_secret();
float predict_ready_time( entity tgt )//If applicable, run BEFORE changing target's goal/direction
{
  if( tgt.wait < 0 )
    return -1;
  if( (tgt.movetype == MOVETYPE_PUSH) && (tgt.speed == 0) )
    return -1;
  switch( tgt.think )
    {
    case th_door:
      if( tgt.spawnflags & DOOR_TOGGLE )//if false, uses the same as th_button and th_plat
	return time + self.wait;// + tgt.wait + vlen( tgt.origin - tgt.start_origin )/tgt.speed;
    case th_button:
    case th_plat:
      return time + tgt.wait + vlen( tgt.origin - tgt.end_origin )/tgt.speed;
    case th_door_secret:
      if( (self.move_state == 0) || (self.move_state > 2) )
	return time + 1 + (vlen( self.origin - self.mid_origin ) + vlen( self.mid_origin - self.end_origin ))/self.speed + self.wait;
      else
	return time + vlen( self.origin - self.end_origin )/self.speed + self.wait;
    default:
      bprint("default\n");
      return time + tgt.wait;
    }
}
entity sub_telefrag( vector org, float radius, entity executor )//returns world on cleared area, if blocked returns blocking entity
{
  entity cursor;
  cursor = findradius( org, radius );
  while( cursor )
    {
      if( (cursor.takedamage != DAMAGE_AIM) && (cursor.solid == SOLID_SLIDEBOX) )
	return cursor;
      if( cursor == executor )
	{
	  cursor = cursor.chain;
	  continue;
	}
      cursor.solid = SOLID_NOT;
      sub_damage( executor, cursor, 500000, FL_Null, DAMID_Telefrag );
      cursor = cursor.chain;
    }
  return world;
}
