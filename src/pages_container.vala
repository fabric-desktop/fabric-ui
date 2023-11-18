namespace Fabric.UI {
	/**
	 * Holds the pages of the application, used for the implicit transition.
	 *
	 * Behaves like a "proper" stack, in other words will always show the page
	 * at the top of the stack, and "navigating back" implies popping from
	 * the stack.
	 */
	public class PagesContainer : Gtk.Box {
		// Parts of the logical pages stack management
		private Queue<Gtk.Widget> children_stack;
		public Gtk.Widget current {
			get;
			private set;
		}
		private Gtk.Widget queued_for_removal;

		// Widgets building this higher order widget
		private Gtk.Widget blocker;
		private Gtk.Stack stack;

		// Singleton implementation
		private PagesContainer() {}
		private static PagesContainer? _instance;
		public static PagesContainer instance {
			get {
				if (_instance == null) {
					_instance = new PagesContainer();
				}
				return _instance;
			}
		}

		public uint pages_count {
			get {
				return children_stack.length - (queued_for_removal != null ? 1 : 0);
			}
		}

		construct {
			vexpand = true;
			hexpand = true;
			halign = Gtk.Align.FILL;
			valign = Gtk.Align.FILL;

			var overlay = new Gtk.Overlay(){
				vexpand = true,
				hexpand = true,
				halign = Gtk.Align.FILL,
				valign = Gtk.Align.FILL
			};
			add_css_class("fabric-pages-container");
			append(overlay);

			children_stack = new Queue<Gtk.Widget>();

			stack = new Gtk.Stack();
			stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
			overlay.set_child(stack);

			// Using a label as it intrinsically is drawn and can be styled.
			// It also does not pass through click events.
			blocker = new Gtk.Label("");
			blocker.set_name("FabricUIBlocker");
			blocker.visible = false;
			overlay.add_overlay(blocker);

			// Hooks stack_update_cb to important props.
			stack.notify["transition-running"].connect(() => {
				stack_update_cb();
			});
			stack.notify["visible-child"].connect(() => {
				stack_update_cb();
			});
		}

		/**
		 * Does internal accounting according to the state of the Stack.
		 *
		 *  - Handles the "blocker" element.
		 *  - Handles removing the queued element for removal after the transition is over.
		 */
		private void stack_update_cb() {
			if (stack.transition_running) {
				blocker.visible = true;
			}
			else {
				blocker.visible = false;
			}

			// Finally remove the stack page intended for deletion
			if (!stack.transition_running && stack.visible_child == current && queued_for_removal != null) {
				stack.remove(queued_for_removal);
				queued_for_removal = null;
			}
		}

		/**
		 * Properly handles the intent of making a stack element visible.
		 */
		private new void set_visible(Gtk.Widget child) {
			if (stack.get_page(child) == null) {
				error("Attempting to set visible a child not present in the stack...");
			}
			stack.set_visible_child(child);
			current = child;
		}

		/**
		 * Whether or not the stack is currently "blocked"
		 * This generally means the user can't do anything about it.
		 *
		 * You may want to connect to its notify signal such that you can
		 * start animations or other interactive bits only once this is done.
		 * But it's not mandatory.
		 */
		public bool is_blocked {
			get { return blocker.visible; }
		}

		/**
		 * Pushes (and activates) the given child.
		 */
		public void push(Gtk.Widget child) {
			if (is_blocked) {
				return;
			}
			raw_push(child);
		}

		/**
		 * Pushess without caring for the stack being blocked.
		 *
		 * Prefer using `push` as it intrinsically handles badly implemented
		 * double-click handling in Gtk.Button where the signal will be
		 * fired twice.
		 */
		public void raw_push(Gtk.Widget child) {
			if (stack.get_page(child) != null) {
				error("Trying to push a child already stacked in this PagesContainer");
			}

			children_stack.push_head(child);
			stack.add_child(child);
			set_visible(child);
		}

		/**
		 * Pops the child from the top of the stack, validating we're
		 * popping the right child.
		 *
		 * While pop shouldn't need an argument, we actually want to
		 * verify that we are popping the current child.
		 */
		public bool pop(Gtk.Widget verify_child) {
			if (is_blocked) {
				return false;
			}
			return raw_pop(verify_child);
		}

		/**
		 * Pops without caring for the stack being blocked.
		 *
		 * Prefer using `pop` as it intrinsically handles badly implemented
		 * double-click handling in Gtk.Button where the signal will be
		 * fired twice.
		 */
		public bool raw_pop(Gtk.Widget verify_child) {
			if (verify_child != children_stack.peek_head()) {
				error("Trying to pop an unexpected children from this PagesContainer");
			}
			queued_for_removal = children_stack.pop_head();
			set_visible(children_stack.peek_head());

			return true;
		}

		/**
		 * Replaces the current page, animating with the `push()` animation.
		 *
		 * It actually pushes the new page, and removes the previous page.
		 *
		 * This can be used to make wizard steps go between pages from a
		 * larger list of steps, while making sure going back goes back to
		 * the list of steps, rather than through every discrete steps.
		 */
		public void replace(Gtk.Widget child) {
			if (is_blocked) {
				return;
			}
			queued_for_removal = current;
			push(child);
		}
	}
}
