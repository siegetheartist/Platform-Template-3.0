// Set listener for 3D sounds. Necessary for Spike trap emmitters to work
if (instance_exists(oPlayer)) {
    // This tells the audio engine where the "ears" are.
    audio_listener_position(oPlayer.x, oPlayer.y, 0);
}


// Add this timer to the top of your Step Event, before the other regions.
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
        scr_fader("fade-out", 60);
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
    
    
                // Reset health for all enemies
                with (oEnemy) {
                    enemy_health = max_enemy_health;
                    flash_timer = 0; // Stop any flashing effect
                    knockback_active = false; // Stop any active knockback
                    knockback_duration_timer = 0; // Reset knockback duration
                    knockback_cooldown_timer = 0; // Reset knockback cooldown
                    // Optionally reset enemy_state to PATROL or initial state:
                    enemy_state = ENEMY_STATE.PATROL;
                    enemy_state_previous = ENEMY_STATE.PATROL;
                    sound_played_for_current_state = false;
                    hsp = 0;
                    vsp = 0;
                    x = start_x; // Reset position to start_x
                    y = start_y; // Reset position to start_y
                    current_dir = 1; // Reset direction to default (e.g., right)
                    taunt_timer = 0; // Reset taunt timer
                    alert_timer = 0; // Reset alert timer
                }
                
                // Set a grace period to prevent immediate death
                respawn_grace_period = 60; // 10 frames of invulnerability
                
                // Immediately start fading back in
                // scr_fader("fade-in", 60);
    
                current_state = GAME_STATE.FADING_IN;
                next_action = ""; // Clear the action so it doesn't run again
                break;
               
            case "next_level":
                // Next level logic
                if (room != room_last) {
                    room_goto_next();
                } else {
                    // This is the last room, so trigger a game over or end screen.
                    next_action = "game_over";
                    //scr_fader("fade_out");
                }
                break;
            
            case "game_over":
                // Game over logic (Permanent)
                layer_set_visible("Layer_Game_over", true);
                selected_button = 0; // Default to "Try Again"
    
                // Also go to FADING_IN so the Game Over screen is revealed
                current_state = GAME_STATE.FADING_IN;
                break;
        }
        break;

    case GAME_STATE.FADING_IN:
        // If no fader exists yet, create one
        if (!instance_exists(objFader) || objFader.fade_mode != "fade-in") {
            scr_fader("fade-in", 60);
        }
    
        // Wait until fade-in is complete
        if (instance_exists(objFader) && objFader.is_complete) {
            instance_destroy(objFader);
    
            if (next_action == "game_over") {
                current_state = GAME_STATE.GAME_OVER;
                next_action = "";
            } else {
                current_state = GAME_STATE.IDLE;
    
                // Give control back to the player
                var _new_player = instance_find(oPlayer, 0);
                if (_new_player) {
                    _new_player.can_control = true;
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
