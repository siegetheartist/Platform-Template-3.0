/// @function scr_move_and_collide(collision_map)
/// @param collision_map    An array or object to check for collisions against.
/// @description Moves the instance and handles collision with solids.

function scr_move_and_collide(_collision_map) {
    
    var _sub_pixel = .5;
    
    #region HORIZONTAL
    // --- Move horizontally until collision ---
    if (place_meeting(x + x_speed, y, _collision_map)) {
        
        // Handle upward slope movement
        // If there is collision to the sides, but not up and to sides, then there is a slope
        if (!place_meeting(x + x_speed, y - abs(x_speed) -1, _collision_map)) { 
        	while (place_meeting(x + x_speed, y, _collision_map)) {
            	y -= _sub_pixel;
            }
        } 
        
        // Normal movement (no slopes)
        else { 
        	var _x_pixel_step = _sub_pixel * sign(x_speed);
            while (!place_meeting(x + _x_pixel_step, y, _collision_map)) {
                x += _x_pixel_step;
            }
            x_speed = 0;
        }
    }
    
    // Handle going down slopes
    if (y_speed >= 0 && !place_meeting(x + x_speed, y + 1, _collision_map) && place_meeting(x + x_speed, y + abs(x_speed) + 1, _collision_map)) {
    	while (!place_meeting(x + x_speed, y + _sub_pixel,_collision_map)) {
        	y += _sub_pixel;
        }
    }
    
    // --- Commit to horizontal movement ---
    x += x_speed;
    
    // --- Clamp horizontal position to room bounds based on mask of the instance ---
    var _half_sprite_mask = .5 * (bbox_right - bbox_left);
    x = clamp(x, _half_sprite_mask, room_width - _half_sprite_mask);
    #endregion
    
    // JUMP
    
    #region GENERAL VERTICAL MOVEMENT PHYSICS
    // Wall slide and wall grab states handle their own vertical movement, overriding default gravity.
    // Therefore, only apply general gravity if not in those states.
    if (player_state != PlayerState.WALL_SLIDE && player_state != PlayerState.WALL_GRAB) {
        // Apply gravity to vertical speed.
        y_speed += grav;
        y_speed = min(y_speed, grav_max); // Clamp vertical speed to prevent it from exceeding max falling speed.
        
        // No upper clamp for y_speed when knocked back, allowing full upward impulse.
        // Otherwise, clamp to normal max upward speed for regular jumps.
        if (!knockback_active) {
            y_speed = max(y_speed, -grav_max);
        }
    }
#endregion
    

    #region VERTICAL
    // --- Move vertically until collision ---
    if (place_meeting(x, y + y_speed, _collision_map)) {
        var _y_pixel_step = _sub_pixel * sign(y_speed);
        while (!place_meeting(x, y + _y_pixel_step, _collision_map)) {
            y += _y_pixel_step;
        }
        y_speed = 0;
    }
    // --- Commit Vertical Movement ---
    y += y_speed;
    #endregion
    

}