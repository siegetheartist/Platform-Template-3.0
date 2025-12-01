function floating_to_integer() {
    // Snap to the grid to remove floating point gaps
    if(_x_pixel_step > 0) {
        // Moving right to the nearest grid pixel integer
        x = ceil(x); 
    } else {
        // Moving left to the nearest grid pixel integer
        x = floor(x);
    }
    
    
    
    
    
    
    
    
    // --- Flush out of wall to prevent wall-edge clipping (bandaid fix) --- 
// TODO: Fix floating point collisions so we can remove this
if (on_wall != 0) {
    while (place_meeting(x, y, collision_tileset)) {
        x -= _sub_pixel * on_wall; // push out opposite the wall direction
    }
}
    
}
