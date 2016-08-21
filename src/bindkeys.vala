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

using Gtk,Gdk,Keybinder;

namespace Terminus {

	// This class is the one that manages the global keybind

	public void keybind_cb(string key, void *udata) {
		Bindkey obj = (Bindkey)udata;
		obj.show_guake();
	}


	class Bindkey : Object {

		private string? key;

		public signal void show_guake();

		public Bindkey() {

			Keybinder.init();
			this.key = null;
		}

		public void set_bindkey(string key) {
			if (this.key != null) {
				this.unset_bindkey();
			}
			this.key = key;
			Keybinder.bind(key,Terminus.keybind_cb,this);
		}

		public void unset_bindkey() {
			if (this.key == null) {
				return;
			}
			Keybinder.unbind(this.key,Terminus.keybind_cb);
			this.key = null;
		}
	}
}
