{ theme, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = theme.font.family;
      size = theme.font.size.normal;
    };

    settings = {
      background = theme.colors.background;
      foreground = theme.colors.foreground;

      background_opacity = theme.opacity.background;
      dynamic_background_opacity = "yes";

      window_padding_width = theme.radius;
      hide_window_decorations = "yes";

      confirm_os_window_close = 0;
    };
  };
}
