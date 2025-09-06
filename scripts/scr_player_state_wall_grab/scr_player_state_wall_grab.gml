/// @description Handles the player's brief wall grab state.
/// @arg {real} _on_wall The wall direction (-1 left, 1 right).
/// @arg {boolean} _is_pressing_wall Is the player actively pressing into a wall?
/// @arg {boolean} _key_jump Is the jump key pressed this frame?

function scr_player_state_wall_grab(_on_wall, _is_pressing_wall, _key_jump) {
    // Set sprite and stop all movement for the duration of the grab.
    sprite_index = sPlayerOnWall;
    image_speed = 0;
    image_xscale = -_on_wall;
    hsp = 0;
    vsp = 0;

    // Check for a jump input. A wall jump can be performed from a grab.
    if (_key_jump) {
        scr_player_wall_jump(_on_wall);
    }

    // Check if the player has let go of the directional input.
    if (!_is_pressing_wall) {
        // If they've let go, immediately transition to AIR.
        player_state = PlayerState.AIR;
    } else {
        // Otherwise, continue the grab.
        wall_grab_timer++;

        // Once the timer runs out, transition to the wall slide state.
        if (wall_grab_timer >= wall_grab_timer_max) {
            player_state = PlayerState.WALL_SLIDE;
        }
    }
}