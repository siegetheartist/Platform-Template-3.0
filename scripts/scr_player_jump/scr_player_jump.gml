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
            // After a ground jump, we transition to the AIR state.
            player_state = PlayerState.AIR;
            break;
        case "wall":
            // The wall jump impulse needs to be handled here.
            vsp = wall_jump_height;
            hsp = -_wall_dir * wall_jump_horizontal_push_off;
            // After a wall jump, we suppress gravity to prevent an immediate re-grab.
            wall_jump_gravity_bypass = wall_jump_gravity_bypass_max;
            // After a wall jump, we transition to the AIR state and start the input lockout.
            wall_jump_temp_hor_loss = wall_jump_temp_hor_loss_max;
            player_state = PlayerState.AIR;
            break;
    }
}