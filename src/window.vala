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

	class Window : Gtk.Window {

		public signal void ended(Terminus.Window window);
		public signal void new_window();

		private Terminus.Base terminal;

		public Window(bool guake_mode) {

			this.destroy.connect( (w) => {
				this.ended(this);
			});

			this.terminal = new Terminus.Base();
			this.terminal.ended.connect( (w) => {
				this.destroy();
			});

			this.terminal.new_window.connect( () => {
				this.new_window();
			});

			this.add(this.terminal);
			this.show_all();
			this.present();
			if (guake_mode) {
				this.present_guake();
			}
		}

		public void present_guake() {
			var scr = this.get_screen();
			var screen_w = scr.get_width();
			int screen_h = Terminus.settings.get_int("guake-height");
			if (screen_h < 0) {
				screen_h = scr.get_height() * 3 / 7;
			}
			this.set_keep_above(true);
			this.set_skip_taskbar_hint(true);
			this.set_skip_pager_hint(true);
			this.set_decorated(false);
			this.move(0,0);
			this.resize(screen_w,screen_h);
		}
	}

}
