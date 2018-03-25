/*
 * Copyright 2016 (C) Raster Software Vigo (Sergio Costas)
 *
 * This file is part of Terminus
 *
 * Terminus is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Terminus is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. */

using Gtk;
using Gdk;

namespace Terminus {
	class Properties : Gtk.Window {
		private Gtk.CheckButton use_system_font;
		private Gtk.CheckButton infinite_scroll;
		private Gtk.CheckButton enable_guake_mode;
		private Gtk.CheckButton use_bold_color;
		private Gtk.CheckButton use_cursor_color;
		private Gtk.CheckButton use_highlight_color;
		private Gtk.SpinButton scroll_value;
		private Gtk.Button custom_font;
		private Gtk.ColorButton fg_color;
		private Gtk.ColorButton bg_color;
		private Gtk.ColorButton bold_color;
		private Gtk.ColorButton cursor_color_fg;
		private Gtk.ColorButton cursor_color_bg;
		private Gtk.ColorButton highlight_color_fg;
		private Gtk.ColorButton highlight_color_bg;
		private Gtk.ColorButton[] palette_colors;
		private Gtk.ComboBox color_scheme;
		private Gtk.ListStore color_schemes;
		private Gtk.ComboBox palette_scheme;
		private Gtk.ListStore palette_schemes;
		private Gtk.ComboBox cursor_shape;
		private Gtk.ListStore cursor_liststore;
		private Gtk.ListStore keybindings;


		private bool editing_keybind;
		private bool changing_guake;
		private string old_keybind;
		private Gtk.TreePath old_keybind_path;
		private bool disable_palette_change;

