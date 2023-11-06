namespace Fabric.UI {
	namespace Helpers {
		public Gtk.Label make_subheading(string label) {
			var sub = new Gtk.Label(label);
			sub.xalign = 0;
			sub.add_css_class("fabric-subheading");

			return sub;
		}
	}
}
