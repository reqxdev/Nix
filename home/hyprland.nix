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

  # A malformed Lua file otherwise reaches Home Manager successfully and only
  # fails after Hyprland reloads it. Validate every Lua file's syntax while the
  # system closure is built, before activation can replace a working config.
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
  # Own the complete Hypr directory as one immutable store link. Home Manager's
  # backup policy preserves the old directory during the first activation.
  xdg.configFile = {
    hypr = {
      source = validatedHyprlandConfig;
    };

    # Hyprpaper normally creates this as a separate Home Manager file. Its
    # generated contents are included in the directory above instead.
    "hypr/hyprpaper.conf".enable = lib.mkForce false;
  };
}
