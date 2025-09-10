/// @description Executes a jump, handling the impulse, sounds, and combo logic.
/// @arg {string} _jump_type The type of jump ("ground" or "wall").
/// @arg {real} [_wall_dir] Optional. The direction of the wall (-1 or 1) for a wall jump.
function scr_player_jump(_jump_type, _wall_dir=0) {
	
    
	#region	JUMP SOUNDS
    /// Play the correct jump sound based on the player's consecutive jumps and manages the jump combo.
    consecutive_jumps++;
    jump_combo_timer = jump_combo_timeout;
    var _jump_sound_to_play = sndPlayerJump; // Default to the first sound.
    switch (consecutive_jumps) {
        case 1:
            _jump_sound_to_play = sndPlayerJump;
            break;
        case 2:
            _jump_sound_to_play = sndPlayerJump02;
            break;
        case 3:
            _jump_sound_to_play = sndPlayerJump03;
            break;
        default:
            // After the third jump, loop back to the first sound.
            _jump_sound_to_play = sndPlayerJump;
            consecutive_jumps = 1;
            break;
    }
    audio_play_sound(_jump_sound_to_play, 10, false);
	#endregion
    
    
    #region JUMP LOGIC
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
            // After a wall jump, we transition to the AIR state and horizontal move loss.
            wall_jump_move_loss = wall_jump_move_loss_max;
            player_state = PlayerState.AIR;
            break;
    }
    #endregion
    
    
}