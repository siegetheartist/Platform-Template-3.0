// Inherit the parent event
event_inherited();

#region COLLISION EVENT with oPlayer
// The collision event already guarantees that the 'other' instance is a player.
// Check if the game manager exists before trying to access it.
if (instance_exists(oGameManager)) {
    // Increment the crystal count on the dedicated game manager object.
    oGameManager.crystals_collected++;
    
    // Check if enough crystals have been collected for an extra life.
    if (oGameManager.crystals_collected >= oGameManager.max_crystals_for_life) {
        // Award the player an extra life.
        oGameManager.player_lives++;
        
        // Reset the crystal count.
        oGameManager.crystals_collected = 0;
        
        // Play a level-up sound.
        audio_play_sound(sndLevelUp, 1, false);
    } else {
        // Play a crystal pickup sound.
        audio_play_sound(sndCrystalPickup, 1, false);
    }
}
    
// Destroy the crystal instance that was just collected.
instance_destroy();
#endregion