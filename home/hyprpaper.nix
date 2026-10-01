{ ... }:

let
  wallpaper = "${../assets/wallpapers/mountain.jpg}";
in
{
  services.hyprpaper = {
    enable = true;

    settings = {
      splash = false;

      preload = [
        wallpaper
      ];

      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
        }
      ];
    };
  };
}
