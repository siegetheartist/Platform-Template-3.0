#region VISUALS
// --- Sprite Flipping Logic ---
// The WALL_SLIDE and WALL_GRAB states handle their own sprite flipping.
if (player_state != PlayerState.WALL_SLIDE && player_state != PlayerState.WALL_GRAB) {
    image_xscale = facing_direction;
}

scr_draw_self_flash();
#endregion






