// Manages fading animation.
if (fader_mode == "fade_in") {
    // Fade in by reducing the alpha.
    alpha = max(alpha - fade_speed, 0);

    // If the fade is complete, destroy the object and restore player control.
    if (alpha <= 0) {
        if (instance_exists(oGameManager)) {
            oGameManager.current_state = GAME_STATE.IDLE;
        }
        
    // Only give control back to the player if we are NOT in the start menu.
    if (room != r_start_screen) {
        if (instance_exists(oPlayer)) {
            oPlayer.can_control = true;
        }
    }
        instance_destroy();
    }
}

if (fader_mode == "fade_out") {
    // Fade out by increasing the alpha.
    alpha = min(alpha + fade_speed, 1);

    // If the fade is complete, tell the game manager that the screen is black.
    if (alpha >= 1) {
        if (instance_exists(oGameManager)) {
            oGameManager.current_state = GAME_STATE.FADE_COMPLETE;
        }
        // Destroy the fader instance so a new one can be created for the fade-in.
        instance_destroy();
    }
}