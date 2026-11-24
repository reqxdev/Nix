{ ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
