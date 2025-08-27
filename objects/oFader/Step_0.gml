// Events -> Add Event -> Step -> Step

// --- FADING LOGIC ---
if (fader_mode == "fade_in") {
    // Fade in by reducing the alpha.
    alpha = max(alpha - fade_speed, 0);

    // If the fade is complete, destroy the object and restore player control.
    if (alpha <= 0) {
        instance_destroy();
        with (oPlayer) {
            can_control = true;
        }
    }
}

if (fader_mode == "next_level") {
    // Fade out by increasing the alpha.
    alpha = min(alpha + fade_speed, 1);

    // When the screen is black, go to the next room.
    if (alpha >= 1) {
        room_goto_next();
    }
}

if (fader_mode == "respawn") {
    // Fade out by increasing the alpha.
    alpha = min(alpha + fade_speed, 1);

    // When the screen is black, respawn the player at the last checkpoint.
    if (alpha >= 1) {
        // Find the player object and destroy it.
        // This makes sure the old instance is gone before the new one is created.
        with (oPlayer) {
            instance_destroy();
        }

        // Now, create a new player instance at the last checkpoint's location.
        var _new_player = instance_create_layer(global.checkpoint_x, global.checkpoint_y, "l_Player", oPlayer);
        
        // Disable the new player's control until the fade-in is complete.
        _new_player.can_control = false;
        
        // Reset all enemies to their starting positions and states.
        with (oEnemy) {
            x = start_x;
            y = start_y;
            hsp = 0; // Stop any current movement
            vsp = 0; // Stop falling/jumping
            enemy_state = ENEMY_STATE.PATROL; // Reset to default state
        }

        // Change the fader mode to fade back in.
        fader_mode = "fade_in";
    }
}