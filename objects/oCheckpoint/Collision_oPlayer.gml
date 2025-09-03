// This is the collision event for oCheckpoint with oPlayer.
// 'other' refers to the oPlayer instance that collided with this checkpoint.

// Only run the activation logic if this checkpoint is not already active.
if (!is_active) {
    // Deactivate all other checkpoints. We'll iterate through all instances
    // of oCheckpoint and set their 'is_active' variable to false.
    with (oCheckpoint) {
        // We use 'other' here to refer back to the oCheckpoint instance
        // that initiated this collision. The 'id' check ensures we
        // don't deactivate the very checkpoint we're currently on.
        if (id != other.id) {
            is_active = false;
            sprite_index = s_Checkpoint_Inactive;
        }
    }

    // Now, activate this checkpoint.
    is_active = true;
    sprite_index = s_Checkpoint_Active;
    audio_play_sound(sndCheckpoint, 10, false);
    
    // Update the global checkpoint variables with a safe respawn position.
    // We add half the sprite width to the x-coordinate to ensure the player is
    // created in the center of the checkpoint sprite.
    global.checkpoint_x = x;
    global.checkpoint_y = y;
}