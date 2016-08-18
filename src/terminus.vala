/*
 Copyright 2016 (C) Raster Software Vigo (Sergio Costas)

 This file is part of Terminus

 Terminus is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 Terminus is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>. */

using Gtk;
using Gee;

//project version = 0.1.0


Gee.List<Terminus.TerminusWindow> windows;

void create_window(bool guake_mode) {

	var window = new Terminus.TerminusWindow(guake_mode);
	window.ended.connect( (w) => {
		windows.remove(w);
		if (windows.size == 0) {
			Gtk.main_quit();
		}
	});
	window.new_window.connect( () => {
		create_window(false);
	});
	windows.add(window);
}

int main(string[] argv) {

	Intl.bindtextdomain(Constants.GETTEXT_PACKAGE, GLib.Path.build_filename(Constants.DATADIR,"locale"));

	Intl.textdomain(Constants.GETTEXT_PACKAGE);
	Intl.bind_textdomain_codeset(Constants.GETTEXT_PACKAGE, "UTF-8" );

	Gtk.init(ref argv);

	windows = new Gee.ArrayList<Terminus.TerminusWindow>();

	create_window(false);

	Gtk.main();

	return 0;
}
