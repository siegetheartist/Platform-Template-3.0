/// @description Handles the player's idle state.
/// @arg {real} _dir The current horizontal input direction.
/// @arg {boolean} _key_jump Is the jump key pressed this frame?

function scr_player_state_idle(_dir, _key_jump) {
    // Set the sprite and image speed for the idle state.
    sprite_index = sPlayerIdle;
    image_speed = 0;

    // Check for horizontal input. If present, switch to the RUN state.
    if (_dir != 0) {
        player_state = PlayerState.RUN;
    }

    // Check for jump input. A ground jump should always be allowed.
    // We pass in the current jump input and the fact that we are on the ground.
	if (scr_player_jump_input(_key_jump, true)) {
	    player_state = PlayerState.AIR;
	}
}