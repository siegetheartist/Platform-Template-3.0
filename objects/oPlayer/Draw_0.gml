#region VISUALS
// --- Sprite Flipping Logic ---
// The WALL_SLIDE and WALL_GRAB states handle their own sprite flipping.
if (player_state != PlayerState.WALL_SLIDE && player_state != PlayerState.WALL_GRAB) {
    image_xscale = facing_direction;
}

// --- Visual Damage Indicator (Blinking) ---
if (sprite_index != noone) {
    if (flash_timer > 0) {
        if (flash_timer mod 6 < 3) {
            draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
        } else {
            draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, 0);   
        }
    } else {
        draw_self();   
    }
} else {
    show_debug_message("ERROR: Player sprite is not a valid asset!");
}
#endregion