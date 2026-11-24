{ ... }:
{
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };

  systemd.services.tailscaled = {
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
    unitConfig.StartLimitIntervalSec = 0;
  };
}
