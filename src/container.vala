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

	class Container : Gtk.Bin {

		private bool has_terminal;
		private Terminus.Terminal? child1;
		private Terminus.Terminal? child2;


		signal void ended(Terminus.Container who);

		public Container(Terminus.Terminal? child) {

			this.has_terminal = true;

			if (child == null) {
				this.child1 = new Terminus.Terminal();
				this.add(this.child1);
				this.child1.ended.connect(this.child1_exited);
			} else {
				this.add(child);
				child.ended.connect(this.child1_exited);
				this.child1 = child;
			}
			this.child2 = null;
		}

		public void child1_exited() {
			if (this.child2 == null) {
				this.ended(this);
			}
		}
	}
}
