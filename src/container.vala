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

using Vte;
using Gtk;
using GLib;

namespace Terminus {
	/**
	 * This is the terminal container. It can contain one terminal, or a Paned with
	 * two containers. It can be splited in two elements and reagruped in a single
	 * one.
	 */

	class Container : Gtk.Bin {
		public Terminus.Container ? container1;
		public Terminus.Container ? container2;
		public Terminus.Notetab ? notetab;

		private Terminus.Terminal ? terminal;
		private Terminus.PanedPercentage ? paned;
		private Terminus.Container top_container;
		private Terminus.Base main_container;

		public signal void ended(Terminus.Container who);

		public Container(Terminus.Base main_container, Terminus.Terminal ? terminal, Terminus.Container ? top_container = null) {
			this.main_container = main_container;
			if (top_container == null) {
				this.top_container = this;
				this.notetab       = new Terminus.Notetab(this.main_container, this);
			} else {
				this.top_container = top_container;
				this.notetab       = null;
			}

			if (terminal == null) {
				this.terminal = new Terminus.Terminal(this.main_container, this.top_container);
			} else {
				this.terminal = terminal;
			}

			this.set_terminal_child();
		}

		public void set_tab_title(string title) {
			if (this.notetab != null) {
				this.notetab.change_title(title);
			}
		}

		public void set_terminal_child() {
			this.add(this.terminal);
			this.terminal.ended.connect(this.ended_cb);

			this.terminal.split_horizontal.connect(this.split_horizontal_cb);
			this.terminal.split_vertical.connect(this.split_vertical_cb);

			this.paned      = null;
			this.container1 = null;
			this.container2 = null;
		}

		public Gtk.Widget ? get_current_child() {
			if (this.terminal != null) {
				this.terminal.split_horizontal.disconnect(this.split_horizontal_cb);
				this.terminal.split_vertical.disconnect(this.split_vertical_cb);
				this.terminal.ended.disconnect(this.ended_cb);
				this.remove(this.terminal);
				return this.terminal;
			} else {
				this.container1.ended.disconnect(this.ended_child);
				this.container2.ended.disconnect(this.ended_child);
				this.remove(this.paned);
				return this.paned;
			}
		}

		public void ended_cb() {
			this.ended(this);
		}

		public void split_horizontal_cb() {
			this.split(true);
		}

		public void split_vertical_cb() {
			this.split(false);
		}

		private void split(bool horizontal) {
			this.remove(terminal);
			this.terminal.split_horizontal.disconnect(this.split_horizontal_cb);
			this.terminal.split_vertical.disconnect(this.split_vertical_cb);
			this.terminal.ended.disconnect(this.ended_cb);

			this.paned      = new Terminus.PanedPercentage(horizontal ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL, 0.5);
			this.container1 = new Terminus.Container(this.main_container, this.terminal, this.top_container);
			this.container2 = new Terminus.Container(this.main_container, null, this.top_container);
			this.container1.ended.connect(this.ended_child);
			this.container2.ended.connect(this.ended_child);
			this.paned.add1(this.container1);
			this.paned.add2(this.container2);
			this.add(this.paned);
			this.paned.show_all();
			this.terminal = null;
		}

		public void do_grab_focus() {
			if (this.terminal == null) {
				this.container1.do_grab_focus();
			} else {
				this.terminal.do_grab_focus();
			}
		}

		public void ended_child(Terminus.Container child) {
			Terminus.Container old_container;

			if (child == this.container1) {
				old_container = this.container2;
			} else {
				old_container = this.container1;
			}
			var new_child = old_container.get_current_child();
			this.paned.remove(this.container1);
			this.paned.remove(this.container2);
			this.container1.ended.disconnect(this.ended_child);
			this.container2.ended.disconnect(this.ended_child);
			this.remove(this.paned);
			if (new_child is Terminus.Terminal) {
				this.terminal = new_child as Terminus.Terminal;
				this.set_terminal_child();
				this.terminal.do_grab_focus();
			} else {
				this.paned      = new_child as Terminus.PanedPercentage;
				this.container1 = old_container.container1;
				this.container2 = old_container.container2;
				this.container1.ended.connect(this.ended_child);
				this.container2.ended.connect(this.ended_child);
				this.add(this.paned);
				this.paned.show_all();
				this.container1.do_grab_focus();
			}
		}
	}
}
