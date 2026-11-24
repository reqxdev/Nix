{
  description = "Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      username = "Paul";

      installer = pkgs.writeShellApplication {
        name = "install-nix";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.e2fsprogs
          pkgs.gnugrep
          pkgs.iputils
          pkgs.gnused
          pkgs.nixos-install-tools
          pkgs.systemd
          pkgs.util-linux
          disko.packages.${system}.disko
        ];
        text = ''
          export INSTALL_FLAKE=${pkgs.lib.escapeShellArg "${self}#Nix"}
          export INSTALL_USER=${pkgs.lib.escapeShellArg username}
          export INSTALL_SOURCE=${pkgs.lib.escapeShellArg "${self}"}
        '' + builtins.readFile ./install.sh;
      };
    in
    {
      apps.${system}.install = {
        type = "app";
        program = "${installer}/bin/install-nix";
        meta.description = "Interactively erase a disk and install Nix";
      };

      packages.${system}.install = installer;

      diskoConfigurations.install =
        { device, ... }:
        {
          disko.devices = {
            disk.main = (import ./disko.nix).disko.devices.disk.main // {
              inherit device;
            };
          };
        };

      nixosConfigurations.Nix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit username; };

        modules = [
          ./configuration.nix
          ./disko.nix
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs.theme = import ./home/theme.nix;
              users.${username} = import ./home.nix;
            };
          }
        ];
      };
    };
}
