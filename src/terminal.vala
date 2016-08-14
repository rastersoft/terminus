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
using GLib;

namespace Terminus {

	class Terminal : Gtk.Box {

		public Vte.Terminal vte_terminal;
		public int pid;

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
		}

		public void child_exited(int status) {
			this.ended();
		}

	}

}
