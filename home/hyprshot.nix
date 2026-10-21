{ config, pkgs, ... }:

let
  hyprshotFreeze = pkgs.writeShellApplication {
    name = "hyprshot-freeze";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.hyprshot
      pkgs.wayfreeze
    ];
    text = ''
      wayfreeze &
      freeze_pid=$!

      cleanup() {
        kill "$freeze_pid" 2>/dev/null || true
        wait "$freeze_pid" 2>/dev/null || true
      }
      trap cleanup EXIT INT TERM

      sleep 0.1
      hyprshot "$@"
    '';
  };
in {
  home.sessionVariables = {
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };

  home.packages = [ hyprshotFreeze ];
}
