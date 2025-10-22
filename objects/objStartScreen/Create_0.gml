// --- State Machine Initialization ---
// 0 = SETUP, 1 = ACTIVE, 2 = INACTIVE
menu_state = 0;
selected_button = 0;
options_menu_open = false; // NEW: Tracks if the options sub-menu is open

// Ensure the control menu layer is hidden at the start
layer_set_visible("control_menu", false);