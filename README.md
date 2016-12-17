# Terminus #

A new terminal for XWindows (and Wayland)


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


## Compiling it ##

Just follow the classic cmake instructions:

    mkdir install
	 cd install
	 cmake ..
	 make
	 sudo make install

If, during cmake stage, you receive an error for missing libraries, install them,
delete all the contents inside *install*, and run cmake again. Launching cmake
in a folder with parts of a previously failed cmake run can result in build errors
(don't ask why).

If your system has an old Gtk version (like Ubuntu yakkety yak, which has Gtk 3.20),
you would need to define GTK_3_20 to use some old functions, not available in versions
older than Gtk 3.22. You can do it this way:

	mkdir install
	cd install
	cmake .. -DGTK_3_20=on
	make
	sudo make install


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
A: That's because Wayland doesn't allow to an application to set its own keybindings.
Fortunately, Terminus includes a Gnome Shell extension that allows to show the Quake-like
terminal. If you have installed Terminus, just exit your session, enter again, and enable
the extension with gnome-tweak-tool.

Another way is using the desktop keybindings to launch the script "terminus_showhide.sh",
which makes use of the DBus remote control to show and hide the Quake-like terminal.

In Gnome Shell it is as easy as opening the Settings window, choose the "Keyboard" icon,
and add there the desired hotkey, associating it with "terminus_showhide.sh" program.


## Contacting the author ##

(C) Sergio Costas Rodriguez (raster software vigo)  
rastersoft@gmail.com  
http://www.rastersoft.com  
