// This script handles the player's idle state.

/// @description Handles the player's idle state.
/// @arg {real} _dir The current horizontal input direction.
function scr_player_state_idle(_dir) {
    // Set the sprite and image speed for the idle state.
    sprite_index = sPlayerIdle;
    image_speed = 1;

    // Check for horizontal input. If present, switch to the RUN state.
    if (_dir != 0) {
        player_state = PlayerState.RUN;
    }
}