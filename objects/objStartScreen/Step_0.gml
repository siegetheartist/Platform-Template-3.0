switch (menu_state) {
    
    case 0: // SETUP
        // This case runs once upon entering the room.
        oHUD.visible = false;
        
        // Show the menu UI layer.
        layer_set_visible("start_menu", true);
        
        // Disable player controls.
        if (instance_exists(oPlayer)) {
            oPlayer.can_control = false;
        }
        
        // Move to the ACTIVE state for the next frame.
        menu_state = 1;
        break;
        
    case 1: // ACTIVE (Main Menu Loop)
        
        var _previously_selection = selected_button; // Store the current selected button before checking for input
        var _input = scr_player_get_input();
        
        // Handle navigation
        if (_input.left_pressed) {
            selected_button--;
        }
        if (_input.right_pressed) {
            selected_button++;
        }
        selected_button = clamp(selected_button, 0, 2); // Clamp between 3 buttons
        
        if (selected_button != _previously_selection) {
        	audio_play_sound(sndButtonSelect, 10, false);
        }

        // Handle confirmation
        if (_input.attack_pressed) {
            switch (selected_button) {
                case 0: // "Start Game"
                    audio_play_sound(sndButtonConfirm, 10, false);
                    
                    // Hide the menu UI.
                    layer_set_visible("start_menu", false);
                    
                    // Show player HUD after starting the game.
                    oHUD.visible = true;
                    
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
        // Give control back to the player.
        if (instance_exists(oPlayer)) {
            oPlayer.can_control = true;
        }
        break;
}
