typedef struct weapon_t{//note: this or any other struct cannot be an entity member
  void() action[WACT_ArrayMax];
  void( entity tgt ) wield;
  float ammotype;
}weapon_t;
typedef entity list_t;

typedef struct aiaction_t{
  void() perform;
  float() evaluate;
}aiaction_t;
