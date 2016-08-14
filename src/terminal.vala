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

namespace Terminus {

	class Terminal : Gtk.Box {

		public Vte.Terminal vte_terminal;
		public int pid;

		private Gtk.Menu menu;
		private Gtk.MenuItem item_copy;

		public signal void ended();

		public Terminal(string command = "/bin/bash") {

			this.orientation = Gtk.Orientation.HORIZONTAL;
			this.vte_terminal = new Vte.Terminal();

			this.pack_start(this.vte_terminal);

			var scroll = new Gtk.Scrollbar(Gtk.Orientation.VERTICAL,this.vte_terminal.vadjustment);
			this.pack_start(scroll);

			string[] cmd = {};
			cmd += command;
			this.vte_terminal.spawn_sync(Vte.PtyFlags.DEFAULT,null,cmd,GLib.Environ.get(),0,null,out this.pid);
			this.vte_terminal.child_exited.connect(this.child_exited);

			this.menu = new Gtk.Menu();
			this.item_copy = new Gtk.MenuItem.with_label(_("Copy"));
			this.menu.add(this.item_copy);

			var item = new Gtk.MenuItem.with_label(_("Paste"));
			this.menu.add(item);

			this.menu.add(new Gtk.SeparatorMenuItem());

			item = new Gtk.MenuItem.with_label(_("Split horizontally"));
			this.menu.add(item);
			item = new Gtk.MenuItem.with_label(_("Split vertically"));
			this.menu.add(item);

			this.menu.add(new Gtk.SeparatorMenuItem());

			item = new Gtk.MenuItem.with_label(_("Preferences"));
			this.menu.add(item);

			this.menu.add(new Gtk.SeparatorMenuItem());

			item = new Gtk.MenuItem.with_label(_("Close"));
			this.menu.add(item);
			this.menu.show_all();

			this.vte_terminal.button_press_event.connect(this.button_event);
			this.vte_terminal.events = Gdk.EventMask.BUTTON_PRESS_MASK;

		}

		public bool button_event(Gdk.EventButton event) {

			if (event.button == 3) {
				this.menu.popup(null,null,null,3,0);
				return true;
			}

			return false;

		}

		public void child_exited(int status) {
			this.ended();
		}

	}

}
