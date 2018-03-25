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

using Gtk;

namespace Terminus {
	class Fixed : Gtk.Fixed {
		public override void get_preferred_width(out int minimum_width, out int natural_width) {
			base.get_preferred_width(out minimum_width, out natural_width);
			minimum_width = 1;
			natural_width = 1;
		}

		public override void get_preferred_height(out int minimum_height, out int natural_height) {
			base.get_preferred_height(out minimum_height, out natural_height);
			minimum_height = 1;
			natural_height = 1;
		}
	}

	class Window : Gtk.Window {
		public signal void ended(Terminus.Window window);
		public signal void new_window();

		private int current_size;
		private int mouseY;
		private Gtk.Paned paned;
		private Terminus.Fixed fixed;
		private bool is_guake;

		private Terminus.Base terminal;
		private int initialized;

		private int get_monitor_width() {
#if GTK_3_20
			return this.get_screen().get_width();
#else
			return this.get_display().get_monitor_at_window(this.get_window().get_effective_toplevel()).get_geometry().width;
#endif
		}

		private int get_monitor_height() {
#if GTK_3_20
			return this.get_screen().get_height();
#else
			return this.get_display().get_monitor_at_window(this.get_window().get_effective_toplevel()).get_geometry().height;
#endif
		}

		public Window(bool guake_mode, Terminus.Base ? terminal = null) {
			this.is_guake    = guake_mode;
			this.initialized = 0;

			this.type_hint    = Gdk.WindowTypeHint.NORMAL;
			this.focus_on_map = true;

			this.destroy.connect((w) => {
				this.ended(this);
			});

			if (terminal == null) {
				this.terminal = new Terminus.Base();
			} else {
				this.terminal = terminal;
			}
			this.terminal.ended.connect(this.ended_cb);

			this.terminal.new_window.connect(() => {
				this.new_window();
			});

			this.show.connect_after(() => {
				GLib.Timeout.add(500, () => {
					this.present();
					return false;
				});
			});

			if (guake_mode) {
				this.set_properties();

				this.current_size = Terminus.settings.get_int("guake-height");
				if (this.current_size < 0) {
					this.current_size = this.get_monitor_height() * 3 / 7;
					Terminus.settings.set_int("guake-height", this.current_size);
				}

				this.map.connect(this.mapped);
				this.realize.connect_after(() => {
					this.set_size();
				});
				this.window_state_event.connect((event) => {
					if ((event.new_window_state & Gdk.WindowState.MAXIMIZED) != 0) {
					    this.unmaximize();
					    this.set_size();
					}
					return false;
				});
				this.paned             = new Gtk.Paned(Gtk.Orientation.VERTICAL);
				this.paned.wide_handle = true;
				this.paned.events      = Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK;
				this.add(this.paned);
				this.paned.add1(this.terminal);
				this.fixed = new Terminus.Fixed();
				//this.fixed.set_size_request(1,1);
				this.paned.add2(fixed);
				this.mouseY = -1;

				this.paned.motion_notify_event.connect((widget, event) => {
					if (this.mouseY < 0) {
					    return false;
					}

					if ((event.state & Gdk.ModifierType.BUTTON1_MASK) == 0) {
					    this.mouseY = -1;
					    Terminus.settings.set_int("guake-height", this.current_size);
					    return false;
					}

					int y;
					y = (int) (event.y_root);
					int newval = y - this.mouseY;
					this.current_size += newval;
					this.mouseY        = y;
					this.resize(this.get_monitor_width(), this.current_size);
					this.paned.set_position(this.current_size);
					return true;
				});

				this.paned.button_press_event.connect((widget, event) => {
					if (event.button != 1) {
					    return false;
					}
					int y;
					y           = (int) (event.y_root);
					this.mouseY = y;
					return true;
				});

				this.paned.button_release_event.connect((widget, event) => {
					if (event.button != 1) {
					    return false;
					}
					this.mouseY = -1;
					Terminus.settings.set_int("guake-height", this.current_size);
					return true;
				});

				this.paned.show_all();
			} else {
				this.add(this.terminal);
				this.terminal.show_all();
				this.present();
			}
		}

		public void ended_cb() {
			this.terminal.ended.disconnect(this.ended_cb);
			this.destroy();
		}

		public void mapped() {
			this.set_properties();
			this.present();
			this.set_size();
		}

		private void set_properties() {
			this.stick();
			this.set_keep_above(true);
			this.set_skip_taskbar_hint(true);
			this.set_skip_pager_hint(true);
			this.set_decorated(false);
		}

		private void set_size() {
			this.move(0, 0);
			this.paned.set_position(this.current_size);
			this.resize(this.get_monitor_width(), this.current_size);
		}
	}
}
