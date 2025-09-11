/// @description Handles the player's attack state.
/// @arg {bool} _on_ground Is the player currently on the ground?
function scr_player_state_attack(_on_ground) {
    // --- On-Entry Logic (first frame of the ATTACK state) ---
    // This code runs only once when the player transitions into the ATTACK state.
    if (player_state_previous != PlayerState.ATTACK) {
        sprite_index = sPlayerAttack;
        image_index = 0; // Reset animation frame
        image_speed = 1; // Start animation
 
        audio_play_sound(sndPlayerAttack, 10, false); // Play attack sound (assuming sndPlayerAttack exists)
        
        // Create the attack slash object
        // Position it relative to the player, slightly in front based on facing_direction
        var _player_half_width = sprite_width / 2;
        var _slash_half_width = sprite_get_width(sPlayerAttackSlash) / 2; // Get the width of the slash sprite itself
        var _desired_gap = 8; // The distance between the player's edge and the slash's edge
        var _total_x_offset = _player_half_width + _desired_gap + _slash_half_width;
        
        var _slash_x = x + facing_direction * _total_x_offset;
        current_attack_slash = instance_create_layer(_slash_x, y, "l_Player", oPlayerAttackSlash);
        if (instance_exists(current_attack_slash)) {
            current_attack_slash.owner = id; // Set the owner to this player instance
            current_attack_slash.image_xscale = facing_direction; // Match player's direction
        }
        attack_timer = attack_duration; // Start attack timer
    }
 
    // --- Per-Frame Logic (while in ATTACK state) ---
    // The attack_timer is decremented in oPlayer's Step_0.gml
    
    // When attack animation is over
    if (attack_timer <= 0) {
        // Destroy the slash object if it still exists (should be handled by slash object itself but good failsafe)
        if (instance_exists(current_attack_slash)) {
            instance_destroy(current_attack_slash);
            current_attack_slash = noone;
        }
 
        // Transition back to an appropriate state based on whether the player is on the ground
        if (_on_ground) {
            if (abs(hsp) > 0.1) { // If player has residual horizontal movement, go to RUN (or a minimum speed)
                player_state = PlayerState.RUN;
            } else { // Otherwise, go to IDLE
                player_state = PlayerState.IDLE;
            }
        } else { // If not on ground, go to AIR
            player_state = PlayerState.AIR;
        }
    }
}