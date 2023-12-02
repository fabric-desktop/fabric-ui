namespace Fabric.UI {
	public class ScrollingArea : Gtk.Widget {
		private Gtk.ScrolledWindow area;
		private Gtk.Box box;

		public Gtk.Align viewport_valign {
			get { return this.area.get_first_child().valign; }
			set { this.area.get_first_child().valign = value; }
		}

		public Gtk.Adjustment vadjustment {
			get { return this.area.vadjustment; }
		}

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

		public void remove(Gtk.Widget widget) {
			this.box.remove(widget);
		}

		public new unowned Gtk.Widget get_first_child() {
			return this.box.get_first_child();
		}

		public override void dispose() {
			this.area.unparent();
			base.dispose();
		}

		public void scroll_to_top() {
			vadjustment.value = 0;
		}
		public void scroll_to_bottom() {
			vadjustment.value = vadjustment.upper;
		}
		public void scroll_to_widget(Gtk.Widget widget) {
			Graphene.Point point = {};                                
			widget.compute_point(widget.get_parent(), point, out point);

			vadjustment.value = point.y - get_height()/2;
		}
	}
}
