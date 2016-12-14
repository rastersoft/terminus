# Terminus #

A new terminal for XWindows

## What is it? ##

There are plenty of graphic terminals for linux, so what makes this one different?

First, it allows to split a window in several tiling subwindows, exactly like the old
Terminator terminal. Of course it can create several simultaneous windows, and have
tabs in each window.

Second, allows to have an always-available drop-down terminal in all screens, with an
appearance similar to the Quake console, exactly like Guake.

Of course, the Guake-like terminal can be split in tiling subwindows.

Third, it has been written in Vala and uses Gtk3, which allows it to take advantage
of the new characteristics available and to use less resources (both guake and terminator
are written in python 2, which needs more memory, and uses Gtk2, which can be considered
obsolete).

## Using it ##

By default, using Shift+F12 will show the Quake-like terminal, but you can change
the key binding by pressing right-click and selecting "Properties".

By default, terminus is launched during startup to check if the user wants to have
the Quake-like terminal available, so just installing it and rebooting will guarantee
to have it. You can also launch it from a terminal.

Currently the number of options modificable is small, but more will become available.

## FAQ ##

Q: I use Gnome-Shell and when I show the Quake terminal, it doesn't get the focus.
A: It seems that installing the "Steal my focus" extension fix it. It can be found at
https://extensions.gnome.org/extension/234/steal-my-focus/

Q: I'm using Wayland, and pressing Alt+F12 (or my keybinding) doesn't show the Quake-like
terminal.
A: That's because Wayland doesn't allow to an application to set its own keybindings. You
have to use the desktop keybindings to launch the script "terminus_showhide.sh", which
makes use of the DBus remote control to show and hide the Quake-like terminal.

In Gnome Shell it is as easy as opening the Settings window, choose the "Keyboard" icon,
and add there the desired hotkey, associating it with "terminus_showhide.sh" program.

## Contacting the author ##

(C) Sergio Costas Rodriguez (raster software vigo)  
rastersoft@gmail.com  
http://www.rastersoft.com  
