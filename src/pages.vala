namespace Fabric.UI {
	public class Page : Gtk.Box {
		protected Header header;
		protected Gtk.Overlay overlay;
		protected Gtk.Box main_container;

		construct {
			header = new Header("(Unnamed)");
			base.append(header);
			orientation = Gtk.Orientation.VERTICAL;
			vexpand = true;
			hexpand = true;
			halign = Gtk.Align.FILL;
			valign = Gtk.Align.FILL;

			overlay = new Gtk.Overlay() {
				vexpand = true,
				hexpand = true,
				halign = Gtk.Align.FILL,
				valign = Gtk.Align.FILL
			};
			base.append(overlay);

			main_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
				vexpand = true,
				hexpand = true,
				halign = Gtk.Align.FILL,
				valign = Gtk.Align.FILL
			};
			overlay.set_child(main_container);

			header.back.clicked.connect(() => {
				this.go_back();
			});

			var hotkeys = new Gtk.EventControllerKey();
			hotkeys.key_pressed.connect((keyval, keycode, state) => {
				switch (keyval) {
					case Keys.XF86Back:
						go_back();
						break;
				}
			});
			this.add_controller(hotkeys);

			map.connect(() => {
				header.back.visible = PagesContainer.instance.pages_count > 1;
			});
		}

		public new virtual void append(Gtk.Widget child) {
			main_container.append(child);
		}

		public void go_back() {
			// TODO: add signal to allow preventing this from happening
			if (PagesContainer.instance.pages_count > 1) {
				PagesContainer.instance.pop(this);
			}
		}
	}

	public class ScrollingPage : Page {
		protected ScrollingArea scrolling_container;
		construct {
			scrolling_container = new ScrollingArea();
			base.append(scrolling_container);
		}

		public new virtual void append(Gtk.Widget child) {
			scrolling_container.append(child);
		}
	}

	public class Window : Gtk.Window {
		private bool _added_workaround_icon_dir = false;

		construct {
			vexpand = true;
			hexpand = true;
			halign = Gtk.Align.FILL;
			valign = Gtk.Align.FILL;
			set_name("FabricWindow");
			add_css_class("fabric-window");
			set_default_icon_name("unknown");
		}

		public string get_private_icon_path() {
			return Path.build_filename(Fabric.UI.Application.get_cache_dir(), "icons");
		}

		public void set_icon_from_texture(Gdk.Texture icon) {
			string icon_dir = Path.build_filename(get_private_icon_path(), "hicolor/scalable/apps/");
			DirUtils.create_with_parents(icon_dir, 0700);
			string icon_path = Path.build_filename(icon_dir, "%s-favicon.png".printf(GLib.Application.get_default().application_id));
			icon.save_to_png(icon_path);

			if (!_added_workaround_icon_dir) {
				var icon_theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default());
				icon_theme.add_search_path(get_private_icon_path());
				_added_workaround_icon_dir = true;
			}


			set_icon_from_path(icon_path);
		}

		public void set_icon_from_path(string path) {
			var regex = new Regex("\\.[^\\.]*$");
			var icon_name = regex.replace(Path.get_basename(path), -1, 0, "");
			set_icon_name(icon_name);
		}
	}

	public class PagedWindow : Window {
		construct {
			child = PagesContainer.instance;
		}
	}

	/**
	 * Window, but with a resize window_resized signal.
	 *
	 * NOTE: the child widget's minimal dimensions will **not** be respected.
	 *
	 * The widget will be cropped, in that case. Make sure your app handles
	 * this well enough.
	 */
	public class SizeableWindow : Window {
		public signal void window_resized(uint width, uint height);
		// Child of the window, used to find the dimensions of the window
		private Gtk.Overlay _size_oracle_overlay;
		// The child contains the _size_oracle_overlay
		private Gtk.Widget _useful_child;

		public Gtk.Widget child {
			get { return _useful_child; }
			set {
				_size_oracle_overlay.remove_overlay(_useful_child);
				_size_oracle_overlay.add_overlay(value);
				_useful_child = value;
			}
		}

		construct {
			_size_oracle_overlay = new Gtk.Overlay();
			base.child = _size_oracle_overlay;

			var size_oracle = new Gtk.DrawingArea() {
				vexpand = true,
				hexpand = true,
				halign = Gtk.Align.FILL,
				valign = Gtk.Align.FILL,
			};
			size_oracle.height_request = 0;
			size_oracle.width_request = 0;
			size_oracle.resize.connect(() => {
				window_resized(size_oracle.get_width(), size_oracle.get_height());
			});
			_size_oracle_overlay.child = size_oracle;
			size_oracle.resize(0, 0);
		}
	}

	public class SizeablePagedWindow : SizeableWindow {
		construct {
			child = PagesContainer.instance;
		}
	}
}
