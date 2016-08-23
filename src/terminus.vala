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
	Terminus.Bindkey bindkey;

	class TerminusRoot : Object {

		private Gee.List<Terminus.Window> window_list;
		private bool launch_guake = false;
		private bool check_guake = false;
		private Terminus.Base? guake_terminal;
		private Terminus.Window? guake_window;

		public TerminusRoot(string[] argv) {

			this.guake_terminal = null;
			this.guake_window = null;

			bool binded_key = Terminus.bindkey.set_bindkey(Terminus.keybind_settings.get_string("guake-mode"));

			this.window_list = new Gee.ArrayList<Terminus.Window>();

			this.check_params(argv);

			bool launch_terminal = true;
			bool launch_guake;

			if (binded_key) {
				launch_guake = Terminus.settings.get_boolean("enable-guake-mode");;
			} else {
				launch_guake = false;
			}

			if (this.launch_guake) {
				launch_terminal = false;
				this.check_guake = false;
				launch_guake = true;
			}

			if (this.check_guake) {
				launch_terminal = false;
				launch_guake = Terminus.settings.get_boolean("enable-guake-mode");
			}

			if (launch_terminal) {
				this.create_window(false);
			}

			if (launch_guake) {
				this.create_window(true);
			}

			if (launch_terminal || launch_guake) {
				Gtk.main();
			}

			Terminus.keybind_settings.changed.connect(this.keybind_settings_changed);
		}

		public void keybind_settings_changed(string key) {

			if (key != "guake-mode") {
				return;
			}
			Terminus.bindkey.set_bindkey(Terminus.keybind_settings.get_string("guake-mode"));
			Terminus.bindkey.show_guake.connect(this.show_hide);
		}

		public void create_window(bool guake_mode) {

			Terminus.Window window;

			if (guake_mode) {
				if (this.guake_terminal == null) {
					this.guake_terminal = new Terminus.Base();
				}
				window = new Terminus.Window(true,this.guake_terminal);
				this.guake_window = window;
				Terminus.bindkey.show_guake.connect(this.show_hide);
			} else {
				window = new Terminus.Window(false);
			}

			window.ended.connect( (w) => {
				window_list.remove(w);
				if (w == this.guake_window) {
					Terminus.bindkey.unset_bindkey();
					this.guake_window = null;
					this.guake_terminal = null;
					this.create_window(true);
				}
				if (window_list.size == 0) {
					Gtk.main_quit();
				}
			});
			window.new_window.connect( () => {
				this.create_window(false);
			});
			window_list.add(window);
		}

		public void check_params(string[] argv) {

			int param_counter = 0;

			while(param_counter < argv.length) {
				param_counter++;
				if (argv[param_counter] == "--guake") {
					this.launch_guake = true;
					continue;
				}
				if (argv[param_counter] == "--check_guake") {
					this.check_guake = true;
					continue;
				}
			}
		}

		public void show_hide() {

			if (Terminus.settings.get_boolean("enable-guake-mode") == false) {
				return;
			}

			if (this.guake_window == null) {
				this.create_window(true);
			}

			if (this.guake_window.visible) {
				this.guake_window.hide();
			} else {
				this.guake_window.present();
			}
		}
	}
}

int main(string[] argv) {

	Intl.bindtextdomain(Constants.GETTEXT_PACKAGE, GLib.Path.build_filename(Constants.DATADIR,"locale"));

	Intl.textdomain(Constants.GETTEXT_PACKAGE);
	Intl.bind_textdomain_codeset(Constants.GETTEXT_PACKAGE, "UTF-8" );

	Gtk.init(ref argv);


	Terminus.settings = new GLib.Settings("org.rastersoft.terminus");
	Terminus.keybind_settings = new GLib.Settings("org.rastersoft.terminus.keybindings");
	Terminus.bindkey = new Terminus.Bindkey();

	var tm = new Terminus.TerminusRoot(argv);

	return 0;
}
