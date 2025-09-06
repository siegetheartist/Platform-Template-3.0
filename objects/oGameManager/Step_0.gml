// Add this timer to the top of your Step Event, before the other regions.
if (respawn_grace_period > 0) {
    respawn_grace_period--;
}


#region PLAYER DEATH CHECK
// Player death check. This is now handled here, not in the player object.
// We will only check for death if the grace period has expired and we are in the IDLE state.
if (instance_exists(oPlayer) && (oPlayer.player_health <= 0 || oPlayer.y > oPlayer.fall_threshold) && respawn_grace_period <= 0) {
    
    // === DEBUG: Check if death is detected ===
    show_debug_message("Death condition met. Player health: " + string(oPlayer.player_health) + " | Player Y: " + string(oPlayer.y));
    
    if (current_state == GAME_STATE.IDLE) {
        // We will also check if the player is in the process of dying
        if (oPlayer.player_state != PlayerState.DEAD) {
            // Set the death state to prevent the death loop.
            oPlayer.player_state = PlayerState.DEAD;
            
            // Play the death sound for any death.
            audio_play_sound(sndPlayerDeath, 10, false);
            
            // Check if the player has lives remaining.
            if (player_lives > 0) {
                // Player has lives remaining: Decrement life and trigger respawn.
                player_lives--;
                next_action = "respawn";
            } else {
                // Player has no lives remaining: GAME OVER.
                next_action = "game_over";
            }
            
            // === DEBUG: Check next action ===
            show_debug_message("Setting next_action to: " + next_action);
            
            // Start the fade-out process.
            initiate_fader_out();
            
            // Manually destroy the player instance to prevent the death loop.
            instance_destroy(oPlayer);
        }
    }
}
#endregion


#region GAME STATE MACHINE
switch (current_state) {
    case GAME_STATE.IDLE:
        // Everything is running normally.
        break;

    case GAME_STATE.FADING_OUT:
        // The screen is fading to black. Do nothing until fade is complete.
    
        // === DEBUG: Confirm state change ===
        show_debug_message("State is now FADING_OUT");
    
        break;

    case GAME_STATE.FADE_COMPLETE:
        // === DEBUG: Confirm state change ===
        show_debug_message("Fade is complete. Performing action: " + next_action);
    
        // The screen is black. Perform the queued action.
        switch (next_action) {
            case "respawn":
                // === DEBUG: Check respawn coordinates ===
                show_debug_message("Attempting respawn at: (" + string(global.checkpoint_x) + ", " + string(global.checkpoint_y) + ")");
    
                // Respawn logic
                var _old_player = instance_find(oPlayer, 0);
                if (_old_player) {
                    instance_destroy(_old_player);
                }
                
                // Create a new player instance at the last checkpoint's location.
                var _new_player = instance_create_layer(global.checkpoint_x, global.checkpoint_y, "l_Player", oPlayer);
                _new_player.can_control = false;
                _new_player.player_health = max_player_health; // Reset health
                _new_player.player_state = PlayerState.IDLE; // Reset the state
                
                // Set a grace period to prevent immediate death
                respawn_grace_period = 10; // 10 frames of invulnerability
                
                // Trigger the fade back in.
                initiate_fader_in();
                break;
                
            case "next_level":
                // Next level logic
                if (room != room_last) {
                    room_goto_next();
                } else {
                    // This is the last room, so trigger a game over or end screen.
                    next_action = "game_over";
                    initiate_fader_out();
                }
                break;
            
            case "game_over":
                // Game over logic (Permanent)
                layer_set_visible("Layer_Game_over", true);
                selected_button = 0; // Default to "Try Again"
                current_state = GAME_STATE.GAME_OVER;
                break;
        }
        break;

    case GAME_STATE.FADING_IN:
        // === DEBUG: Confirm state change ===
        show_debug_message("State is now FADING_IN");
    
        // The screen is fading back in. Do nothing until fade is complete.
        break;
        
    case GAME_STATE.GAME_OVER:
        // Game Over Screen Input
        // 'A' key to select previous button
        if (keyboard_check_pressed(ord("A"))) {
            selected_button = max(0, selected_button - 1);
        }
        
        // 'D' key to select next button
        if (keyboard_check_pressed(ord("D"))) {
            selected_button = min(1, selected_button + 1);
        }
        
        // 'J' key to confirm selection
        if (keyboard_check_pressed(ord("J"))) {
            // These actions are common to both buttons, so we can do them here
            player_lives = 1;
            crystals_collected = 0;
            current_state = GAME_STATE.IDLE;
            layer_set_visible("Layer_Game_over", false);
            
            // Now, perform the unique action for the selected button
            if (selected_button == 0) { // Try Again
                room_restart();
                initiate_fader_in();
            } else if (selected_button == 1) { // Back to Menu
                room_goto(rStartMenu);
                initiate_fader_in();
            }
        }
        break;
}

#endregion


#region PARALLAX SCROLLING
// Parallax Scrolling Logic
// Get the camera's current X position.
var _camera_x = camera_get_view_x(view_camera[0]);

// Calculate the horizontal offset for each layer based on the camera's movement and
// each layer's scroll speed multiplier.
var _bg_1_x_offset = _camera_x * bg_1_scroll_speed;
var _bg_2_x_offset = _camera_x * bg_2_scroll_speed;
var _bg_3_x_offset = _camera_x * bg_3_scroll_speed;

// Apply the calculated offset to each layer.
layer_x("Background_1", _bg_1_x_offset);
layer_x("Background_2", _bg_2_x_offset);
layer_x("Background_3", _bg_3_x_offset);
#endregion