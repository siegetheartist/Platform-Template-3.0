#region VISUALS
// --- Sprite Flipping Logic ---
// The WALL_SLIDE and WALL_GRAB states handle their own sprite flipping.
if (player_state != PlayerState.WALL_SLIDE && player_state != PlayerState.WALL_GRAB) {
    image_xscale = facing_direction;
}

// Offset the sprite to LOOK like it's snapped to the grid. DOES NOT CHANGE COLLISION MASK. Just the sprite. Purely visual.
// draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale, image_angle, c_white, 1);

// TODO: Remove drawing the instance again. Causes double instances with the offset above
// Draw visual damage flash-blinking indicator
scr_obj_flash_draw();
#endregion






