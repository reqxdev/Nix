{
  description = "MyNixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    codex-nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
                codex = _prev.stdenvNoCC.mkDerivation (finalAttrs: {
                  pname = "codex";
                  version = "0.163.0";
                  src = _prev.fetchurl {
                    url = "https://github.com/openai/codex/releases/download/rust-v${finalAttrs.version}/codex-package-x86_64-unknown-linux-musl.tar.gz";
                    sha256 = "582646c6bf0561eb0de540f7fc85b9121b0091a826bc6e96830b7f1722122182";
                  };
                  sourceRoot = ".";
                  nativeBuildInputs = [ _prev.installShellFiles ];
                  dontConfigure = true;
                  dontBuild = true;
                  dontFixup = true;
                  installPhase = ''
                    runHook preInstall
                    mkdir -p $out
                    cp -r bin codex-package.json codex-path codex-resources $out/
                    installShellCompletion --cmd codex \
                      --bash <($out/bin/codex completion bash) \
                      --fish <($out/bin/codex completion fish) \
                      --zsh <($out/bin/codex completion zsh)
                    runHook postInstall
                  '';
                  doInstallCheck = true;
                  installCheckPhase = ''
                    $out/bin/codex --version | grep -Fx "codex-cli ${finalAttrs.version}"
                    $out/bin/codex-code-mode-host --help >/dev/null
                  '';
                  meta = codex-nixpkgs.legacyPackages."x86_64-linux".codex.meta // {
                    platforms = [ "x86_64-linux" ];
                  };
                });
              })
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs.theme = import ./home/theme.nix;
              users.Paul = import ./home.nix;
            };
          }
        ];
      };
    };
}
