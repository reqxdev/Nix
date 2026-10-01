{ config, ... }:

{
  home.sessionVariables = {
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };
}
