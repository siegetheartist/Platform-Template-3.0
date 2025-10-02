// Update position and direction relative to the player
// This ensures the slash stays with the player if they move (though player movement is frozen during attack)
if (instance_exists(owner)) {
    // Match the offset used in oPlayer's Step event for creating the slash
    // Calculate the total offset from the player's center to the slash's center
    // This ensures the slash's edge is a consistent distance from the player's edge.
    var _total_x_offset = scr_get_offset(sPlayerAttack, sPlayerAttackSlash, -32); // Must match players offset (in scr_player_state_attack)
    x = owner.x + owner.facing_direction * _total_x_offset;
    y = owner.y; // Keep vertical position synced
    image_xscale = owner.facing_direction; // Keep direction synced with player
} 
