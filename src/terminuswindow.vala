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

namespace Terminus {

	class TerminusWindow : Gtk.Window {

		public signal void ended(Terminus.TerminusWindow window);
		public signal void new_window();

		private Terminus.TerminusBase terminal;

		public TerminusWindow(bool guake_mode) {

			this.destroy.connect( (w) => {
				this.ended(this);
			});

			this.terminal = new Terminus.TerminusBase();
			this.terminal.ended.connect( (w) => {
				this.destroy();
			});

			this.terminal.new_window.connect( () => {
				this.new_window();
			});

			this.add(this.terminal);
			this.show_all();
		}
	}

}
