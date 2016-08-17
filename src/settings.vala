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

	struct ColorScheme {

		string name;
		uint8 fg_red;
		uint8 fg_green;
		uint8 fg_blue;
		uint8 bg_red;
		uint8 bg_green;
		uint8 bg_blue;

		public ColorScheme(string name, uint8 fg_red, uint8 fg_green, uint8 fg_blue, uint8 bg_red, uint8 bg_green, uint8 bg_blue) {
			this.name = name;
			this.fg_red = fg_red;
			this.fg_green = fg_green;
			this.fg_blue = fg_blue;
			this.bg_red = bg_red;
			this.bg_green = bg_green;
			this.bg_blue = bg_blue;
		}

	}

	class Properties : Gtk.Window {

		private GLib.Settings settings;
		private Gtk.CheckButton use_system_font;
		private Gtk.CheckButton infinite_scroll;
		private Gtk.SpinButton scroll_value;
		private Gtk.Button custom_font;
		private Gtk.ColorButton fg_color;
		private Gtk.ColorButton bg_color;
		private Gtk.ComboBox color_scheme;
		private ColorScheme[] schemes;

		public Properties(GLib.Settings settings) {

			this.settings = settings;

			this.schemes = {
				ColorScheme(_("Custom"),0x00,0x00,0x00,0x00,0x00,0x00),
				ColorScheme(_("Black on light yellow"),0x00,0x00,0x00,0xFF,0xFF,0xDD),
				ColorScheme(_("Black on white"),0x00,0x00,0x00,0xFF,0xFF,0xFF),
				ColorScheme(_("Gray on black"),0xC0,0xC0,0xC0,0x00,0x00,0x00),
				ColorScheme(_("Green on black"),0x00,0xFF,0x00,0x00,0x00,0x00),
				ColorScheme(_("White on black"),0xFF,0xFF,0xFF,0x00,0x00,0x00),
				ColorScheme(_("Orange on black"),0xFF,0xDD,0x00,0x00,0x00,0x00)
			};

			var main_window = new Gtk.Builder();
			string[] elements = {"properties_notebook", "list_schemes", "list_keybindings", "scroll_lines", "transparency_level"};
			main_window.add_objects_from_resource("/com/rastersoft/terminus/interface/properties.ui",elements);
			this.add(main_window.get_object("properties_notebook") as Gtk.Widget);

			this.use_system_font = main_window.get_object("use_system_font") as Gtk.CheckButton;
			this.custom_font =  main_window.get_object("custom_font") as Gtk.Button;
			use_system_font.toggled.connect( () => {
				this.custom_font.sensitive = !this.use_system_font.active;
			});

			this.fg_color = main_window.get_object("text_color") as Gtk.ColorButton;
			this.fg_color.color_set.connect( () => {
				var color = (this.fg_color as Gtk.ColorChooser).rgba;
				var htmlcolor = "#%02X%02X%02X".printf((uint)(255*color.red),(uint)(255*color.green),(uint)(255*color.blue));
				this.settings.set_string("fg-color",htmlcolor);
			});
			this.bg_color = main_window.get_object("bg_color") as Gtk.ColorButton;
			this.bg_color.color_set.connect( () => {
				var color = (this.bg_color as Gtk.ColorChooser).rgba;
				var htmlcolor = "#%02X%02X%02X".printf((uint)(255*color.red),(uint)(255*color.green),(uint)(255*color.blue));
				this.settings.set_string("bg-color",htmlcolor);
			});

			this.color_scheme = main_window.get_object("color_scheme") as Gtk.ComboBox;
			this.color_scheme.changed.connect( () => {
				var selected = this.color_scheme.get_active();
				if (selected == 0) { // Custom
					this.fg_color.sensitive = true;
					this.bg_color.sensitive = true;
					var color = (this.fg_color as Gtk.ColorChooser).rgba;
					var htmlcolor = "#%02X%02X%02X".printf((uint)(255*color.red),(uint)(255*color.green),(uint)(255*color.blue));
					this.settings.set_string("fg-color",htmlcolor);
					color = (this.bg_color as Gtk.ColorChooser).rgba;
					htmlcolor = "#%02X%02X%02X".printf((uint)(255*color.red),(uint)(255*color.green),(uint)(255*color.blue));
					this.settings.set_string("bg-color",htmlcolor);
				} else {
					this.fg_color.sensitive = false;
					this.bg_color.sensitive = false;
					var fg_htmlcolor = "#%02X%02X%02X".printf(this.schemes[selected].fg_red,this.schemes[selected].fg_green,this.schemes[selected].fg_blue);
					var bg_htmlcolor = "#%02X%02X%02X".printf(this.schemes[selected].bg_red,this.schemes[selected].bg_green,this.schemes[selected].bg_blue);
					this.settings.set_string("fg-color",fg_htmlcolor);
					this.settings.set_string("bg-color",bg_htmlcolor);
				}
			});

			var scroll_lines = main_window.get_object("scroll_lines") as Gtk.Adjustment;
			this.infinite_scroll = main_window.get_object("infinite_scroll") as Gtk.CheckButton;
			this.scroll_value = main_window.get_object("scroll_spinbutton") as Gtk.SpinButton;
			this.infinite_scroll.toggled.connect( () => {
				this.scroll_value.sensitive = !this.infinite_scroll.active;
			});

			this.settings.bind("color-scheme",this.color_scheme,"active",GLib.SettingsBindFlags.DEFAULT);
			this.settings.bind("use-system-font",this.use_system_font,"active",GLib.SettingsBindFlags.DEFAULT);
			this.settings.bind("terminal-font",this.custom_font,"font_name",GLib.SettingsBindFlags.DEFAULT);
			this.settings.bind("scroll-lines",scroll_lines,"value",GLib.SettingsBindFlags.DEFAULT);
			this.settings.bind("infinite-scroll",this.infinite_scroll,"active",GLib.SettingsBindFlags.DEFAULT);
			this.settings.bind("scroll-on-output",main_window.get_object("scroll_on_output") as Gtk.CheckButton,"active",GLib.SettingsBindFlags.DEFAULT);
			this.settings.bind("scroll-on-keystroke",main_window.get_object("scroll_on_keystroke") as Gtk.CheckButton,"active",GLib.SettingsBindFlags.DEFAULT);

			var list_schemes = main_window.get_object("list_schemes") as Gtk.ListStore;
			int counter = 0;
			foreach(var scheme in this.schemes) {
				Gtk.TreeIter iter;
				list_schemes.append(out iter);
				var name = GLib.Value(typeof(string));
				name.set_string(scheme.name);
				list_schemes.set_value(iter,0,name);
				var id = GLib.Value(typeof(int));
				id.set_int(counter);
				list_schemes.set_value(iter,1,id);
				counter++;
			}

			this.update_interface();

		}

		private void update_interface() {

			this.custom_font.sensitive = !this.use_system_font.active;
			this.scroll_value.sensitive = !this.infinite_scroll.active;
			var fg_color = Gdk.RGBA();
			var bg_color = Gdk.RGBA();
			fg_color.parse(this.settings.get_string("fg-color"));
			bg_color.parse(this.settings.get_string("bg-color"));
			this.fg_color.set_rgba(fg_color);
			this.bg_color.set_rgba(bg_color);
			this.color_scheme.set_active(this.settings.get_int("color-scheme"));
		}

	}
}
