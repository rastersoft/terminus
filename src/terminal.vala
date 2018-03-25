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

using Vte;
using Gtk;
using Gdk;
using GLib;
using Posix;

namespace Terminus {
	/**
	 * This is the terminal itself, available in each container.
	 */

	class Terminal : Gtk.Box {
		private int pid;
		private Vte.Terminal vte_terminal;
		private Gtk.Label title;
		private Gtk.EventBox titlebox;
		private Gtk.Menu menu;
		private Gtk.MenuItem item_copy;
		private Terminus.Container top_container;
		private Terminus.Base main_container;
		private Gtk.Scrollbar right_scroll;

		private Gdk.EventKey new_tab_key;
		private Gdk.EventKey new_window_key;
		private Gdk.EventKey next_tab_key;
		private Gdk.EventKey previous_tab_key;
		private bool had_focus;

		public signal void ended(Terminus.Terminal terminal);
		public signal void split_horizontal(Terminus.Terminal terminal);
		public signal void split_vertical(Terminus.Terminal terminal);


		private void add_separator() {
			var separator = new Gtk.SeparatorMenuItem();
			separator.margin_top    = 5;
			separator.margin_bottom = 5;
			this.menu.add(separator);
		}

		public void do_grab_focus() {
			this.vte_terminal.grab_focus();
		}

		public Terminal(Terminus.Base main_container, Terminus.Container top_container) {
			// when creating a new terminal, it must take the focus
			had_focus = true;
			this.map.connect_after(() => {
				// this ensures that the title is updated when the window is shown
				GLib.Timeout.add(500, update_title_cb);
			});

			this.main_container = main_container;
			this.top_container  = top_container;
			this.orientation    = Gtk.Orientation.VERTICAL;

			this.title    = new Gtk.Label("");
			this.titlebox = new Gtk.EventBox();
			this.titlebox.add(this.title);

			var newbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			this.pack_start(this.titlebox, false, true);
			this.pack_start(newbox, true, true);

			this.vte_terminal = new Vte.Terminal();

			// by default, UTF-8
			this.vte_terminal.set_encoding(null);

			this.vte_terminal.window_title_changed.connect_after(() => {
				this.update_title();
			});
			this.vte_terminal.focus_in_event.connect_after((event) => {
				this.update_title();
				this.had_focus = true;
				return false;
			});
			this.vte_terminal.focus_out_event.connect_after((event) => {
				this.update_title();
				this.had_focus = false;
				return false;
			});
			this.vte_terminal.resize_window.connect_after((x, y) => {
				this.update_title();
			});
			this.vte_terminal.map.connect_after((w) => {
				if (this.had_focus) {
				    GLib.Timeout.add(500, () => {
						this.vte_terminal.grab_focus();
						return false;
					});
				}
			});

			Terminus.settings.bind("scroll-on-output", this.vte_terminal, "scroll_on_output", GLib.SettingsBindFlags.DEFAULT);
			Terminus.settings.bind("scroll-on-keystroke", this.vte_terminal, "scroll_on_keystroke", GLib.SettingsBindFlags.DEFAULT);

			this.right_scroll = new Gtk.Scrollbar(Gtk.Orientation.VERTICAL, this.vte_terminal.vadjustment);

			newbox.pack_start(this.vte_terminal, true, true);
			newbox.pack_start(right_scroll, false, true);

			string[] cmd = {};
			cmd += Terminus.settings.get_string("shell-command");
			this.vte_terminal.spawn_sync(Vte.PtyFlags.DEFAULT, null, cmd, GLib.Environ.get(), 0, null, out this.pid);
			this.vte_terminal.child_exited.connect(() => {
				this.ended(this);
			});

			this.menu      = new Gtk.Menu();
			this.item_copy = new Gtk.MenuItem.with_label(_("Copy"));
			this.item_copy.activate.connect(() => {
				this.vte_terminal.copy_primary();
				var primary   = Gtk.Clipboard.get(Gdk.SELECTION_PRIMARY);
				var clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
				clipboard.set_text(primary.wait_for_text(), -1);
			});
			this.menu.add(this.item_copy);

			var item = new Gtk.MenuItem.with_label(_("Paste"));
			item.activate.connect(() => {
				this.vte_terminal.paste_primary();
			});
			this.menu.add(item);

			this.add_separator();

			item = new Gtk.MenuItem();
			var tmpbox   = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			var tmplabel = new Gtk.Label(_("Split horizontally"));
			var tmpicon  = new Gtk.Image.from_resource("/com/rastersoft/terminus/pixmaps/horizontal.svg");
			tmpbox.pack_start(tmpicon, false, true);
			tmpbox.pack_start(tmplabel, false, true);
			item.add(tmpbox);
			item.activate.connect(() => {
				this.split_horizontal(this);
			});
			this.menu.add(item);

			item     = new Gtk.MenuItem();
			tmpbox   = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			tmplabel = new Gtk.Label(_("Split vertically"));
			tmpicon  = new Gtk.Image.from_resource("/com/rastersoft/terminus/pixmaps/vertical.svg");
			tmpbox.pack_start(tmpicon, false, true);
			tmpbox.pack_start(tmplabel, false, true);
			item.add(tmpbox);
			item.activate.connect(() => {
				this.split_vertical(this);
			});
			this.menu.add(item);

			item = new Gtk.MenuItem.with_label(_("New tab"));
			item.activate.connect(() => {
				this.main_container.new_terminal_tab();
			});
			this.menu.add(item);

			item = new Gtk.MenuItem.with_label(_("New window"));
			item.activate.connect(() => {
				this.main_container.new_terminal_window();
			});
			this.menu.add(item);

			this.add_separator();

			item = new Gtk.MenuItem.with_label(_("Preferences"));
			item.activate.connect(() => {
				Terminus.main_root.window_properties.show_all();
				Terminus.main_root.window_properties.present();
			});
			this.menu.add(item);

			this.add_separator();

			item = new Gtk.MenuItem.with_label(_("Close"));
			item.activate.connect(() => {
				Posix.kill(this.pid, 9);
			});
			this.menu.add(item);
			this.menu.show_all();

			this.show_all();

			this.vte_terminal.button_press_event.connect(this.button_event);
			this.vte_terminal.events = Gdk.EventMask.BUTTON_PRESS_MASK;

			this.new_tab_key      = new Gdk.Event(Gdk.EventType.KEY_RELEASE).key;
			this.new_window_key   = new Gdk.Event(Gdk.EventType.KEY_RELEASE).key;
			this.next_tab_key     = new Gdk.Event(Gdk.EventType.KEY_RELEASE).key;
			this.previous_tab_key = new Gdk.Event(Gdk.EventType.KEY_RELEASE).key;

			keybind_settings_changed("new-window");
			keybind_settings_changed("new-tab");
			keybind_settings_changed("next-tab");
			keybind_settings_changed("previous-tab");

			Terminus.settings.changed.connect(this.settings_changed);
			Terminus.keybind_settings.changed.connect(this.keybind_settings_changed);

			this.vte_terminal.key_press_event.connect(this.on_key_press);
			this.update_title();

			// Set all the properties
			settings_changed("infinite-scroll");
			settings_changed("use-system-font");
			settings_changed("color-palete");
			settings_changed("fg-color");
			settings_changed("bg-color");
			settings_changed("cursor-shape");
			settings_changed("terminal-bell");
			settings_changed("allow-bold");
			settings_changed("rewrap-on-resize");
		}

