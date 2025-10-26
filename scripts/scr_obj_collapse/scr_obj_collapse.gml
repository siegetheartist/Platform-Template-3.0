/// @function scr_obj_collapse(time_before_collapse, respawn_time, break_sound);
/// @description Manages the state machine for a timed, collapsing, and respawning object.
/// @param {Real} time_before_collapse   The delay in frames before the breaking animation starts.
/// @param {Real} respawn_time           The time in frames for the object to respawn.
/// @param {Asset.GMSound} break_sound   The sound to play when the object starts breaking.

function scr_obj_collapse(time_before_collapse, respawn_time, break_sound) {
    
    // -- State Definitions --
    // 0 = IDLE, 1 = TRIGGERED, 2 = BREAKING, 3 = BROKEN
    
    // One-time initialization for the state machine variables.
    if (!variable_instance_exists(id, "collapse_state_initialized")) {
        state = 0; // IDLE
        break_timer = time_before_collapse;
        respawn_timer = respawn_time;
        original_mask = mask_index; // Store the valid collision mask
        collapse_state_initialized = true;
    }

    // --- State Machine Logic ---
    switch (state) {
        
        case 0: // IDLE
            image_speed = 0;
            image_index = 0;
            visible = true;
            mask_index = original_mask; // Ensure it has the correct mask
            
            if (instance_exists(oPlayer) && place_meeting(x, y - 1, oPlayer) && oPlayer.y_speed >= 0) {
                state = 1; // TRIGGERED
                break_timer = time_before_collapse;
            }
            break;
        
        case 1: // TRIGGERED
            break_timer--;
            if (break_timer <= 0) {
                state = 2; // BREAKING
                image_speed = 1; 
                
                if (variable_instance_exists(id, "platform_emitter")) {
                    audio_play_sound_on(platform_emitter, break_sound, false, 1);
                } else {
                    audio_play_sound(break_sound, 1, false);
                }
            }
            break;
            
        case 2: // BREAKING
            if (image_index >= image_number - 1) {
                state = 3; // BROKEN
                visible = false;
                mask_index = sprNoCollision; // Set mask to non-collidable
            }
            break;
            
        case 3: // BROKEN
            respawn_timer--;
            if (respawn_timer <= 0) {
                
                // Temporarily assign the original mask to check for the player
                var _old_mask = mask_index;
                mask_index = original_mask;
                var _player_in_the_way = place_meeting(x, y, oPlayer);
                mask_index = _old_mask; // Instantly change it back

                // Only respawn if the player is not in the way
                if (!_player_in_the_way) {
                    state = 0; // Back to IDLE
                    respawn_timer = respawn_time; 
                }
            }
            break;
    }
}