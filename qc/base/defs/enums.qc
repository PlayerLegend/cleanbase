//client think types, used for cl_thinktype
enum {
  CL_THINK_Unspawned,
  CL_THINK_Spectator,
  CL_THINK_Normal,
  CL_THINK_Dead,
};

enum {//weapon id's
  WEAPID_noweapon,
  WEAPID_axe,
  WEAPID_shotgun,
  WEAPID_supershotgun,
  WEAPID_nailgun,
  WEAPID_supernailgun,
  WEAPID_grenadelauncher,
  WEAPID_rocketlauncher,
  WEAPID_lightning,
  MAX_WEAPID,
};
enum {//ammo types
  AMMOTYPE_None,
  AMMOTYPE_Shells,
  AMMOTYPE_Nails,
  AMMOTYPE_Rockets,
  AMMOTYPE_Cells,
  MAX_AMMOTYPE,
};
enum { //weapon actions
  WACT_Attack1,
  WACT_Attack2,
  WACT_Reload,
  WACT_ArrayMax,
};
enum {//damage id's - specific damage info
  DAMID_Mystery,
  DAMID_Drown,
  DAMID_Lava,
  DAMID_Slime,
  DAMID_Fall,
  DAMID_Melee,
  DAMID_Bullet,
  DAMID_Blastradius,
  DAMID_Atebomb,
  DAMID_Suicide,
  DAMID_Telefrag,
};
enum {//blood types
  BT_Dust,
  BT_Blood,
  BT_None,
};
enum {//ai types
  AITYPE_none,
  AITYPE_soldier,
  MAX_AITYPE,
};
enum {
  RANGE_Melee,
  RANGE_Near,
  RANGE_Mid,
  RANGE_Far,
  RANGE_NoEnemy,
};
enum {
  AI_Impossible,
  AI_Unimportant,
  AI_Maybe,
  AI_Important,
  AI_Urgent,
  AI_Vital,
};
enum { //powerups
  POWER_Envsuit,
  POWER_Invis,
  POWER_Quad,
  POWER_Pent,
  MAX_POWERS,
};
