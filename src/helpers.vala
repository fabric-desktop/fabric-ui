namespace Fabric.UI {
	namespace Helpers {
		public Gtk.Label make_text(string label) {
			var sub = new Gtk.Label(label) {
				xalign = 0,
				wrap = true,
			};

			return sub;
		}
		public Gtk.Label make_subheading(string label) {
			var sub = make_text(label);
			sub.add_css_class("fabric-subheading");

			return sub;
		}
	}
}
