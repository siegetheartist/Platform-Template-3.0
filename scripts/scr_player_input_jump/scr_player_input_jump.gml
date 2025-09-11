/// @description Checks for and executes a jump based on input and timers.
/// @arg {real} _key_jump Is the jump key pressed this frame?
/// @arg {bool} _on_ground Is the player on the ground?
function scr_player_input_jump(_key_jump, _on_ground) {
    
    // --- Jump Buffer Logic ---
    // If jump key is pressed while not on the ground, activate jump buffer
    if (_key_jump && !_on_ground) {
        jump_buffer = jump_buffer_max;
    }
    // Decrement jump buffer
    if (jump_buffer > 0) {
        jump_buffer--;
    }
 
    // --- Coyote Time Logic ---
    // If on ground, reset coyote time. Otherwise, decrement it.
    if (_on_ground) {
        coyote_time = coyote_time_max;
    } else {
        coyote_time--;
    }
	
    // A jump is allowed only if the player presses the jump key
	// AND is either on the ground, or has an active jump buffer,
	// or has an active coyote time.
	if ((_key_jump && (_on_ground || coyote_time > 0)) || (_on_ground && jump_buffer > 0)) {
	    scr_player_jump("ground");
	    // Reset both the jump buffer and coyote time after a successful jump.
	    jump_buffer = 0;
	    coyote_time = 0;
	    return true; // Return true to indicate a jump was performed.
	}

    return false; // No jump was performed.
}