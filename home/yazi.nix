{
  programs.yazi = {
    enable = true;

    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "<C-c>" ];
          run = "shell --orphan 'printf \"file://%s\\n\" $argv | wl-copy --foreground -t text/uri-list' -- %s";
          desc = "Copy file(s) to system clipboard";
        }
      ];
    };
  };
}
