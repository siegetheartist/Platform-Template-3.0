/// @function scr_game_over();
/// @description Handles all input and logic for the Game Over screen.

function scr_game_over() {
    
    // Self-initialize the selected_button variable if it doesn't exist
    if (!variable_instance_exists(oGameManager, "selected_button")) {
        oGameManager.selected_button = 0;
    }

    // --- Gather Input ---
    // Get the raw input from the exact same script the player uses.
    var _input = scr_get_input();
    
    // --- Handle Menu Logic ---
    
    // Use the "pressed" inputs for snappy menu navigation.
    if (_input.left_pressed) {
        selected_button = max(0, selected_button - 1);
    }
    
    if (_input.right_pressed) {
        selected_button = min(1, selected_button + 1);
    }
    
    // Use the attack button for "confirm" to match player controls.
    if (_input.attack_pressed) {
        // Reset
        player_lives = 1;
        crystals_collected = 0;
        current_state = GAME_STATE.IDLE;
        layer_set_visible("Layer_Game_over", false);
        
        if (selected_button == 0) { // Try Again
            room_restart();
            // initiate_fader_in();
        } else { // Back to Menu
            room_goto(r_start_screen);
            // initiate_fader_in();
        }
    }
}