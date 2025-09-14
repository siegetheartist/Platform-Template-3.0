/// @description Handles the player's airborne (jumping/falling) state.
/// @arg {boolean} _key_jump_held Is the jump key being held down?
/// @arg {real} _on_wall The wall direction (-1 left, 1 right).
/// @arg {boolean} _is_touching_wall Is the player touching a wall?
/// @arg {boolean} _is_pressing_wall Is the player actively pressing into a wall?
/// @arg {real} _dir The current horizontal input direction.

function scr_player_state_air(_key_jump_held, _on_wall, _is_touching_wall, _is_pressing_wall, _dir) {
    // Set the sprite and image speed for the airborne state.
    sprite_index = sPlayerInAir;
    image_speed = 0;
    image_index = (vsp < 0) ? 0 : 1; // Show first frame for ascent, second for descent

    // Check if the player can transition to the wall grab state.
    if (_is_touching_wall && _is_pressing_wall && vsp > 0 && wall_jump_gravity_bypass <= 0) {
        player_state = PlayerState.WALL_GRAB;
        wall_grab_timer = 0; // Reset the timer for the new grab
    }

    // Handle variable jump height.
    if (vsp < 0 && !_key_jump_held) {
        vsp = max(vsp, jump_height_min);
    }
}