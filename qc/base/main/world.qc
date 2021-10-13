void main()
{
  allprecache_main();
}
void worldspawn()
{
  allprecache_sounds();
  allprecache_models();
  setup_lightstyles();
  init_weapons();

  g_framenum = 0;
}
void SetNewParms()
{
  
}
void SetChangeParms()
{
  
}
void StartFrame()
{
  g_framenum += 1;
}
