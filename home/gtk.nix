{ pkgs, theme, ... }:

let
  osuCursorTheme = pkgs.runCommand "osu-cursor-theme" {
    nativeBuildInputs = [
      pkgs.librsvg
      pkgs.xcursorgen
    ];
  } ''
    theme_dir="$out/share/icons/Osu"
    mkdir -p "$theme_dir/cursors"

    cat > cursor.svg <<'EOF'
    <svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96">
      <circle cx="50" cy="50" r="30" fill="none" stroke="#000000" stroke-opacity="0.65" stroke-width="10"/>
      <circle cx="48" cy="48" r="28" fill="#ff66aa" fill-opacity="0.42" stroke="#ffffff" stroke-width="6"/>
      <circle cx="48" cy="48" r="5" fill="#ffffff"/>
    </svg>
    EOF

    : > cursor.conf
    for size in 24 32 48 64 96; do
      rsvg-convert --width "$size" --height "$size" cursor.svg > "cursor-$size.png"
      hotspot=$((size / 2))
      printf '%s %s %s cursor-%s.png\n' "$size" "$hotspot" "$hotspot" "$size" >> cursor.conf
    done

    xcursorgen cursor.conf "$theme_dir/cursors/left_ptr"
    for alias in default arrow top_left_arrow; do
      ln -s left_ptr "$theme_dir/cursors/$alias"
    done

    cat > "$theme_dir/index.theme" <<'EOF'
    [Icon Theme]
    Name=Osu
    Comment=OSU-style circular cursor
    Inherits=Adwaita
    EOF
  '';
in
{
  home.pointerCursor = {
    package = osuCursorTheme;
    name = "Osu";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;

    colorScheme = "dark";

    font = {
      name = theme.font.family;
      size = theme.font.size.normal;
    };

    theme.name = "Adwaita-dark";

    gtk3.extraCss = ''
      @define-color thunar_bg ${theme.colors.glass.background};
      @define-color thunar_surface ${theme.colors.glass.surface};
      @define-color thunar_selected ${theme.colors.glass.selected};
      @define-color thunar_border ${theme.colors.glass.border};
      @define-color thunar_fg ${theme.colors.foreground};
      @define-color thunar_muted ${theme.colors.muted};

      window.thunar {
        background-color: @thunar_bg;
        color: @thunar_fg;
      }

      window.thunar headerbar,
      window.thunar .titlebar,
      window.thunar toolbar,
      window.thunar menubar,
      window.thunar statusbar {
        background-color: transparent;
        background-image: none;
        color: @thunar_fg;
        border: none;
        box-shadow: none;
      }

      window.thunar box,
      window.thunar grid,
      window.thunar paned,
      window.thunar notebook,
      window.thunar notebook stack,
      window.thunar scrolledwindow {
        background-color: transparent;
        color: @thunar_fg;
      }

      window.thunar .standard-view,
      window.thunar .standard-view .view,
      window.thunar .standard-view treeview.view,
      window.thunar .standard-view widget.view,
      window.thunar .sidebar,
      window.thunar .sidebar .view,
      window.thunar .shortcuts-pane,
      window.thunar .shortcuts-pane .view {
        background-color: transparent;
        color: @thunar_fg;
      }

      window.thunar button,
      window.thunar entry {
        background-color: @thunar_surface;
        background-image: none;
        color: @thunar_fg;
        border: 1px solid @thunar_border;
        border-radius: ${toString theme.radius}px;
        box-shadow: none;
      }

      window.thunar headerbar button,
      window.thunar toolbar button,
      window.thunar .path-bar button,
      window.thunar .location-toolbar button,
      window.thunar menubar > menuitem {
        background-color: transparent;
        background-image: none;
        color: @thunar_fg;
        border: none;
        box-shadow: none;
      }

      window.thunar headerbar entry,
      window.thunar toolbar entry,
      window.thunar .location-toolbar entry {
        background-color: transparent;
        background-image: none;
        color: @thunar_fg;
        border: 1px solid @thunar_border;
        box-shadow: none;
      }

      window.thunar button:hover,
      window.thunar button:checked,
      window.thunar button:active,
      window.thunar menubar > menuitem:hover,
      window.thunar entry:focus {
        background-color: @thunar_selected;
        color: @thunar_fg;
        border-color: @thunar_border;
      }

      window.thunar notebook > header {
        background-color: transparent;
        border-color: @thunar_border;
      }

      window.thunar notebook > header tabs tab {
        background-color: @thunar_surface;
        color: @thunar_muted;
        border: 1px solid @thunar_border;
        border-radius: ${toString theme.radius}px;
        margin: 3px;
      }

      window.thunar notebook > header tabs tab:checked {
        background-color: @thunar_selected;
        color: @thunar_fg;
      }

      window.thunar .standard-view .view:selected,
      window.thunar .standard-view .view *:selected,
      window.thunar .standard-view .view:hover,
      window.thunar .sidebar .view:selected,
      window.thunar .sidebar .view *:selected,
      window.thunar .sidebar .view:hover {
        background-color: @thunar_selected;
        color: @thunar_fg;
        border-radius: ${toString theme.radius}px;
      }

      window.thunar paned > separator {
        background-color: @thunar_border;
        min-width: 1px;
        min-height: 1px;
      }

      window.thunar scrollbar {
        background-color: transparent;
      }

      window.thunar scrollbar slider {
        background-color: alpha(@thunar_muted, ${theme.opacity.scrollbar});
        border-radius: ${toString theme.radius}px;
        min-width: 6px;
        min-height: 36px;
      }

      window.thunar .dim-label {
        color: @thunar_muted;
      }
    '';
  };
}
