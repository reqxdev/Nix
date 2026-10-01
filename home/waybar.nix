{ theme, ... }:

{
  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
      targets = [ "graphical-session.target" ];
    };

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        reload_style_on_change = true;

        modules-left = [
          "temperature"
          "cpu"
          "memory"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "battery"
          "wireplumber"
        ];

        # CPU temperature
        temperature = {
          format = " {temperatureC}°C";
          tooltip = true;
        };

        # CPU usage
        cpu = {
          format = "󰍛 {usage}%";
          tooltip = true;
        };

        # RAM usage
        memory = {
          format = " {percentage}%";
          tooltip = true;
        };

        # Clock + date
        clock = {
          format = "{:%H:%M | %a %d %b}";
          tooltip = false;
        };

        # Battery
        battery = {
          interval = 30;
          format = "󰁹 {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-full = "󰁹 {capacity}%";
          tooltip = true;
        };

        # Volume
        wireplumber = {
          format = " {volume}%";
          format-muted = "󰝟 muted";
          tooltip = true;
        };

      };
    };

    style = ''
      * {
        font-family: "${theme.font.family}", "Symbols Nerd Font", sans-serif;
        font-size: ${toString theme.font.size.medium}px;
        color: ${theme.colors.foreground};
        background: transparent;
      }

      window#waybar {
        background: transparent;
      }

      #clock,
      #temperature,
      #cpu,
      #memory,
      #battery,
      #wireplumber {
        background-color: ${theme.colors.glass.bar};
        color: ${theme.colors.foreground};
        border: 1px solid ${theme.colors.glass.border};
        border-radius: ${toString theme.radius}px;
        padding: 0 ${toString theme.radius}px;
        margin: 6px 4px;
        font-weight: 600;
      }

      #clock {
        font-size: ${toString theme.font.size.large}px;
        font-weight: bold;
        padding: 0 20px;
      }

    '';
  };
}
