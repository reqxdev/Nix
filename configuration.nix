{ lib, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./system/bluetooth.nix
    ./system/fonts.nix
    ./system/hyprland.nix
    ./system/obs.nix
    ./system/tailscale.nix
    ./system/thunar.nix
  ]
  ++ lib.optional (builtins.pathExists ./extra-drives.nix) ./extra-drives.nix;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "Nix";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";

  users.mutableUsers = true;
  users.users.${username} = {
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  programs.fish.enable = true;
  services.getty.autologinUser = username;

  environment.systemPackages = with pkgs; [
    zip
    unzip
    git
    gh
    pavucontrol
    blueman
    wl-clipboard
    hyprshot
    thunar
  ];

  system.stateVersion = "26.05";
}
