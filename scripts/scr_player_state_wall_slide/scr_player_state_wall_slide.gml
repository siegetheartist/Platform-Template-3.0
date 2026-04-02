/// @description Handles the player's wall sliding state.
/// @arg {real} _on_wall The wall direction (-1 for left, 1 for right).
/// @arg {boolean} _is_touching_wall Is the player touching a wall?
/// @arg {boolean} _is_pressing_wall Is the player actively pressing into a wall?
/// @arg {boolean} _key_jump Is the jump key pressed this frame?

function scr_player_state_wall_slide(_on_wall, _is_touching_wall, _is_pressing_wall, _key_jump) {
    
    // Play wall slide sound
    if (player_state == PlayerState.WALL_SLIDE) {
        if (!audio_is_playing(sndPlayerWallSlide)) {
            audio_play_sound(sndPlayerWallSlide, 10, false);
        }
    } else if (audio_is_playing(sndPlayerWallSlide)) {
        audio_stop_sound(sndPlayerWallSlide);
    }

    // Set the sprite and image speed for the wall slide state.
    sprite_index = sPlayerOnWall;
    image_speed = 1;
    image_xscale = -_on_wall;

    // Apply reduced gravity for wall sliding.
    vsp = clamp(vsp + grav_wall, 0, grav_max_wall);

    // Stop horizontal movement.
    hsp = 0;

    // Check if the player has left the wall.
    // The player should only transition out of this state if they stop pressing the input key.
    if (!_is_pressing_wall) {
        player_state = PlayerState.AIR;
    }

    // Check for wall jump input.
    if (_key_jump) {
        scr_player_jump("wall", _on_wall);
    }
    
    // Dust cloud spawning
    wall_slide_dust_timer++;
    if (wall_slide_dust_timer >= wall_slide_dust_timer_max) {
        wall_slide_dust_timer = 0;
        scr_spawn_dust_cloud(x, y, -_on_wall, _on_wall);
    }
}

