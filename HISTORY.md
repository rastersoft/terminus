# History of versions #

* Version 0.11.0 (2018-3-25)
  * Now the CAPS LOCK state doesn't interfere with the hot keys
  * Several fixes to the Debian packaging files (thanks to Barak)
* Version 0.10.0 (2017-12-03)
  * Now guake mode works better under Wayland
* Version 0.9.1 (2017-10-13)
  * Now doesn't lock gnome shell under wayland for 20 seconds when there are no instances of terminus running and the user presses the key to show the guake terminal
* Version 0.9.0 (2017-10-12)
  * Now the guake-style window won't get stuck in maximized mode when resized too big
  * Now the guake mode works fine if all terminus sessions are killed and is relaunched via D-Bus
  * Now, when closing the terminal in an split window, the other terminal will receive the focus
* Version 0.8.1 (2017-09-18)
  * Fixed the install path when creating packages
  * Fixed the gnome shell extension, now it works on gnome shell 3.24 and 3.26
  * Forced GTK version to 3, to avoid compiling with GTK 4
* Version 0.8.0 (2017-08-01)
  * Fixed some startup bugs
* Version 0.7.0 (2016-12-24)
  * Added full palette support
  * Added all palette styles from gnome-terminal
  * Added Solarized palette
  * Allows to set the preferred shell
  * Allows to configure more details (cursor shape, using bolds, rewrap on resize, and terminal bell)
* Version 0.6.0 (2016-12-17)
  * Added a Gnome Shell extension, to allow to use the quake-terminal mode under Wayland with Gnome Shell
  * Fixed the top bar (sometimes it didn't show the focus)
  * Removed several deprecated functions
* Version 0.5.0 (2016-12-12)
  * Added Wayland support
  * Added DBus remote control
* Version 0.4.0 (2016-09-17)
  * Fixed the window size during startup
  * Fixed resize bug when moving the mouse too fast
  * Fixed the "Copy" function. Now it copies the text to the clipboard
* Version 0.3.0 (2016-08-24)
  * Fixed compilation paths
  * Now can be compiled with valac-0.30
  * Added package files
* Version 0.2.0 (2016-08-24)
  * Fixed resizing
  * Cyclic jump from tab to tab using Page Down and Page Up
  * Added note in the README to fix the focus problem in Gnome Shell
* Version 0.1.0 (2016-08-23)
  * First public version
