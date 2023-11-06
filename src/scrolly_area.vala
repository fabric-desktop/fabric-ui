namespace Fabric.UI {
	public class ScrollingArea : Gtk.Widget {
		private Gtk.ScrolledWindow area;
		private Gtk.Box box;

		construct {
			this.set_layout_manager(new Gtk.BinLayout());
			this.hexpand = true;
			this.vexpand = true;
			this.halign = Gtk.Align.FILL;
			this.valign = Gtk.Align.FILL;
			this.area = new Gtk.ScrolledWindow();
			this.add_css_class("fabric-scrolling-area");
			this.area.set_parent(this);
			this.area.set_policy(
				Gtk.PolicyType.NEVER,
				Gtk.PolicyType.AUTOMATIC
			);
			this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			this.box.set_name("ScrollingPage");
			this.box.add_css_class("box");
			this.area.set_child(this.box);
		}

		public void append(Gtk.Widget widget) {
			this.box.append(widget);
		}

		~ScrollingArea() {
			this.area.unparent();
		}
	}
}
