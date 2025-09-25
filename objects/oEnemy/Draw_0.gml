//  Enemy Parent Drawing Logic 

#region DEFAULT DRAWING
// --- Visual Damage Indicator (Blinking) --- 
if (sprite_index != noone) {
	if (flash_timer > 0) {
		if (flash_timer mod 6 < 3) { // Blink every 3 frames
			draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
		} else {
			draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, 0); // Transparent
		}
	} else {
		draw_self(); // Draws the sprite assigned to the instance's sprite_index
	}
} else {
	show_debug_message("ERROR: Enemy sprite is not a valid asset!");
}
#endregion

#region ALARM INDICATOR DRAWING
// Only draw the exclamation mark if the enemy is in ALERT or CHASE state
if (enemy_state == ENEMY_STATE.ALERT) { // || enemy_state == ENEMY_STATE.CHASE
    // Check if the exclamation sprite has been assigned by a child
    if (exclamation_sprite != -1) {
        var _draw_color = c_white; // Default color for the exclamation mark

        // Set color based on state
        if (enemy_state == ENEMY_STATE.ALERT) {
            _draw_color = c_yellow; // Yellow for alert state
        } // else if (enemy_state == ENEMY_STATE.CHASE) {
            // _draw_color = c_red;    // Red for chase state
        // }
        
        // Draw the exclamation sprite above the enemy's head
        // Adjust the Y offset (-sprite_height - 10) to position it correctly above your enemy sprite
        draw_sprite_ext(
            exclamation_sprite,     // The sprite to draw (set by child)
            0,                      // Sub-image (if animated, adjust this in child or Draw event)
            x,                      // X position
            y - sprite_height - 10, // Y position (adjust offset as needed)
            1,                      // X scale
            1,                      // Y scale
            0,                      // Rotation (0 for no rotation)
            _draw_color,            // Color blend (dynamically set)
            1                       // Alpha (opacity)
        );
    }
}
#endregion
