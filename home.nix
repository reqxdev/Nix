{ config, pkgs, ... }:

{
  imports = [
	./home/fish.nix
	./home/fonts.nix	
	./home/gtk.nix
	./home/hyprland.nix
	./home/hyprpaper.nix
	./home/hyprshot.nix
	./home/kitty.nix
	./home/rofi.nix
	./home/thunar.nix
	./home/udiskie.nix
	./home/waybar.nix
  ];

  home.stateVersion = "26.05";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    download = "${config.home.homeDirectory}/Downloads";
    projects = "${config.home.homeDirectory}/Projects";

    music = "${config.home.homeDirectory}/Media/Music";
    pictures = "${config.home.homeDirectory}/Media/Pictures";
    videos = "${config.home.homeDirectory}/Media/Videos";
    extraConfig = {
      MOVIES = "${config.home.homeDirectory}/Media/Movies";
      TV = "${config.home.homeDirectory}/Media/TV";
    };

    documents = null;
    publicShare = null;
    templates = null;
  };

  home.packages = with pkgs; [
	firefox	
	chromium
	mpv
	spotify
	discord
	prismlauncher
	obs-studio				
	vscode
	javaPackages.compiler.temurin-bin.jdk-25
  ];

  xfconf.settings.thunar.hidden-devices = [
    "SCARLETT"
  ];
}
