{
  programs.fish = {
    enable = true;

    loginShellInit = ''
      if status is-login
        if uwsm check may-start
          exec uwsm start hyprland-uwsm.desktop
        end
      end
    '';
  };
}
