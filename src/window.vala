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
		public bool is_guake;

		private int current_size;
		private int mouseY;
		private Gtk.Paned paned;
		private Gtk.Fixed fixed;

		private Terminus.Base terminal;

		public Window(bool guake_mode) {

			this.is_guake = guake_mode;

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

			if (guake_mode) {
				this.map.connect(this.mapped);
				this.paned = new Gtk.Paned(Gtk.Orientation.VERTICAL);
				this.paned.wide_handle = true;
				this.add(this.paned);
				this.paned.add1(this.terminal);
				this.fixed = new Gtk.Fixed();
				this.fixed.set_size_request(1,1);
				this.paned.add2(fixed);
				this.mouseY = -1;
				this.paned.motion_notify_event.connect( (widget,event) => {
					if (this.mouseY < 0) {
						return false;
					}
					int y;
					y = (int)(event.y_root);
					int newval = y - this.mouseY;
					this.current_size += newval;
					this.mouseY = y;
					this.resize(this.get_screen().get_width(),this.current_size);
					this.paned.set_position(this.current_size);
					return true;
				});

				this.paned.button_press_event.connect( (widget, event) => {
					if (event.button != 1) {
						return false;
					}
					int y;
					y = (int)(event.y_root);
					this.mouseY = y;
					return true;
				});

				this.paned.button_release_event.connect( (widget,event) => {
					if (event.button != 1) {
						return false;
					}
					this.mouseY = -1;
					Terminus.settings.set_int("guake-height", this.current_size);
					return true;
				});

			} else {
				this.add(this.terminal);
			}
			if (guake_mode) {
				this.present_guake();
			}
			this.show_all();
			this.present();
		}

		public void mapped() {
			this.present_guake(false);
		}

		public void present_guake(bool minimum = true) {
			this.fixed.set_size_request(1,1);
			var scr = this.get_screen();
			var screen_w = scr.get_width();
			this.current_size = Terminus.settings.get_int("guake-height");
			if (this.current_size < 0) {
				this.current_size = scr.get_height() * 3 / 7;
				Terminus.settings.set_int("guake-height", this.current_size);
			}
			this.set_keep_above(true);
			this.set_skip_taskbar_hint(true);
			this.set_skip_pager_hint(true);
			this.set_decorated(false);
			this.move(0,0);
			if (minimum) {
				// a trick to ensure that everything has the desired size
				this.resize(screen_w,this.current_size/2);
			} else {
				this.resize(screen_w,this.current_size);
			}
			this.paned.set_position(this.current_size);
		}
	}

}
