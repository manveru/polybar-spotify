# polybar-spotify
Little tool to get spotify info from dbus

If you're using [home-manager](https://github.com/rycee/home-manager) you can use it like this:

    "module/spotify" = let
      polybar-spotify = import (fetchGit {
        url = "https://github.com/manveru/polybar-spotify.git";
        ref = "0.2.0";
      }) {};
    in {
      type = "custom/script";
      exec = "${polybar-spotify}/bin/polybar-spotify %xesam:artist% - %xesam:title%";
      tail = true;
      interval = 2;
    };