		public bool update_title_cb() {
			this.update_title();
			return false;
		}

		public void keybind_settings_changed(string key) {
			uint             keyval;
			Gdk.ModifierType state;

			Gtk.accelerator_parse(Terminus.keybind_settings.get_string(key), out keyval, out state);
			if (keyval < 128) {
				keyval &= ~32;
			}

			switch (key) {
			case "new-window":
				this.new_window_key.keyval = keyval;
				this.new_window_key.state  = state;
				break;

			case "new-tab":
				this.new_tab_key.keyval = keyval;
				this.new_tab_key.state  = state;
				break;

			case "next-tab":
				this.next_tab_key.keyval = keyval;
				this.next_tab_key.state  = state;
				break;

			case "previous-tab":
				this.previous_tab_key.keyval = keyval;
				this.previous_tab_key.state  = state;
				break;

			default:
				break;
			}
		}

		public void settings_changed(string key) {
			Gdk.RGBA ? color = null;
			string color_string;
			if (key.has_suffix("-color")) {
				color_string = Terminus.settings.get_string(key);
				if (color_string != "") {
					color = Gdk.RGBA();
					if (false == color.parse(color_string)) {
						color = null;
					}
				}
			} else {
				color_string = "";
			}

			switch (key) {
			case "infinite-scroll":
			case "scroll-lines":
				var lines    = Terminus.settings.get_uint("scroll-lines");
				var infinite = Terminus.settings.get_boolean("infinite-scroll");
				if (infinite) {
					lines = -1;
				}
				this.vte_terminal.scrollback_lines = lines;
				break;

			case "cursor-shape":
				var v = Terminus.settings.get_int("cursor-shape");
				if (v == 0) {
					this.vte_terminal.cursor_shape = Vte.CursorShape.BLOCK;
				} else if (v == 1) {
					this.vte_terminal.cursor_shape = Vte.CursorShape.IBEAM;
				} else if (v == 2) {
					this.vte_terminal.cursor_shape = Vte.CursorShape.UNDERLINE;
				}
				break;

			case "terminal-bell":
				this.vte_terminal.audible_bell = Terminus.settings.get_boolean(key);
				break;

			case "rewrap-on-resize":
				this.vte_terminal.rewrap_on_resize = Terminus.settings.get_boolean(key);
				break;

			case "allow-bold":
				this.vte_terminal.allow_bold = Terminus.settings.get_boolean(key);
				break;

			case "fg-color":
				this.vte_terminal.set_color_foreground(color);
				break;

			case "bg-color":
				this.vte_terminal.set_color_background(color);
				break;

			case "bold-color":
				this.vte_terminal.set_color_bold(color);
				break;

			case "cursor-fg-color":
				this.vte_terminal.set_color_cursor_foreground(color);
				break;

			case "cursor-bg-color":
				this.vte_terminal.set_color_cursor(color);
				break;

			case "highlight-fg-color":
				this.vte_terminal.set_color_highlight_foreground(color);
				break;

			case "highlight-bg-color":
				this.vte_terminal.set_color_highlight(color);
				break;

			case "color-palete":
				if (Terminus.check_palette()) {
					return;
				}
				string[]   palette_string = Terminus.settings.get_strv("color-palete");
				Gdk.RGBA[] palette        = {};
				foreach (var color_string2 in palette_string) {
					var tmpcolor = Gdk.RGBA();
					tmpcolor.parse(color_string2);
					palette += tmpcolor;
				}
				var fgcolor = Gdk.RGBA();
				fgcolor.parse(Terminus.settings.get_string("fg-color"));
				var bgcolor = Gdk.RGBA();
				bgcolor.parse(Terminus.settings.get_string("bg-color"));
				this.vte_terminal.set_colors(fgcolor, bgcolor, palette);
				this.settings_changed("bold-color");
				this.settings_changed("cursor-fg-color");
				this.settings_changed("cursor-bg-color");
				this.settings_changed("highlight-fg-color");
				this.settings_changed("highlight-bg-color");
				break;

			case "use-system-font":
			case "terminal-font":
				var system_font = Terminus.settings.get_boolean("use-system-font");
				Pango.FontDescription ? font_desc;
				if (system_font) {
					font_desc = null;
				} else {
					var font = Terminus.settings.get_string("terminal-font");
					font_desc = Pango.FontDescription.from_string(font);
				}
				this.vte_terminal.set_font(font_desc);
				break;

			default :
				break;
			}
		}

