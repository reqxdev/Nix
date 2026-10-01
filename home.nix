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
	./home/yazi.nix
  ];

  home.username = "rex";
  home.homeDirectory = "/home/rex";
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
	wl-clipboard
	hyprshot
	thunar
	firefox	
	chromium
	discord
	steam
	spotify
	prismlauncher
	obs-studio				
	codex
	vscode
	nodejs
	jetbrains.idea
	javaPackages.compiler.temurin-bin.jdk-25
  ];

  xfconf.settings.thunar.hidden-devices = [
    "SCARLETT"
  ];
}
