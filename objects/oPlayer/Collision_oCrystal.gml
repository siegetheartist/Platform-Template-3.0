// --- Crystal Collection Logic ---
// This code is triggered when the player collides with a crystal.
// 'other' refers to the oCrystal instance that was just hit.

// Increment the crystal count via the player controller.
oPlayerController.crystals_collected++;

// Check if enough crystals have been collected for an extra life.
if (oPlayerController.crystals_collected >= oPlayerController.max_crystals_for_life) {
    // Award the player an extra life.
    oPlayerController.player_lives++;
    
    // Reset the crystal count.
    oPlayerController.crystals_collected = 0;
    
    // You can add a sound effect or a visual particle effect here.
}

// Destroy the crystal instance that was just collected.
instance_destroy(other);
