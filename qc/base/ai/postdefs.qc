void generic_perform_best_action()
{
  float actnum;
  switch( self.aitype )
    {
    case AITYPE_soldier:
      actnum = soldier_get_best_action();
      ai_soldier_actions[actnum].perform();
      self.last_action = actnum;
      break;
    default:
      bprint(self.classname);
      bprint("generic_get_best_action: nonsense aitype\n");
      break;
    }
}
