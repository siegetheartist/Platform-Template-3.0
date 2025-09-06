/// @description Handles the player's running state.
/// @arg {real} _dir The current horizontal input direction.
/// @arg {boolean} _key_jump Is the jump key pressed this frame?

function scr_player_state_run(_dir, _key_jump) {
    // Set the sprite and image speed for the running state.
    sprite_index = sPlayerRun;
    image_speed = 1;

    // Apply horizontal acceleration based on input.
    hsp += _dir * accel;

    // Clamp horizontal speed within limits.
    hsp = clamp(hsp, -max_hsp, max_hsp);

    // Check for a lack of horizontal input. If no input, switch to the IDLE state.
    if (_dir == 0) {
        player_state = PlayerState.IDLE;
    }

    // Running sound logic: play the step sound at the beginning of animation frames 0 and 2.
    if ((floor(image_index) == 0 || floor(image_index) == 2) && (floor(image_index_previous) != floor(image_index))) {
        if (current_step_sound == 0) {
            audio_play_sound(sndPlayerStep01, 1, false);
            current_step_sound = 1; // Switch to the next sound
        } else {
            audio_play_sound(sndPlayerStep02, 1, false);
            current_step_sound = 0; // Switch back
        }
    }

    // We pass in the current jump input and the fact that we are on the ground.
	if (scr_player_jump_input(_key_jump, true)) {
	    player_state = PlayerState.AIR;
	}
}