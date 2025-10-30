/// @function scr_move_and_collide(collision_map)
/// @param collision_map    The collision object/tilemap to check against.
/// @description Moves the instance horizontally and vertically, handling collisions with solids and basic slopes.

function scr_move_and_collide2(_collision_map) {
    
    var _sub_pixel = 0.5; // Controls precision for pixel-by-pixel movement
    var _max_step_height = 4; // Maximum height in pixels the entity can step up automatically

    #region HORIZONTAL MOVEMENT & COLLISION
    
    // --- Check intended horizontal position for collision ---
    if (!place_meeting(x + x_speed, y, _collision_map)) {
        // Path is clear, commit full horizontal movement
        x += x_speed;
    } else {
        // Collision detected at intended position
        
        // --- Check for Upward Slope/Step ---
        // Check if it's possible to move UPWARDS slightly at the CURRENT x to clear an obstacle,
        // AND if the destination x is clear after moving up that amount.
        var _can_step_up = false;
        for (var i = 1; i <= _max_step_height; i++) {
            // Is it clear slightly above the current position?
            // AND Is it clear slightly above the *intended* position?
            if (!place_meeting(x, y - i, _collision_map) && 
                !place_meeting(x + x_speed, y - i, _collision_map)) 
            {
                // Found a height we can step up to!
                // Move vertically pixel-by-pixel until just below the step height
                while (place_meeting(x + x_speed, y - _sub_pixel, _collision_map) && y > bbox_top - i) {
                     y -= _sub_pixel;
                }
                 y = ceil(y); // Snap y position after adjustments
                _can_step_up = true;
                break; // Exit the loop once a valid step height is found and adjusted
            }
        }

        // If we successfully stepped up, allow horizontal movement
        if (_can_step_up) {
            x += x_speed; 
        } else {
            // --- Wall Collision (Cannot step up) ---
            // Move pixel-by-pixel horizontally until collision
            var _x_pixel_step = _sub_pixel * sign(x_speed);
            while (!place_meeting(x + _x_pixel_step, y, _collision_map)) {
                x += _x_pixel_step;
            }
            x_speed = 0; // Stop horizontal movement
        }
    }

    // --- Clamp horizontal position to room bounds ---
    // Note: Assumes origin is centered in mask. Adjust if needed.
    var _half_mask_width = (bbox_right - bbox_left) / 2;
    x = clamp(x, _half_mask_width, room_width - _half_mask_width);

    #endregion // End of HORIZONTAL


    #region VERTICAL MOVEMENT & COLLISION
    
    // --- Move vertically until collision ---
    if (place_meeting(x, y + y_speed, _collision_map)) {
        var _y_pixel_step = _sub_pixel * sign(y_speed);
        while (!place_meeting(x, y + _y_pixel_step, _collision_map)) {
            y += _y_pixel_step;
        }
         // Optional: Consider adding ground check logic here if needed specifically for enemies
        // if (y_speed >= 0) { on_ground = true; /* reset enemy jump counts etc */ } 
        y_speed = 0; // Stop vertical movement
    }
    
    // --- Commit Vertical Movement ---
    y += y_speed;

    // --- Downward Slope Snapping (Optional - Better placed after vertical) ---
    // If needed, downward slope logic could go here, checking if grounded after vertical checks.
    // Example (requires on_ground variable for enemy):
    /*
    if (on_ground && x_speed != 0) { // Only snap if grounded and moving horizontally
        var _max_snap_down = 4; // Max distance to snap down
        if (!place_meeting(x, y + 1, _collision_map)) { // Check if slightly above ground
             // Check further down to confirm slope
            if (place_meeting(x, y + _max_snap_down + 1, _collision_map)) { 
                while (!place_meeting(x, y + _sub_pixel, _collision_map)) {
                    y += _sub_pixel;
                }
            }
        }
    }
    */

    #endregion // End of VERTICAL
}
