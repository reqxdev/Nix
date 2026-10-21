{ config, pkgs, ... }:

{
  imports = [
	./home/default-apps.nix
	./home/fish.nix
	./home/fonts.nix	
	./home/gtk.nix
	./home/hyprland.nix
	./home/hyprpaper.nix
	./home/hyprshot.nix
	./home/kitty.nix
	./home/rofi.nix
	./home/udiskie.nix
	./home/waybar.nix
  ];

  home.username = "Paul";
  home.homeDirectory = "/home/Paul";
  home.stateVersion = "26.05";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    download = "${config.home.homeDirectory}/Downloads";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
  };

  home.packages = with pkgs; [
	firefox	
	chromium
	mpv
	spotify
	steam
	discord
	equibop	
	prismlauncher
	obs-studio				
	codex
	vscode
	jetbrains.idea
	javaPackages.compiler.temurin-bin.jdk-25
	nodejs
	python314
  ];

  xfconf.settings.thunar.hidden-devices = [
    "SCARLETT"
  ];
}
