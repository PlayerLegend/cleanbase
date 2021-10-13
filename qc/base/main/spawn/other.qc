//scenery
void func_wall()
{
  init_bspent();
}
void func_illusionary()
{
  init_bspent();
  self.solid = SOLID_NOT;
  makestatic( self );
}
void func_bossgate()
{
  func_wall();
}
//torches
void light_torch_small_walltorch()
{
  init_torch();
}
void light_flame_large_yellow()
{
  init_torch();
}
void light_flame_small_yellow()
{
  init_torch();
}
void light_flame_small_white()
{
  init_torch();
}
