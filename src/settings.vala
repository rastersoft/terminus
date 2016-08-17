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
using Gdk;

namespace Terminus {

	class Properties : Gtk.Window {

		private GLib.Settings settings;
		private Gtk.CheckButton use_system_font;
		private Gtk.Button custom_font;

		public Properties(GLib.Settings settings) {

			this.settings = settings;

			var main_window = new Gtk.Builder();
			string[] elements = {};
			elements += "properties_notebook";
			elements += "liststore1";
			elements += "liststore2";
			elements += "list_keybindings";
			elements += "scroll_lines";
			elements += "transparency_level";
			main_window.add_objects_from_resource("/com/rastersoft/terminus/interface/properties.ui",elements);
			this.add(main_window.get_object("properties_notebook") as Gtk.Widget);

			this.use_system_font = main_window.get_object("use_system_font") as Gtk.CheckButton;
			this.custom_font =  main_window.get_object("custom_font") as Gtk.Button;
			use_system_font.toggled.connect( () => {
				this.update_interface();
			});

			this.settings.bind("use-system-font",use_system_font,"active",GLib.SettingsBindFlags.DEFAULT);
			this.settings.bind("terminal-font",custom_font,"font_name",GLib.SettingsBindFlags.DEFAULT);
			this.update_interface();

		}

		private void update_interface() {
			this.custom_font.sensitive = !this.use_system_font.active;
		}

	}
}
