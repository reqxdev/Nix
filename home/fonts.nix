{ theme, ... }:

{
  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      sansSerif = [ theme.font.family ];
      serif = [ theme.font.family ];
      monospace = [ theme.font.monospace ];
    };
  };
}
