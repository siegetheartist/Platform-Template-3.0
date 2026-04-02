// This script handles the player's running state.

/// @description Handles the player's running state.
/// @arg {real} _dir The current horizontal input direction.
function scr_player_state_run(_dir) {
    // Set the sprite and image speed for the running state.
    sprite_index = sPlayerRun;
    image_speed = 1;

    // Check for a lack of horizontal input.
    if (_dir == 0) { // If no input, switch to the IDLE state.
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
        // NEW: Spawn dust cloud on the same frames as the step sounds
        scr_spawn_dust_cloud(x, y, facing_direction);
    }
}