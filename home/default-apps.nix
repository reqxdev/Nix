{ ... }:

{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
      "application/x-gnome-saved-search" = [ "thunar.desktop" ];
    };

    associations.removed = {
      "inode/directory" = [ "kitty-open.desktop" ];
    };
  };
}
