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

		public static Terminus.TerminusBase main_container;

		private int pid;
		private Vte.Terminal vte_terminal;
		private Gtk.Label title;
		private Gtk.EventBox titlebox;
		private Gtk.Menu menu;
		private Gtk.MenuItem item_copy;
		private Terminus.Container top_container;

		public signal void ended(Terminus.Terminal terminal);
		public signal void new_tab(Terminus.Terminal terminal);
		public signal void split_horizontal(Terminus.Terminal terminal);
		public signal void split_vertical(Terminus.Terminal terminal);


		public Terminal(Terminus.Container top_container, string command = "/bin/bash") {

			this.top_container = top_container;
			this.orientation = Gtk.Orientation.VERTICAL;

			this.title = new Gtk.Label("");
			this.titlebox = new Gtk.EventBox();
			this.titlebox.add(this.title);

			var newbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
			this.pack_start(this.titlebox,false,true);
			this.pack_start(newbox,true,true);

			this.vte_terminal = new Vte.Terminal();
			this.vte_terminal.window_title_changed.connect( () => {
				this.update_title();
			});
			this.vte_terminal.focus_in_event.connect( () => {
				this.update_title();
				return false;
			});
			this.vte_terminal.focus_out_event.connect( () => {
				this.update_title();
				return false;
			});
			this.vte_terminal.resize_window.connect( (x,y) => {
				this.update_title();
			});

			newbox.pack_start(this.vte_terminal, true, true);

			var scroll = new Gtk.Scrollbar(Gtk.Orientation.VERTICAL,this.vte_terminal.vadjustment);
			newbox.pack_start(scroll, false, true);

			string[] cmd = {};
			cmd += command;
			this.vte_terminal.spawn_sync(Vte.PtyFlags.DEFAULT,null,cmd,GLib.Environ.get(),0,null,out this.pid);
			this.vte_terminal.child_exited.connect( () => {
				this.ended(this);
			});

			this.menu = new Gtk.Menu();
			this.item_copy = new Gtk.MenuItem.with_label(_("Copy"));
			this.item_copy.activate.connect( () => {
				this.vte_terminal.copy_primary();
			});
			this.menu.add(this.item_copy);

			var item = new Gtk.MenuItem.with_label(_("Paste"));
			item.activate.connect( () => {
				this.vte_terminal.paste_primary();
			});
			this.menu.add(item);

			this.menu.add(new Gtk.SeparatorMenuItem());

			item = new Gtk.MenuItem();
			var tmpbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			var tmplabel = new Gtk.Label(_("Split horizontally"));
			var tmpicon = new Gtk.Image.from_resource ("/com/rastersoft/terminus/pixmaps/horizontal.svg");
			tmpbox.pack_start(tmpicon,false,true);
			tmpbox.pack_start(tmplabel,false,true);
			item.add(tmpbox);
			item.activate.connect( () => {
				this.split_horizontal(this);
			});
			this.menu.add(item);

			item = new Gtk.MenuItem();
			tmpbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
			tmplabel = new Gtk.Label(_("Split vertically"));
			tmpicon = new Gtk.Image.from_resource ("/com/rastersoft/terminus/pixmaps/vertical.svg");
			tmpbox.pack_start(tmpicon,false,true);
			tmpbox.pack_start(tmplabel,false,true);
			item.add(tmpbox);
			item.activate.connect( () => {
				this.split_vertical(this);
			});
			this.menu.add(item);

			item = new Gtk.MenuItem.with_label(_("New tab"));
			item.activate.connect( () => {
				Terminus.Terminal.main_container.new_terminal_tab();
			});
			this.menu.add(item);

			this.menu.add(new Gtk.SeparatorMenuItem());

			item = new Gtk.MenuItem.with_label(_("Preferences"));
			this.menu.add(item);

			this.menu.add(new Gtk.SeparatorMenuItem());

			item = new Gtk.MenuItem.with_label(_("Close"));
			item.activate.connect( () => {
				Posix.kill(this.pid,9);
			});
			this.menu.add(item);
			this.menu.show_all();

			this.vte_terminal.button_press_event.connect(this.button_event);
			this.vte_terminal.events = Gdk.EventMask.BUTTON_PRESS_MASK;
			this.update_title();
		}

		private void update_title() {

			string title = this.vte_terminal.get_window_title();
			if (title == null) {
				title = this.vte_terminal.get_current_file_uri();
			}
			if (title == null) {
				title = this.vte_terminal.get_current_directory_uri();
			}
			if (title == null) {
				title = "/bin/bash";
			}
			this.top_container.set_tab_title(title);
			var bgcolor = Gdk.RGBA();
			string fg;
			string bg;
			if (this.vte_terminal.has_focus) {
				bgcolor.red = 1.0;
				bgcolor.green = 0.0;
				bgcolor.blue = 0.0;
				bgcolor.alpha = 1.0;
				fg = "#FFFFFF";
				bg = "#FF0000";
			} else {
				bgcolor.red = 0.6666666;
				bgcolor.green = 0.6666666;
				bgcolor.blue = 0.6666666;
				bgcolor.alpha = 1.0;
				fg = "#000000";
				bg = "#AAAAAA";
			}
			this.title.label = "<span foreground=\"%s\" background=\"%s\" size=\"small\">%s %ldx%ld</span>".printf(fg,bg,title,this.vte_terminal.get_column_count(),this.vte_terminal.get_row_count());
			this.titlebox.override_background_color(Gtk.StateFlags.NORMAL,bgcolor);
			this.title.use_markup = true;
		}

		public bool button_event(Gdk.EventButton event) {

			if (event.button == 3) {
				this.item_copy.sensitive = this.vte_terminal.get_has_selection();
				this.menu.popup(null,null,null,3,Gtk.get_current_event_time());
				return true;
			}

			return false;
		}

	}

}
