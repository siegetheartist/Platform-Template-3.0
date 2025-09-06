/// @description Executes a jump, handling the impulse, sounds, and combo logic.
/// @arg {string} _jump_type The type of jump ("ground" or "wall").
/// @arg {real} [_wall_dir] Optional. The direction of the wall (-1 or 1) for a wall jump.
function scr_player_jump(_jump_type, _wall_dir=0) {
    // Play the jump sound and handle the combo logic.
    scr_player_jump_sound();
    
    // Apply the correct jump impulse based on the jump type.
    switch (_jump_type) {
        case "ground":
            vsp = jump_height;
            // Since this is a ground jump, we reset coyote time.
            coyote_time = coyote_time_max;
            // After a ground jump, we transition to the AIR state.
            player_state = PlayerState.AIR;
            break;
        case "wall":
            // The wall jump impulse needs to be handled here.
            vsp = jump_height_wall - 2;
            hsp = -_wall_dir * wall_jump_distance;
            // After a wall jump, we suppress gravity to prevent an immediate re-grab.
            wall_jump_gravity_bypass = wall_jump_gravity_bypass_max;
            // After a wall jump, we transition to the AIR state and start the input lockout.
            wall_jump_delay = wall_jump_delay_max;
            player_state = PlayerState.AIR;
            break;
    }
}