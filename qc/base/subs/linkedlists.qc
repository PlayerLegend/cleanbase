void list_null( list_t member )
{
  if( member.ll_up )
    member.ll_up.ll_down = member.ll_down;
  if( member.ll_down )
    member.ll_down.ll_up = member.ll_up;
  member.ll_up = world;
  member.ll_down = world;
}
void list_extract( list_t listfrom )
{
  g_list_extracted = listfrom;
  if( listfrom.ll_up )
    listfrom.ll_up.ll_down = listfrom.ll_down;
  if( listfrom.ll_down )
    listfrom.ll_down.ll_up = listfrom.ll_up;

  if( listfrom.ll_up )
    g_list_new = listfrom.ll_up;
  else
    g_list_new = listfrom.ll_down;

  g_list_extracted.ll_up = world;
  g_list_extracted.ll_down = world;
}
entity list_add( list_t member, list_t listto )
{
  list_null( member );
  if( listto.ll_up )
    {
      listto.ll_up.ll_down = member;
      member.ll_up = listto.ll_up;
      member.ll_down = listto.ll_down;
      listto.ll_up = member;
    }
  else if( listto.ll_down )
    {
      member.ll_down = listto.ll_down;
      member.ll_up = listto;
      listto.ll_down.ll_up = member;
      listto.ll_down = member;
    }
  g_list_new = member;
  return member;
}