		public bool on_key_press(Gdk.EventKey event) {
			Gdk.EventKey eventkey = event.key;
			// SHIFT, CTRL, LEFT ALT, ALT+GR
			eventkey.state &= Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.MOD1_MASK | Gdk.ModifierType.MOD5_MASK;

			if (eventkey.keyval < 128) {
				// to avoid problems with upper and lower case
				eventkey.keyval &= ~32;
			}

			if ((eventkey.keyval == this.new_window_key.keyval) && (eventkey.state == this.new_window_key.state)) {
				this.main_container.new_terminal_window();
				return true;
			}

			if ((eventkey.keyval == this.new_tab_key.keyval) && (eventkey.state == this.new_tab_key.state)) {
				this.main_container.new_terminal_tab();
				return true;
			}
			if ((eventkey.keyval == this.next_tab_key.keyval) && (eventkey.state == this.next_tab_key.state)) {
				this.main_container.next_tab();
				return true;
			}

			if ((eventkey.keyval == this.previous_tab_key.keyval) && (eventkey.state == this.previous_tab_key.state)) {
				this.main_container.prev_tab();
				return true;
			}

			return false;
		}

		private void update_title() {
			string s_title = this.vte_terminal.get_window_title();
			if (s_title == null) {
				s_title = this.vte_terminal.get_current_file_uri();
			}
			if (s_title == null) {
				s_title = this.vte_terminal.get_current_directory_uri();
			}
			if (s_title == null) {
				s_title = "/bin/bash";
			}
			this.top_container.set_tab_title(s_title);

			var    bgcolor = Gdk.RGBA();
			string fg;
			string bg;
			if (this.vte_terminal.has_focus) {
				bgcolor.red   = 1.0;
				bgcolor.green = 0.0;
				bgcolor.blue  = 0.0;
				bgcolor.alpha = 1.0;
				fg            = "#FFFFFF";
				bg            = "#FF0000";
			} else {
				bgcolor.red   = 0.6666666;
				bgcolor.green = 0.6666666;
				bgcolor.blue  = 0.6666666;
				bgcolor.alpha = 1.0;
				fg            = "#000000";
				bg            = "#AAAAAA";
			}
			this.title.use_markup = true;
			this.title.label      = "<span foreground=\"%s\" background=\"%s\" size=\"small\">%s %ldx%ld</span>".printf(fg, bg, s_title, this.vte_terminal.get_column_count(), this.vte_terminal.get_row_count());
			this.titlebox.override_background_color(Gtk.StateFlags.NORMAL, bgcolor);
		}

		public bool button_event(Gdk.EventButton event) {
			if (event.button == 3) {
				this.item_copy.sensitive = this.vte_terminal.get_has_selection();
#if GTK_3_20
				this.menu.popup(null, null, null, 3, Gtk.get_current_event_time());
#else
				this.menu.popup_at_pointer(event);
#endif
				return true;
			}

			return false;
		}
	}
}
