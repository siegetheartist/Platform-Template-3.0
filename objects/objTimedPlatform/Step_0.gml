/// @description Timed platform state logic
scr_shake(id);

// Run code based on the current state
switch (state) {
    // --- IDLE STATE ---
    // The platform is solid and waiting for the player.
    case PLATFORM_STATE.IDLE:
        // Check if the player instance exists and is landing on top of the platform.
        // We check 'vsp >= 0' to ensure the player is falling onto it, not jumping up through it.
        if (instance_exists(oPlayer) && place_meeting(x, y - 1, oPlayer) && oPlayer.vsp >= 0) {
            // If the player is on top, start the breaking sequence.
            state = PLATFORM_STATE.BREAKING;
            audio_play_sound_on(platform_emitter, sndRockCrackandBreak, false, 1);
        }
        break;

    // --- BREAKING STATE ---
    // The player is on the platform, and it's starting to crumble.
    case PLATFORM_STATE.BREAKING:
        // Countdown the timer.
        break_timer--;

        // Change the sprite frame based on how much time is left.
        if (break_timer <= 0) {
            
            // Timer is up! Break the platform.
            image_index = 3; // Show the final break frame
            state = PLATFORM_STATE.BROKEN;
            visible = false; // Make it disappear
            mask_index = sprNoCollision; // Disable collisions

        } else if (break_timer <= 20) {
            image_index = 2; // Second break frame
            
        } else if (break_timer <= 40) {
            image_index = 1; // First break frame
            
            // Start shaking once when entering this phase 
            if (!is_shaking) {
                scr_shake_initialize(id, 3, 40, true);
            }
        }
        break;

    // --- BROKEN STATE ---
    // The platform is gone and waiting to respawn.
    case PLATFORM_STATE.BROKEN:
        // Countdown the respawn timer.
        respawn_timer--;

        // When the timer reaches zero, reset the platform.
        if (respawn_timer <= 0) {
            state = PLATFORM_STATE.IDLE;
            visible = true; // Make it reappear
            mask_index = original_mask; // Re-enable collisions
            image_index = 0; // Reset to the default sprite
            break_timer = break_timer_max; // Reset the break timer
            respawn_timer = respawn_timer_max; // Reset the respawn timer
        }
        break;
}