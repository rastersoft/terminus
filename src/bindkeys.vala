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

using Gtk, Gdk, Keybinder;

namespace Terminus {
	// This class is the one that manages the global keybind

	public void keybind_cb(string key, void *udata) {
		Bindkey obj = (Bindkey) udata;
		obj.show_guake();
	}

	class Bindkey : Object {
		private string ? key;
		private bool use_bindkey;

		public signal void show_guake();

		public Bindkey(bool use_bindkey) {
			this.use_bindkey = use_bindkey;
			if (this.use_bindkey) {
				Keybinder.init();
			}
			this.key = null;
		}

		public bool set_bindkey(string key) {
			bool retval;

			if (this.use_bindkey) {
				if (this.key != null) {
					this.unset_bindkey();
				}
			}
			this.key = key;
			if (this.use_bindkey) {
				retval = Keybinder.bind(key, Terminus.keybind_cb, this);
				if (retval == false) {
					print("Failed to set the guake_mode bind key\n");
				}
				return retval;
			} else {
				return true;
			}
		}

		public void unset_bindkey() {
			if (this.use_bindkey) {
				if (this.key == null) {
					return;
				}
				Keybinder.unbind(this.key, Terminus.keybind_cb);
				this.key = null;
			}
		}
	}
}
