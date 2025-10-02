/// @description Handles the player's attack state.
/// @arg {bool} _on_ground Is the player currently on the ground?
function scr_player_state_attack(_on_ground) {
    // --- On-Entry Logic (first frame of the ATTACK state) ---
    // This code runs only once when the player transitions into the ATTACK state.
    if (player_state_previous != PlayerState.ATTACK) {
        
        // Set sprites
        if (!_on_ground) {
        	sprite_index = sPlayerAirAttack;
        } else {
            sprite_index = sPlayerAttack;
        }
        
        // Play attack sound
        audio_play_sound(sndPlayerAttack, 10, false); 
        
        // Create the attack slash object
        // Position it relative to the player, slightly in front based on facing_direction
        // Pass the player's variable into the function
        var _total_x_offset = scr_get_offset(sPlayerAttack, sPlayerAttackSlash, -32);
        var _slash_x = x + facing_direction * _total_x_offset;
        current_attack_slash = instance_create_layer(_slash_x, y, "ilMiddle", oPlayerAttackSlash);
        
        if (instance_exists(current_attack_slash)) {
            current_attack_slash.owner = id; // Set the owner to this player instance
            current_attack_slash.image_xscale = facing_direction; // Match player's direction
        }
        attack_timer = attack_duration; // Start attack timer
    }
 
    // --- Per-Frame Logic (while in ATTACK state) ---
    // If on ground, disable horizontal movement. If in air, maintain current hsp (handled by Step_0's default physics).
    if (_on_ground) {
        hsp = 0; // Temporarily disable horizontal movement when attacking on the ground
    }
    // vsp is handled by gravity in oPlayer's Step_0.gml
 
    // When attack animation is over
    if (attack_timer <= 0) {

 
        // Transition back to an appropriate state based on whether the player is on the ground
        if (_on_ground) {
            // After a ground attack, revert to IDLE since hsp was forced to 0.
            player_state = PlayerState.IDLE;
        } else { // If not on ground, go to AIR
            player_state = PlayerState.AIR;
        }
    }
}