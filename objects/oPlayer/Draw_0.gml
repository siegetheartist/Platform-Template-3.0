// --- Player Drawing Logic ---

#region DEFAULT DRAWING
// --- Visual Damage Indicator (Blinking) ---
// Only apply the blinking effect if the flash_timer is active
if (flash_timer > 0) {
    // Make the player blink white.
    // We'll use a simple modulo operation to make it flash on/off.
    // Adjust '6' for faster/slower blinking (lower number = faster blink).
    if (flash_timer mod 6 < 3) { // Blinks every 3 frames (on for 3, off for 3)
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
    } else {
        // Draw with current sprite's alpha (effectively invisible for a moment)
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, 0); 
    }
} else {
    // If not flashing, draw the player normally
    draw_self(); 
}
#endregion
