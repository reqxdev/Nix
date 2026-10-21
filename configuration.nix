{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "MyNix";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";

  users.mutableUsers = true;
  users.users.Paul = {
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  programs.fish.enable = true;
  services.getty.autologinUser = "Paul";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  programs.xfconf.enable = true;
  services.udisks2.enable = true;

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
