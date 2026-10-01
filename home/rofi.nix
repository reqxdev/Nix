{ pkgs, theme, ... }:

let
  glassTheme = pkgs.writeText "rofi-neutral-glass.rasi" ''
    * {
        glass-background: ${theme.colors.glass.background};
        glass-surface:    ${theme.colors.glass.surface};
        glass-selected:   ${theme.colors.glass.selected};
        glass-border:     ${theme.colors.glass.border};

        foreground:       ${theme.colors.foreground};
        foreground-muted: ${theme.colors.muted};

        background-color: transparent;
        text-color:       @foreground;
    }

    window {
        transparency:     "real";

        location:         center;
        anchor:           center;
        width:            600px;

        background-color: @glass-background;

        border:           1px;
        border-radius:    ${toString theme.radius}px;
        border-color:     @glass-border;

        padding:          18px;
    }

    mainbox {
        background-color: transparent;

        spacing:          12px;
        padding:          0px;

        children:         [ inputbar, listview ];
    }

    inputbar {
        background-color: @glass-surface;

        border:           1px;
        border-radius:    ${toString theme.radius}px;
        border-color:     @glass-border;

        padding:          12px 14px;
        spacing:          12px;

        children:         [ prompt, entry ];
    }

    prompt {
        background-color: transparent;
        text-color:       @foreground-muted;

        expand:           false;
        padding:          0px 6px 0px 2px;
        margin:           0px;
    }

    entry {
        background-color: transparent;
        text-color:       @foreground;

        placeholder:       "Search applications...";
        placeholder-color: @foreground-muted;
    }

    listview {
        background-color: transparent;

        lines:            8;
        columns:          1;
        fixed-height:     false;
        scrollbar:        false;

        spacing:          5px;
        padding:          0px;
    }

    element {
        background-color: transparent;
        text-color:       @foreground;

        border:           0px;
        border-radius:    ${toString theme.radius}px;

        padding:          10px 12px;
        spacing:          12px;
    }

    element normal.normal {
        background-color: transparent;
        text-color:       @foreground;
    }

    element selected.normal {
        background-color: @glass-selected;
        text-color:       @foreground;
    }

    element selected.active {
        background-color: @glass-selected;
        text-color:       @foreground;
    }

    element selected.urgent {
        background-color: @glass-selected;
        text-color:       @foreground;
    }

    element-icon {
        background-color: transparent;

        size:             28px;
        margin:           0px 4px 0px 0px;
    }

    element-text {
        background-color: transparent;
        text-color:       @foreground;

        vertical-align:   0.5;
    }
  '';
in

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    font = "${theme.font.family} ${toString theme.font.size.medium}";
    terminal = "kitty";
    cycle = true;

    extraConfig = {
      modi = "drun,run";

      show-icons = true;
      icon-theme = "Papirus-Dark";

      # Keep the trailing spaces to prevent the icon being clipped.
      display-drun = "󰍉  ";
      display-run = "󰍉  ";

      drun-display-format = "{name}";

      matching = "fuzzy";
      sort = true;
      click-to-exit = true;
    };

    theme = "${glassTheme}";
  };

  home.packages = with pkgs; [
    papirus-icon-theme
  ];
}
