namespace Fabric.UI {
	public class MaybeEmptyBox : Gtk.Box {
		private Queue<Gtk.Widget> children;
		private Gtk.Widget _empty_widget;
		private Gtk.FlowBox _actual_widget;

		public Gtk.Widget empty_widget {
			get { return _empty_widget; }
			set {
				if (_empty_widget != null) {
					base.remove(_empty_widget);
				}
				_empty_widget = value;
				base.prepend(_empty_widget);
				update_empty_widget_state();
			}
		}
		
		public uint children_per_line {
			get {
				return _actual_widget.max_children_per_line;
			}
			set {
				_actual_widget.max_children_per_line = value;
				_actual_widget.min_children_per_line = value;
			}
		}

		public MaybeEmptyBox() {
			Object(orientation: Gtk.Orientation.VERTICAL);
		}

		construct {
			children = new Queue<Gtk.Widget>();
			hexpand = true;
			halign = Gtk.Align.FILL;
			valign = Gtk.Align.FILL;

			_actual_widget = new Gtk.FlowBox();
			_actual_widget.selection_mode = Gtk.SelectionMode.NONE;
			_actual_widget.max_children_per_line = 1;
			_actual_widget.min_children_per_line = 1;
			_actual_widget.homogeneous = true;
			base.append(_actual_widget);

			add_css_class("fabric-maybe-empty-box");
			update_empty_widget_state();
		}

		private void update_empty_widget_state() {
			if (children.is_empty()) {
				add_css_class("-is-empty");
			}
			else {
				remove_css_class("-is-empty");
			}
			if (empty_widget != null) {
				remove_css_class("-is-unconfigured");
				empty_widget.set_visible(children.is_empty());
			}
			else {
				add_css_class("-is-unconfigured");
			}
		}

		public new void prepend() {
			// Marking it `private` will add the warning “Method `Fabric.UI.MaybeEmptyBox.prepend' never used”...
			// So let's do this to remove the warning, for now :/
			error("MaybeEmptyBox#prepend() is not supported.");
		}

		public new void append(Gtk.Widget child) {
			remove_css_class("-is-empty");
			children.push_head(child);
			_actual_widget.append(child);
			update_empty_widget_state();
		}

		public new void remove(Gtk.Widget child) {
			_actual_widget.remove(child);
			children.remove(child);
			if (children.is_empty()) {
				add_css_class("-is-empty");
			}
			update_empty_widget_state();
		}
	}
}
