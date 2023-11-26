// Prevents `Gtk.StyleContext.add_provider_for_display` from producing a bogus warning...
// The warning here is bogus; `Gtk.StyleContext` has been deprecated, but
// *somehow* `gtk_style_context_add_provider_for_display` isn't...
// https://discourse.gnome.org/t/what-good-is-gtkcssprovider-without-gtkstylecontext/12621/2
extern void gtk_style_context_add_provider_for_display(
	Gdk.Display* display,
	Gtk.StyleProvider* provider,
	uint priority
);

namespace Fabric.UI {
	public class Application : Gtk.Application {
		private static double _current_dpi = 96;
		private Gtk.CssProvider _dpi_provider;

		public static double scale {
			get { return _current_dpi / 96.0; }
		}

		construct {
			flags = ApplicationFlags.DEFAULT_FLAGS;

			startup.connect(() => {
				add_styles_from_resource("/Fabric/UI/fabric-ui.css");
				_handle_fabric_dpi();
			});
		}

		public static string get_data_dir() {
			return Path.build_filename(
				Environment.get_user_data_dir()
				, GLib.Application.get_default().application_id
			);
		}

		public static string get_config_dir() {
			return Path.build_filename(
				Environment.get_user_config_dir()
				, GLib.Application.get_default().application_id
			);
		}

		/**
		 * Implicitly creates the cache dir for this app, and returns the path.
		 */
		public static string get_cache_dir() {
			string path = Path.build_filename(
				Environment.get_user_cache_dir()
				, GLib.Application.get_default().application_id
			);
			DirUtils.create_with_parents(path, 0700);
			return path;
		}

		public Gtk.StyleProvider add_styles_from_resource(string path) {
				var provider = new Gtk.CssProvider();

				provider.load_from_resource(path);
				gtk_style_context_add_provider_for_display(Gdk.Display.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

				return provider;
		}

		public double get_gdk_scale() {
			double scale_factor = 0;
			Gtk.Window window = active_window;

			if (active_window == null) {
				debug("No window yet... making something temporarily...");
				window = new Gtk.Window();
				window.present();
				scale_factor = window.get_surface().scale_factor;
				window.destroy();
			}
			else {
				scale_factor = window.get_surface().scale_factor;
			}

			return scale_factor;
		}

		/**
		 * This function allows applications to force a specific "font" DPI for the application.
		 *
		 * Note that this differs from the scale, what people would refer to for DPI.
		 *
		 * This allows tighter control, *including fractional scaling*.
		 */
		public void force_dpi(double value) {
			double scale_factor = get_gdk_scale();
			double adjusted_dpi = value / scale_factor;
			_current_dpi = adjusted_dpi;
			
#if FABRIC_DEBUG_SCALING
			debug("DPI: %f", value);
			debug("ADJUSTED DPI: %f", adjusted_dpi);
			debug("Fabric scale: %f", scale);
			debug("GDK Scale factor: %f", scale_factor);
#endif
			if (_dpi_provider == null) {
				_dpi_provider = new Gtk.CssProvider();
				gtk_style_context_add_provider_for_display(Gdk.Display.get_default(), _dpi_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER + 100);
			}

			double border_width = Math.round(value / 96.0);

			// NOTE: `calc` does not provide the appropriate semantics to handle this in CSS.
			// Furthermore, no CSS variables.
			// We may want to actually add some basic templating to make our own variables system :X
			// So, for now, all "pixel perfect" values should be here. Limit to borders.
			_dpi_provider.load_from_data((uint8[])"""
				window { -gtk-dpi: %f; }

				button { border-width: %fpx; }
			""".printf(
				adjusted_dpi
				, border_width
			));
		}

		private void _handle_fabric_dpi() {
			// TODO: add `fabric` framework config, and add dpi setting in there.
			// NOTE: preferred config is through /etc/xdg/... config!!
			// The FABRIC_DPI environment variable is useful for testing and development.
			unowned string fabric_dpi = Environment.get_variable("FABRIC_DPI");
			// By default the DPI is set to a computed "real" value.
			if (fabric_dpi == null || fabric_dpi == "") {
				_handle_default_fabric_dpi();
			}
			// Otherwise a numeric fabric_dpi means a forced value.
			else if (double.parse(fabric_dpi) > 10.0) {
				force_dpi(double.parse(fabric_dpi));
			}
		}
		// Defaults for unset FABRIC_DPI or set to `default`.
		private void _handle_default_fabric_dpi() {
			var display = Gdk.Display.get_default();
			// For now, assume that the first monitor is correct as a default scale factor.
			// It is assumed to be e.g. the laptop's own or the phone's own monitor.
			// This will need to be handled better at some point.
			// We may want to do a macOS approach where we get the monitor for the surface.
			//   -> https://valadoc.org/gtk4/Gdk.Display.get_monitor_at_surface.html
			// This would *somehow* need to happen at any window move, correctly.
			// Using the 0th monitor by default is fine enough since it will be static.
			var monitor = (Gdk.Monitor)display.get_monitors().get_item(0);
#if FABRIC_DEBUG_SCALING
			debug(
				"Monitor[0] (%s): %i×%imm, @ %i×%ipx"
				, monitor.model
				, monitor.width_mm, monitor.height_mm
				, monitor.geometry.width, monitor.geometry.height
			);
#endif
			double pixels = monitor.geometry.height;
			// We'll convert to inches, since DPI is per inch...
			double height_inches = monitor.height_mm / 25.4;
			double dpi = pixels / height_inches;

			force_dpi(dpi);
		}
	}
}
