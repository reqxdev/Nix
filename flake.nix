{
  description = "MyNixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    codex-nixpkgs.url = "github:NixOS/nixpkgs/0e34c168e6de5597105b92a46e94eee4d7f592d3";
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
    { self, nixpkgs, codex-nixpkgs, home-manager, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      installer = pkgs.writeShellApplication {
        name = "install-mynix";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.iputils
          pkgs.gnused
          pkgs.nixos-install-tools
          pkgs.util-linux
          disko.packages.${system}.disko
        ];
        text = ''
          export MYNIX_FLAKE=${pkgs.lib.escapeShellArg "${self}#MyNix"}
          export MYNIX_SOURCE=${pkgs.lib.escapeShellArg "${self}"}
        '' + builtins.readFile ./install.sh;
      };
    in
    {
      apps.${system}.install = {
        type = "app";
        program = "${installer}/bin/install-mynix";
        meta.description = "Interactively erase a disk and install MyNixOS";
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

      nixosConfigurations.MyNix = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix
          ./disko.nix
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              (_final: _prev: {
                codex = codex-nixpkgs.legacyPackages."x86_64-linux".codex;
              })
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs.theme = import ./home/theme.nix;
              users.rex = import ./home.nix;
            };
          }
        ];
      };
    };
}
