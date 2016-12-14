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

//project version = 0.5.0

namespace Terminus {

	TerminusRoot main_root;
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

			main_root = this;
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

			Terminus.keybind_settings.changed.connect(this.keybind_settings_changed);

			if (launch_terminal || launch_guake) {
				Bus.own_name (BusType.SESSION, "com.rastersoft.terminus", BusNameOwnerFlags.NONE, this.on_bus_aquired, () => {}, () => {});
				Gtk.main();
			}
		}

		void on_bus_aquired (DBusConnection conn) {
			try {
				conn.register_object ("/com/rastersoft/terminus", new RemoteControl ());
			} catch (IOError e) {
				GLib.stderr.printf ("Could not register service\n");
			}
		}

		public void keybind_settings_changed(string key) {

			if (key != "guake-mode") {
				return;
			}
			Terminus.bindkey.show_guake.disconnect(this.show_hide);
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
					Terminus.bindkey.show_guake.disconnect(this.show_hide);
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
			this.show_hide_global(2);
		}

		public void show_hide_global(int mode) {
			/*mode = 0: force show
			 *mode = 1: force hide
			 *mode = 2: hide if visible, show if hidden
			 */

			if (Terminus.settings.get_boolean("enable-guake-mode") == false) {
				return;
			}

			if (this.guake_window == null) {
				this.create_window(true);
			}

			if (this.guake_window.visible) {
				if ((mode == 1) || (mode == 2)) {
					this.guake_window.hide();
				}
			} else {
				if ((mode == 0) || (mode == 2)) {
					this.guake_window.present();
				}
			}
		}
	}


	bool check_params(string[] argv) {

		int param_counter = 0;

		if (check_wayland() == 1) {
			return false; // under Wayland we can't use bindkeys
		}
		
		while(param_counter < argv.length) {
			param_counter++;
			if (argv[param_counter] == "--nobindkey") {
				return false;
			}
		}
		return true;
	}
	
	[DBus (name = "com.rastersoft.terminus")]
	public class RemoteControl : GLib.Object {

		public int do_ping(int v) {
			return (v+1);
		}

		public void show_guake() {
			main_root.show_hide_global(0);
		}

		public void hide_guake() {
			main_root.show_hide_global(1);
		}

		public void swap_guake() {
			main_root.show_hide_global(2);
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
	Terminus.bindkey = new Terminus.Bindkey(Terminus.check_params(argv));

	new Terminus.TerminusRoot(argv);

	return 0;
}
