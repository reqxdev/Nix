{
  config,
  lib,
  pkgs,
  ...
}:

let
  hyprpaperConfig = pkgs.writeText "hyprpaper.conf" (
    lib.hm.generators.toHyprconf {
      attrs = config.services.hyprpaper.settings;
      inherit (config.services.hyprpaper) importantPrefixes;
    }
  );

  validatedHyprlandConfig = pkgs.runCommand "hyprland-config" { } ''
    mkdir -p "$out/modules"
    cp ${./hyprland/hyprland.lua} "$out/hyprland.lua"
    cp -r ${./hyprland/modules}/. "$out/modules/"
    cp ${hyprpaperConfig} "$out/hyprpaper.conf"

    for file in "$out/hyprland.lua" "$out"/modules/*.lua; do
      ${pkgs.lua}/bin/luac -p "$file"
    done
  '';
in
{
  xdg.configFile = {
    hypr = {
      source = validatedHyprlandConfig;
    };

    "hypr/hyprpaper.conf".enable = lib.mkForce false;
  };
}
