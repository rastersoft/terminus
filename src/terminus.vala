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


namespace Terminus {

	GLib.Settings settings = null;
	GLib.Settings keybind_settings = null;
	Gee.List<Terminus.Window> window_list;
	bool launch_guake = false;
	bool check_guake = false;
	Terminus.Bindkey bindkey;

	void create_window(bool guake_mode) {

		var window = new Terminus.Window(guake_mode);
		window.ended.connect( (w) => {
			window_list.remove(w);
			if (window_list.size == 0) {
				Gtk.main_quit();
			}
		});
		window.new_window.connect( () => {
			Terminus.create_window(false);
		});
		window_list.add(window);
	}

	void check_params(string[] argv) {

		int param_counter = 0;

		while(param_counter < argv.length) {
			param_counter++;
			if (argv[param_counter] == "--guake") {
				launch_guake = true;
				continue;
			}
			if (argv[param_counter] == "--check_guake") {
				check_guake = true;
				continue;
			}
		}
	}
}

int main(string[] argv) {

	Intl.bindtextdomain(Constants.GETTEXT_PACKAGE, GLib.Path.build_filename(Constants.DATADIR,"locale"));

	Intl.textdomain(Constants.GETTEXT_PACKAGE);
	Intl.bind_textdomain_codeset(Constants.GETTEXT_PACKAGE, "UTF-8" );

	Gtk.init(ref argv);

	Terminus.bindkey = new Terminus.Bindkey();

	Terminus.window_list = new Gee.ArrayList<Terminus.Window>();
	Terminus.settings = new GLib.Settings("org.rastersoft.terminus");
	Terminus.keybind_settings = new GLib.Settings("org.rastersoft.terminus.keybindings");

	Terminus.check_params(argv);

	bool launch_terminal = true;

	if (Terminus.check_guake) {
		if (false == Terminus.settings.get_boolean("enable-guake-mode")) {
			launch_terminal = false;
		} else {
			Terminus.launch_guake = true;
		}
	}

	if (launch_terminal) {
		Terminus.create_window(Terminus.launch_guake);
		Gtk.main();
	}

	return 0;
}
