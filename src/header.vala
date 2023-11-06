namespace Fabric.UI {
	public class Header : Gtk.Box {
		private Gtk.Label _label;
		private Gtk.Box _actions;
		private Gtk.Button _back;

		public string label {
			get { return this._label.label; }
			set { this._label.label = value; }
		}

		public Gtk.Box actions {
			get { return this._actions; }
		}

		public Gtk.Button back {
			get { return this._back; }
		}

		public Header(string label) {
			this.set_name("FabricHeader");
			this.add_css_class("fabric-header");
			this._back = new Gtk.Button();
			this._back.label = "←";
			this._back.add_css_class("fabric-header-back-button");
			append(this._back);

			this._label = new Gtk.Label(label);
			append(this._label);

			this._actions = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			this._actions.hexpand = true;
			this._actions.halign = Gtk.Align.END;
			append(this._actions);
		}
		construct {
			orientation = Gtk.Orientation.HORIZONTAL;
			hexpand = true;
			halign = Gtk.Align.FILL;
			valign = Gtk.Align.FILL;
		}
	}
}
