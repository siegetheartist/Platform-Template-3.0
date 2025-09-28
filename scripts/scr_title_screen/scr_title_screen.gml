/// @function scr_title_screen();
/// @description A self-contained script to manage the entire title screen menu.

function scr_title_screen() {

    // --- State Machine Initialization ---
    // This block runs only once to set up the menu's state machine.
    // 0 = SETUP, 1 = ACTIVE, 2 = INACTIVE
    if (!variable_instance_exists(id, "menu_state")) {
        menu_state = 0; // Start in the SETUP state
        selected_button = 0;
    }

    // --- State Machine Logic ---
    switch (menu_state) {
        
        case 0: // SETUP
            // This case runs once upon entering the room.
            
            // Show the menu UI layer.
            layer_set_visible("start_menu", true);
            
            // Disable player controls.
            if (instance_exists(oPlayer)) {
                oPlayer.can_control = false;
            }
            
            // Set the default selected button.
            selected_button = 0;
            
            // Move to the ACTIVE state for the next frame.
            menu_state = 1;
            break;
            
        case 1: // ACTIVE (Main Menu Loop)
            // Gather input from our universal script.
            var _input = scr_get_input();
            
            // Handle navigation
            if (_input.left_pressed) {
                selected_button--;
            }
            if (_input.right_pressed) {
                selected_button++;
            }
            selected_button = clamp(selected_button, 0, 2); // Clamp between 3 buttons

            // Handle confirmation
            if (_input.attack_pressed) {
                switch (selected_button) {
                    case 0: // "Start Game"
                        // Hide the menu UI.
                        layer_set_visible("start_menu", false);
                        // Give control back to the player.
                        if (instance_exists(oPlayer)) {
                            oPlayer.can_control = true;
                        }
                        // The menu is now done, so move to the INACTIVE state.
                        menu_state = 2;
                        break;
                        
                    case 1: // "Options"
                        show_debug_message("ACTION: Options");
                        break;
                        
                    case 2: // "Exit Game"
                        game_end();
                        break;
                }
            }
            break;
            
        case 2: // INACTIVE
            // The menu has been completed. Do nothing.
            break;
    }
}