		public Properties() {
			this.editing_keybind   = false;
			disable_palette_change = false;

			this.delete_event.connect((w) => {
				this.hide();
				return true;
			});

			var      main_window = new Gtk.Builder();
			string[] elements    = { "properties_notebook", "color_schemes", "palette_schemes", "scroll_lines", "transparency_level", "cursor_liststore" };
			main_window.add_objects_from_resource("/com/rastersoft/terminus/interface/properties.ui", elements);
			this.add(main_window.get_object("properties_notebook") as Gtk.Widget);

			var label_version = main_window.get_object("label_version") as Gtk.Label;
			label_version.label = _("Version %s").printf(Constants.VERSION);

			this.use_system_font = main_window.get_object("use_system_font") as Gtk.CheckButton;
			this.custom_font     = main_window.get_object("custom_font") as Gtk.Button;
			use_system_font.toggled.connect(() => {
				this.custom_font.sensitive = this.use_system_font.active;
			});

			this.fg_color            = main_window.get_object("text_color") as Gtk.ColorButton;
			this.bg_color            = main_window.get_object("bg_color") as Gtk.ColorButton;
			this.bold_color          = main_window.get_object("bold_color") as Gtk.ColorButton;
			this.use_bold_color      = main_window.get_object("use_bold_color") as Gtk.CheckButton;
			this.cursor_color_fg     = main_window.get_object("cursor_color_fg") as Gtk.ColorButton;
			this.cursor_color_bg     = main_window.get_object("cursor_color_bg") as Gtk.ColorButton;
			this.use_cursor_color    = main_window.get_object("use_cursor_color") as Gtk.CheckButton;
			this.highlight_color_fg  = main_window.get_object("highlight_color_fg") as Gtk.ColorButton;
			this.highlight_color_bg  = main_window.get_object("highlight_color_bg") as Gtk.ColorButton;
			this.use_highlight_color = main_window.get_object("use_highlight_color") as Gtk.CheckButton;
			this.color_scheme        = main_window.get_object("color_scheme") as Gtk.ComboBox;
			this.color_schemes       = main_window.get_object("color_schemes") as Gtk.ListStore;
			this.palette_scheme      = main_window.get_object("palette_scheme") as Gtk.ComboBox;
			this.palette_schemes     = main_window.get_object("palette_schemes") as Gtk.ListStore;
			this.cursor_shape        = main_window.get_object("cursor_shape") as Gtk.ComboBox;
			this.palette_colors      = {};
			string[] palette_string = Terminus.settings.get_strv("color-palete");
			var      tmpcolor       = Gdk.RGBA();
			for (int i = 0; i < 16; i++) {
				Gtk.ColorButton palette_button = main_window.get_object("palette%d".printf(i)) as Gtk.ColorButton;
				tmpcolor.parse(palette_string[i]);
				palette_button.set_rgba(tmpcolor);
				this.palette_colors += palette_button;
			}

			var    tmp_color = Gdk.RGBA();
			string key;
			tmp_color.parse(Terminus.settings.get_string("fg-color"));
			this.fg_color.set_rgba(tmp_color);
			tmp_color.parse(Terminus.settings.get_string("bg-color"));
			this.bg_color.set_rgba(tmp_color);
			key = Terminus.settings.get_string("bold-color");
			if (key != "") {
				tmp_color.parse(key);
				this.bold_color.set_rgba(tmp_color);
				this.use_bold_color.active = true;
				this.bold_color.sensitive  = true;
			} else {
				this.use_bold_color.active = false;
				this.bold_color.sensitive  = false;
			}
			key = Terminus.settings.get_string("highlight-fg-color");
			if (key != "") {
				tmp_color.parse(key);
				this.highlight_color_fg.set_rgba(tmp_color);
				tmp_color.parse(Terminus.settings.get_string("highlight-bg-color"));
				this.highlight_color_bg.set_rgba(tmp_color);
				this.use_highlight_color.active   = true;
				this.highlight_color_fg.sensitive = true;
				this.highlight_color_bg.sensitive = true;
			} else {
				this.use_highlight_color.active   = false;
				this.highlight_color_fg.sensitive = false;
				this.highlight_color_bg.sensitive = false;
			}

			key = Terminus.settings.get_string("cursor-fg-color");
			if (key != "") {
				tmp_color.parse(key);
				this.cursor_color_fg.set_rgba(tmp_color);
				tmp_color.parse(Terminus.settings.get_string("cursor-bg-color"));
				this.cursor_color_bg.set_rgba(tmp_color);
				this.use_cursor_color.active   = true;
				this.cursor_color_fg.sensitive = true;
				this.cursor_color_bg.sensitive = true;
			} else {
				this.use_cursor_color.active   = false;
				this.cursor_color_fg.sensitive = false;
				this.cursor_color_bg.sensitive = false;
			}

			this.fg_color.color_set.connect(() => {
				this.set_all_properties("fg-color");
			});
			this.bg_color.color_set.connect(() => {
				this.set_all_properties("bg-color");
			});
			this.bold_color.color_set.connect(() => {
				this.set_all_properties("bold-color");
			});
			this.use_bold_color.toggled.connect_after(() => {
				this.bold_color.sensitive = this.use_bold_color.get_active();
				this.set_all_properties("bold-color");
			});
			this.cursor_color_fg.color_set.connect(() => {
				this.set_all_properties("cursor-fg-color");
			});
			this.cursor_color_bg.color_set.connect(() => {
				this.set_all_properties("cursor-bg-color");
			});
			this.use_cursor_color.toggled.connect_after(() => {
				this.cursor_color_fg.sensitive = this.use_cursor_color.get_active();
				this.cursor_color_bg.sensitive = this.use_cursor_color.get_active();
				this.set_all_properties("cursor-fg-color");
				this.set_all_properties("cursor-bg-color");
			});
			this.highlight_color_fg.color_set.connect(() => {
				this.set_all_properties("highlight-fg-color");
			});
			this.highlight_color_bg.color_set.connect(() => {
				this.set_all_properties("highlight-bg-color");
			});
			this.use_highlight_color.toggled.connect_after(() => {
				this.highlight_color_fg.sensitive = this.use_highlight_color.get_active();
				this.highlight_color_bg.sensitive = this.use_highlight_color.get_active();
				this.set_all_properties("highlight-fg-color");
				this.set_all_properties("highlight-bg-color");
			});

			foreach (var button in this.palette_colors) {
				button.color_set.connect(() => {
					this.updated_palette();
				});
			}

			this.palette_scheme.changed.connect(() => {
				var selected = this.palette_scheme.get_active();
				if (selected < 0) {
				    return;
				}
				Gtk.TreeIter iter;
				this.palette_scheme.get_active_iter(out iter);
				GLib.Value selectedCell;
				this.palette_schemes.get_value(iter, 1, out selectedCell);
				selected = selectedCell.get_int();
				var scheme = Terminus.main_root.palettes[selected];
				if (scheme.custom) {
				    return;
				}
				int i = 0;
				this.disable_palette_change = true;
				foreach (var color in scheme.palette) {
				    this.palette_colors[i].set_rgba(color);
				    i++;
				}
				this.disable_palette_change = false;
				this.updated_palette();
			});
			this.color_scheme.changed.connect(() => {
				var selected = this.color_scheme.get_active();
				if (selected < 0) {
				    return;
				}
				Gtk.TreeIter iter;
				this.color_scheme.get_active_iter(out iter);
				GLib.Value selectedCell;
				this.color_schemes.get_value(iter, 1, out selectedCell);
				selected = selectedCell.get_int();
				var scheme = Terminus.main_root.palettes[selected];
				if (scheme.custom) {
				    return;
				}
				this.fg_color.rgba = scheme.text_fg;
				this.bg_color.rgba = scheme.text_bg;
				this.set_all_properties("fg-color");
				this.set_all_properties("bg-color");
			});

			var scroll_lines = main_window.get_object("scroll_lines") as Gtk.Adjustment;
			this.infinite_scroll = main_window.get_object("infinite_scroll") as Gtk.CheckButton;
			this.scroll_value    = main_window.get_object("scroll_spinbutton") as Gtk.SpinButton;
			this.infinite_scroll.toggled.connect(() => {
				this.scroll_value.sensitive = !this.infinite_scroll.active;
			});

			this.enable_guake_mode = main_window.get_object("enable_guake_mode") as Gtk.CheckButton;

			Terminus.settings.bind("cursor-shape", this.cursor_shape, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("use-system-font", this.use_system_font, "active", GLib.SettingsBindFlags.DEFAULT | GLib.SettingsBindFlags.INVERT_BOOLEAN);
			Terminus.settings.bind("terminal-font", this.custom_font, "font_name", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("scroll-lines", scroll_lines, "value", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("infinite-scroll", this.infinite_scroll, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("scroll-on-output", main_window.get_object("scroll_on_output") as Gtk.CheckButton, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("scroll-on-keystroke", main_window.get_object("scroll_on_keystroke") as Gtk.CheckButton, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("enable-guake-mode", this.enable_guake_mode, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("terminal-bell", main_window.get_object("terminal_bell") as Gtk.CheckButton, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("rewrap-on-resize", main_window.get_object("rewrap_on_resize") as Gtk.CheckButton, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("allow-bold", main_window.get_object("allow_bold") as Gtk.CheckButton, "active", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("shell-command", main_window.get_object("command_shell") as Gtk.Entry, "text", GLib.SettingsBindFlags.DEFAULT);

			int counter  = -1;
			int selected = 0;
			int selcount = 0;
			foreach (var scheme in Terminus.main_root.palettes) {
				counter++;
				if ((!scheme.custom) && (scheme.text_fg == null)) {
					continue;
				}
				Gtk.TreeIter iter;
				this.color_schemes.append(out iter);
				var name = GLib.Value(typeof(string));
				name.set_string(scheme.name);
				this.color_schemes.set_value(iter, 0, name);
				var id = GLib.Value(typeof(int));
				id.set_int(counter);
				this.color_schemes.set_value(iter, 1, id);
				if (scheme.compare_scheme()) {
					selected = selcount;
				}
				selcount++;
			}

			this.custom_font.sensitive  = this.use_system_font.active;
			this.scroll_value.sensitive = !this.infinite_scroll.active;

			this.color_scheme.set_active(selected);

			counter  = -1;
			selected = 0;
			selcount = 0;
			foreach (var scheme in Terminus.main_root.palettes) {
				counter++;
				if ((!scheme.custom) && (scheme.palette.length == 0)) {
					continue;
				}
				Gtk.TreeIter iter;
				this.palette_schemes.append(out iter);
				var name = GLib.Value(typeof(string));
				name.set_string(scheme.name);
				this.palette_schemes.set_value(iter, 0, name);
				var id = GLib.Value(typeof(int));
				id.set_int(counter);
				this.palette_schemes.set_value(iter, 1, id);
				if (scheme.compare_palette()) {
					selected = selcount;
				}
				selcount++;
			}
			this.palette_scheme.set_active(selected);

			this.keybindings = new Gtk.ListStore(3, typeof(string), typeof(string), typeof(string));
			this.add_keybinding(_("New window"), "new-window");
			this.add_keybinding(_("New tab"), "new-tab");
			this.add_keybinding(_("Next tab"), "next-tab");
			this.add_keybinding(_("Previous tab"), "previous-tab");
			this.add_keybinding(_("Show guake terminal"), "guake-mode");

			var keybindings_view = main_window.get_object("keybindings") as Gtk.TreeView;
			keybindings_view.activate_on_single_click = true;
			keybindings_view.row_activated.connect(this.keybind_clicked_cb);
			keybindings_view.set_model(this.keybindings);
			Gtk.CellRendererText cell = new Gtk.CellRendererText();
			keybindings_view.insert_column_with_attributes(-1, _("Action"), cell, "text", 0);
			keybindings_view.insert_column_with_attributes(-1, _("Key"), cell, "text", 1);

			this.events = Gdk.EventMask.KEY_PRESS_MASK;
			this.key_press_event.connect(this.on_key_press);
		}

		public void set_all_properties(string ? key) {
			bool changed_text_colors = false;
			bool changed             = false;

			if (key == "fg-color") {
				changed_text_colors = true;
				var color     = (this.fg_color as Gtk.ColorChooser).rgba;
				var htmlcolor = "#%02X%02X%02X".printf((uint) (255 * color.red), (uint) (255 * color.green), (uint) (255 * color.blue));
				if (Terminus.settings.get_string("fg-color") != htmlcolor) {
					Terminus.settings.set_string("fg-color", htmlcolor);
					changed = true;
				}
			}

			if (key == "bg-color") {
				changed_text_colors = true;
				var color     = (this.bg_color as Gtk.ColorChooser).rgba;
				var htmlcolor = "#%02X%02X%02X".printf((uint) (255 * color.red), (uint) (255 * color.green), (uint) (255 * color.blue));
				if (Terminus.settings.get_string("bg-color") != htmlcolor) {
					Terminus.settings.set_string("bg-color", htmlcolor);
					changed = true;
				}
			}
			if (key == "bold-color") {
				string htmlcolor;
				if (this.use_bold_color.active) {
					var color = (this.bold_color as Gtk.ColorChooser).rgba;
					htmlcolor = "#%02X%02X%02X".printf((uint) (255 * color.red), (uint) (255 * color.green), (uint) (255 * color.blue));
				} else {
					htmlcolor = "";
				}
				if (Terminus.settings.get_string("bold-color") != htmlcolor) {
					Terminus.settings.set_string("bold-color", htmlcolor);
				}
			}
			if ((key == "cursor-fg-color") || changed_text_colors) {
				string htmlcolor;
				if (this.use_cursor_color.active) {
					var color = (this.cursor_color_fg as Gtk.ColorChooser).rgba;
					htmlcolor = "#%02X%02X%02X".printf((uint) (255 * color.red), (uint) (255 * color.green), (uint) (255 * color.blue));
				} else {
					htmlcolor = "";
				}
				if ((Terminus.settings.get_string("cursor-fg-color") != htmlcolor) || changed_text_colors) {
					Terminus.settings.set_string("cursor-fg-color", htmlcolor);
				}
			}
			if ((key == "cursor-bg-color") || changed_text_colors) {
				string htmlcolor;
				if (this.use_cursor_color.active) {
					var color = (this.cursor_color_bg as Gtk.ColorChooser).rgba;
					htmlcolor = "#%02X%02X%02X".printf((uint) (255 * color.red), (uint) (255 * color.green), (uint) (255 * color.blue));
				} else {
					htmlcolor = "";
				}
				if ((Terminus.settings.get_string("cursor-bg-color") != htmlcolor) || changed_text_colors) {
					Terminus.settings.set_string("cursor-bg-color", htmlcolor);
				}
			}
			if (key == "highlight-fg-color") {
				string htmlcolor;
				if (this.use_highlight_color.active) {
					var color = (this.highlight_color_fg as Gtk.ColorChooser).rgba;
					htmlcolor = "#%02X%02X%02X".printf((uint) (255 * color.red), (uint) (255 * color.green), (uint) (255 * color.blue));
				} else {
					htmlcolor = "";
				}
				if (Terminus.settings.get_string("highlight-fg-color") != htmlcolor) {
					Terminus.settings.set_string("highlight-fg-color", htmlcolor);
				}
			}
			if (key == "highlight-bg-color") {
				string htmlcolor;
				if (this.use_highlight_color.active) {
					var color = (this.highlight_color_bg as Gtk.ColorChooser).rgba;
					htmlcolor = "#%02X%02X%02X".printf((uint) (255 * color.red), (uint) (255 * color.green), (uint) (255 * color.blue));
				} else {
					htmlcolor = "";
				}
				if (Terminus.settings.get_string("highlight-bg-color") != htmlcolor) {
					Terminus.settings.set_string("highlight-bg-color", htmlcolor);
				}
			}
			if (changed) {
				this.color_scheme.set_active(this.get_current_scheme());
			}
		}

		private void updated_palette() {
			if (this.disable_palette_change) {
				return;
			}

			string[] old_palette = Terminus.settings.get_strv("color-palete");
			string[] new_palette = {};
			bool     changed     = false;
			int      i           = 0;
			foreach (var button in this.palette_colors) {
				var color     = button.rgba;
				var color_str = "#%02X%02X%02X".printf((int) (color.red * 255), (int) (color.green * 255), (int) (color.blue * 255));
				new_palette += color_str;
				if (old_palette[i] != color_str) {
					changed = true;
				}
				i++;
			}
			if (changed) {
				Terminus.settings.set_strv("color-palete", new_palette);
				this.palette_scheme.set_active(this.get_current_palette());
			}
		}

		private int get_current_palette() {
			int counter  = 0;
			int selected = 0;
			foreach (var scheme in Terminus.main_root.palettes) {
				if ((!scheme.custom) && (scheme.palette.length == 0)) {
					continue;
				}
				if (scheme.compare_palette()) {
					selected = counter;
					break;
				}
				counter++;
			}
			return selected;
		}

		private int get_current_scheme() {
			int counter  = 0;
			int selected = 0;
			foreach (var scheme in Terminus.main_root.palettes) {
				if ((!scheme.custom) && (scheme.text_fg == null)) {
					continue;
				}
				if (scheme.compare_scheme()) {
					selected = counter;
					break;
				}
				counter++;
			}
			return selected;
		}

		private void add_keybinding(string name, string setting) {
			Gtk.TreeIter iter;
			this.keybindings.append(out iter);
			this.keybindings.set(iter, 0, name, 1, Terminus.keybind_settings.get_string(setting), 2, setting);
		}

		public void keybind_clicked_cb(TreePath path, TreeViewColumn column) {
			Gtk.TreeIter iter;
			GLib.Value   val;

			if (this.editing_keybind) {
				this.editing_keybind = false;
				this.keybindings.get_iter(out iter, this.old_keybind_path);
				this.keybindings.set(iter, 1, this.old_keybind);
				if (this.changing_guake) {
					Terminus.keybind_settings.set_string("guake-mode", old_keybind);
				}
			} else {
				this.editing_keybind = true;
				this.keybindings.get_iter(out iter, path);
				this.keybindings.get_value(iter, 1, out val);
				this.old_keybind      = val.get_string();
				this.old_keybind_path = path;
				this.keybindings.set(iter, 1, "...");
				this.keybindings.get_value(iter, 2, out val);
				if ("guake-mode" == val.get_string()) {
					Terminus.bindkey.unset_bindkey();
					this.changing_guake = true;
				} else {
					this.changing_guake = false;
				}
			}
		}

		public bool on_key_press(Gdk.EventKey eventkey) {
			if (this.editing_keybind == false) {
				return false;
			}

			switch (eventkey.keyval) {
			case Gdk.Key.Shift_L:
			case Gdk.Key.Shift_R:
			case Gdk.Key.Control_L:
			case Gdk.Key.Control_R:
			case Gdk.Key.Caps_Lock:
			case Gdk.Key.Shift_Lock:
			case Gdk.Key.Meta_L:
			case Gdk.Key.Meta_R:
			case Gdk.Key.Alt_L:
			case Gdk.Key.Alt_R:
			case Gdk.Key.Super_L:
			case Gdk.Key.Super_R:
			case Gdk.Key.ISO_Level3_Shift:
				return false;

			default:
				break;
			}

			this.editing_keybind = false;

			eventkey.state &= 0x07;

			if (eventkey.keyval < 128) {
				eventkey.keyval &= ~32;
			}

			var new_keybind = Gtk.accelerator_name(eventkey.keyval, eventkey.state);

			Gtk.TreeIter iter;
			Value        val;

			this.editing_keybind = false;
			this.keybindings.get_iter(out iter, this.old_keybind_path);
			this.keybindings.set(iter, 1, new_keybind);
			this.keybindings.get_value(iter, 2, out val);
			var key = val.get_string();
			Terminus.keybind_settings.set_string(key, new_keybind);

			return false;
		}
	}
}
