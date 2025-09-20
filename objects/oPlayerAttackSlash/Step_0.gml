// Decrement timer
timer--;
 
// Update position and direction relative to the player
// This ensures the slash stays with the player if they move (though player movement is frozen during attack)
if (instance_exists(owner)) {
    // Match the offset used in oPlayer's Step event for creating the slash
    // Calculate the total offset from the player's center to the slash's center
    // This ensures the slash's edge is a consistent distance from the player's edge.
    var _player_half_width = sprite_get_width(sPlayerAttack) / 2;
    var _slash_half_width = sprite_get_width(sPlayerAttackSlash) / 2; // 'sprite_width' here refers to oPlayerAttackSlash's own sprite_width
    var _desired_gap = -34 // The distance between the player's edge and the slash's edge
    var _total_x_offset = _player_half_width + _desired_gap + _slash_half_width;
    x = owner.x + owner.facing_direction * _total_x_offset;
    y = owner.y; // Keep vertical position synced
    image_xscale = owner.facing_direction; // Keep direction synced with player
} 
