// Set listener for 3D sounds. Necessary for Spike trap emmitters to work
if (instance_exists(oPlayer)) {
    // This tells the audio engine where the "ears" are.
    audio_listener_position(oPlayer.x, oPlayer.y, 0);
}


// Add this timer to the top of your Step Event, before the other regions.
if (respawn_grace_period > 0) {
    respawn_grace_period--;
}


#region START SCREEN
// If we are in the start screen room, run the title screen script.
if (room == r_start_screen) {
    scr_title_screen();
}
#endregion


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
        break;

    case GAME_STATE.FADE_COMPLETE:
        // The screen is black. Perform the queued action.
        switch (next_action) {
            case "respawn":
                //show_debug_message("Attempting respawn at: (" + string(global.checkpoint_x) + ", " + string(global.checkpoint_y) + ")");
    
                // Respawn logic
                var _old_player = instance_find(oPlayer, 0);
                if (_old_player) {
                    instance_destroy(_old_player);
                }
                
                // Create a new player instance at the last checkpoint's location.
                var _new_player = instance_create_layer(global.checkpoint_x, global.checkpoint_y, "il_player", oPlayer);
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
        // show_debug_message("State is now FADING_IN");
        // The screen is fading back in. Do nothing until fade is complete.
        break;
        
    case GAME_STATE.GAME_OVER:
        scr_game_over();
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