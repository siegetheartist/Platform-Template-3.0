/// @function scr_move_and_collide(collision_map)
/// @param collision_map    An array or object to check for collisions against.
/// @description Moves the instance and handles collision with solids.

function scr_move_and_collide(_collision_map) {
    
    var _sub_pixel = .5;
    
    #region HORIZONTAL
    // --- Move horizontally until collision ---
    if (place_meeting(x + hsp, y, _collision_map)) {
        
        // Handle upward slope movement
        // If there is collision to the sides, but not up and to sides, then there is a slope
        if (!place_meeting(x + hsp, y - abs(hsp) -1, _collision_map)) { 
        	while (place_meeting(x + hsp, y, _collision_map)) {
            	y -= _sub_pixel;
            }
        } 
        
        // Normal movement (no slopes)
        else { 
        	var _x_pixel_step = _sub_pixel * sign(hsp);
            while (!place_meeting(x + _x_pixel_step, y, _collision_map)) {
                x += _x_pixel_step;
            }
            hsp = 0;
        }
    }
    
    // Handle going down slopes
    if (vsp >= 0 && !place_meeting(x + hsp, y + 1, _collision_map) && place_meeting(x + hsp, y + abs(hsp) + 1, _collision_map)) {
    	while (!place_meeting(x + hsp, y + _sub_pixel,_collision_map)) {
        	y += _sub_pixel;
        }
    }
    
    // --- Commit to horizontal movement ---
    x += hsp;
    
    // --- Clamp horizontal position to room bounds based on mask of the instance ---
    var _half_sprite_mask = .5 * (bbox_right - bbox_left);
    x = clamp(x, _half_sprite_mask, room_width - _half_sprite_mask);
    #endregion
    

    #region VERTICAL
    // --- Move vertically until collision ---
    if (place_meeting(x, y + vsp, _collision_map)) {
        var _y_pixel_step = _sub_pixel * sign(vsp);
        while (!place_meeting(x, y + _y_pixel_step, _collision_map)) {
            y += _y_pixel_step;
        }
        vsp = 0;
    }
    // --- Commit Vertical Movement ---
    y += vsp;
    #endregion
    

}