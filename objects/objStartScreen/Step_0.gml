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
        
        var _input = scr_player_get_input();
        
        // --- Check which menu is currently active ---
        if (options_menu_open) {
            // If the options menu is open, only listen for the back command to close it.
            if (_input.back_pressed) {
                options_menu_open = false;
                layer_set_visible("control_menu", false);
                layer_set_visible("start_menu", true);
                // Optional: Play a "cancel" sound effect
                // audio_play_sound(sndButtonCancel, 10, false); 
            }
        } else {
            // If the main menu is open, run the navigation and confirmation logic.
            var _previously_selection = selected_button;
            
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
            if (_input.confirm_pressed) {
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
                        
                    case 1: // "Options" -> MODIFIED
                        audio_play_sound(sndButtonConfirm, 10, false);
                        options_menu_open = true; // Set our flag
                        layer_set_visible("start_menu", false); // Hide main menu
                        layer_set_visible("control_menu", true); // Show control menu
                        break;
                        
                    case 2: // "Exit Game"
                        game_end();
                        break;
                }
            }
        }
        break;
        
    case 2: // INACTIVE
        // Give control back to the player.
        if (instance_exists(oPlayer)) {
            oPlayer.can_control = true;
        }
        room_goto_next()
        break;
}