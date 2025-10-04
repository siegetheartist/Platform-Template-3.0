// Set listener for 3D sounds. Necessary for Spike trap emmitters to work
if (instance_exists(oPlayer)) {
    // This tells the audio engine where the "ears" are.
    audio_listener_position(oPlayer.x, oPlayer.y, 0);
}


// A timer to briefly prevent death checks after respawn.
if (respawn_grace_period > 0) {
    respawn_grace_period--;
}



#region GAME STATE MACHINE
switch (current_state) {
    case GAME_STATE.IDLE:
        // Everything is running normally.
        break;

    case GAME_STATE.FADING_OUT:
        // The screen is fading to black.
        // Step 1: If a fader doesn't exist, create one.
        if (!instance_exists(objFader)) {
        scr_fader("fade-out", 50);
        }
    
        // Step 2: Once fade-out is complete, move to FADE_COMPLETE
        if (instance_exists(objFader) && objFader.is_complete) {
            current_state = GAME_STATE.FADE_COMPLETE;
        }
    break;

    case GAME_STATE.FADE_COMPLETE:
        // The screen is black. Perform the queued action.
        switch (next_action) {
            case "respawn":
    
                /*
                // Respawn logic
                var _old_player = instance_find(oPlayer, 0);
                if (_old_player) {
                    instance_destroy(_old_player);
                }
                */         
    
                // Create a new player instance at the last checkpoint's location.
                var _new_player = instance_create_layer(global.checkpoint_x, global.checkpoint_y, "ilMiddle", oPlayer);
                _new_player.can_control = false;
                _new_player.player_health = max_player_health; // Reset health
                _new_player.player_state = PlayerState.IDLE; // Reset the state
    
    
                // Reset health for all enemies that are marked to be reset
                with (oEnemy) {
                    // Only run this code if the variable is true
                    if (reset_on_respawn) {
                        enemy_health = max_enemy_health;
                        flash_timer = 0;
                        knockback_active = false;
                        knockback_duration_timer = 0;
                        knockback_cooldown_timer = 0;
                        enemy_state = ENEMY_STATE.PATROL;
                        enemy_state_previous = ENEMY_STATE.PATROL;
                        sound_played_for_current_state = false;
                        hsp = 0;
                        vsp = 0;
                        x = start_x;
                        y = start_y;
                        current_dir = 1;
                        taunt_timer = 0;
                        alert_timer = 0;
                    }
                }
                
                // Set a grace period to prevent immediate death
                respawn_grace_period = 60; // 10 frames of invulnerability
    
                // After respawning, immediately start fading back in
                current_state = GAME_STATE.FADING_IN;
                next_action = ""; // Clear the action

            break;
               
            case "next_level":
                next_action = ""; // Clear the action
                if (room != room_last) {
                    room_goto_next();
                } else {
                    // This is the last room, so trigger a game over
                    next_action = "game_over";
                    current_state = GAME_STATE.FADING_IN; // Go to FADING_IN to reveal game over screen
                }
                break;
            
            case "previous_level":
                next_action = ""; // Clear the action
                
                if (room != room_first) {
                    room_goto_previous();
                }
                break;
            
            case "game_over":
                // Show game over UI
                layer_set_visible("Layer_Game_over", true);
    
                selected_button = 0; // Default to "Try Again"
    
                // Also go to FADING_IN so the Game Over screen is revealed
                current_state = GAME_STATE.FADING_IN;
            break;
        }
    
        // Re-initialize the existing fader to perform a fade-in.
        if (instance_exists(objFader)) {
            with (objFader) {
                fade_mode   = "fade-in";
                fade_speed  = fade_target / 30;
                fade_alpha  = fade_target; // Start fully opaque (e.g., 1)
                is_complete = false;
            }
        }
        
        // Transition to FADING_IN state (if not already set by a case above)
        if (current_state != GAME_STATE.FADING_IN) { // should this be == GAME_STATE.FADING_COMPLETE ?
            current_state = GAME_STATE.FADING_IN;
        }

    break;

    case GAME_STATE.FADING_IN:
        // Step 1: If a fader doesn't exist, create one. This makes the state self-sufficient.
        if (!instance_exists(objFader)) {
            scr_fader("fade-in", 30);
        }

        // Step 2: Wait for the fade-in to complete
        if (instance_exists(objFader) && objFader.is_complete) {
            instance_destroy(objFader); // Clean up the fader

            if (next_action == "game_over") {
                current_state = GAME_STATE.GAME_OVER;
                next_action = "";
            } else {
                // Transition to normal gameplay
                current_state = GAME_STATE.IDLE;

                // Give control back to the player
                if (instance_exists(oPlayer) && room != rStartScreen) {
                    oPlayer.can_control = true;
                }
            }
        }
    break;

    case GAME_STATE.GAME_OVER:
        scr_game_over();
    break;
}
#endregion


// PARALLAX SCROLLING
scr_parallax_scrolling(view_camera[0], "Background_1", 0.08, "Background_2", 0.06, "Background_3", 0.02);
