// Movement systems heavily inspired by Peyton Burnham
// Credit to his 9 part "How ot make a 2D platformer series

/// @description Resolve overlaps with solid moving platforms that moved inside the player (Begin Step)
function moving_platform_collision_correction() {
    
    var _right_wall = noone;
    var _left_wall = noone;
    var _bottom_wall = noone;
    var _top_wall = noone;
    var _list = ds_list_create();
    var _list_size = instance_place_list(x, y, objMovingPlatform, _list, false);
    
    // Check all overlapping moving platforms
    for (var i = 0; i < _list_size; i++) {
    	var  _list_instance = _list[| i];
        
        // Track nearest platform on each side of the player
        // Right side: platform’s left edge is to the right of player’s right edge
        if (_list_instance.bbox_left - _list_instance.x_speed >= bbox_right - 1) {
        	if (!instance_exists(_right_wall) || _list_instance.bbox_left < _right_wall.bbox_left) {
            	_right_wall = _list_instance;
            }
        }
        
        // Left side: platform’s right edge is to the left of player’s left edge
        if (_list_instance.bbox_right - _list_instance.x_speed <= bbox_left + 1) {
        	if (!instance_exists(_left_wall) || _list_instance.bbox_right > _left_wall.bbox_right) {
            	_left_wall = _list_instance;
            }
        }
        
        // Bottom side: platform’s top edge is below player’s bottom edge
        if (_list_instance.bbox_top - _list_instance.y_speed >= bbox_bottom - 1) {
        	if (!instance_exists(_bottom_wall) || _list_instance.bbox_top < _bottom_wall.bbox_top) {
            	_bottom_wall = _list_instance;
            }
        }
        
        // Top side: platform’s bottom edge is above player’s top edge
        if (_list_instance.bbox_bottom - _list_instance.y_speed <= bbox_top + 1) {
        	if (!instance_exists(_top_wall) || _list_instance.bbox_bottom > _top_wall.bbox_bottom) {
            	_top_wall = _list_instance;
            }
        }
    }
    
    ds_list_destroy(_list); // Destroy ds list to free memory and avoid memory leak
    
    // Push player out of overlapping walls
    // Right wall: move player left if not blocked
    if ( instance_exists(_right_wall) && !place_meeting(bbox_left + _right_wall.x_speed, y, objWall) ) {
    	var _right_distance = bbox_right - x;
        x = _right_wall.bbox_left - _right_distance;
    }
    
    // Left wall: move player right if not blocked
    if ( instance_exists(_left_wall) && !place_meeting(bbox_right + _left_wall.x_speed, y, objWall) ) {
    	var _left_distance = x - bbox_left;
        x = _left_wall.bbox_right + _left_distance;
    }
    
    // Bottom wall: move player up
    if (instance_exists(_bottom_wall)) {
    	var _bottom_distance = bbox_bottom - y;
        y = _bottom_wall.bbox_top - _bottom_distance;
    }
    
    // Top wall: move player down if space is clear (used for polish/crouch features)
    if (instance_exists(_top_wall)) {
    	var _up_distance = y - bbox_top;
        var _target_y = _top_wall.bbox_bottom + _up_distance;
        
        if (!place_meeting(x, _target_y, objWall)) {
        	y = _target_y;
        }
    }
    
    // Don't get left behind by a moving platform
    early_moving_plat_x_speed = false; // Default to false
    if (instance_exists(my_floor_plat) && my_floor_plat.x_speed != 0 && !place_meeting(x, y + term_vel + 1, my_floor_plat)) {
    	if (!place_meeting(x + my_floor_plat.x_speed, y, objWall)) {
        	x += my_floor_plat.x_speed;
            early_moving_plat_x_speed = true; // Set to true if you did move early due to being on a moving platform (it moved you)
        }
    }
}

// -----------------------------------------------------------------------------------------

/// @description Horizontal physics calculations. Handles knockback, accel, decel.
/// @param {type} _dir The current directional intent (-1 left, 1 right, 0 none).
/// @param {real} [_change_speed] Multiplier for max_x_speed. Optional; defaults to 1.
function horizontal_physics(_dir, _change_speed = 1) {
    // --- Knockback Physics ---
    if (knockback_active) {
        // Apply knockback-specific friction/deceleration
        if (abs(x_speed) > knockback_h_friction) {
            x_speed -= sign(x_speed) * knockback_h_friction;
        } else {
            x_speed = 0;
        }
    
        // End knockback if duration timer runs out
        if (knockback_duration_timer <= 0) {
            knockback_active = false;
            x_speed = 0;
            y_speed = 0;
        }
    }
    
    // --- Normal Movement Physics ---
    if (!knockback_active) {
        if (_dir != 0) {
            // Accelerate towards max speed in the input direction
            x_speed += _dir * accel;
            x_speed = clamp(x_speed, -max_x_speed * _change_speed, max_x_speed * _change_speed);
        } else {
            // If no horizontal input, apply deceleration
            if (abs(x_speed) > decel) {
                x_speed -= sign(x_speed) * decel;
            } else {
                x_speed = 0;
            }
        }
    }
}

// -----------------------------------------------------------------------------------------

/// @description Vertical physics calculations. Handles gravity, knockback, coyote time.
function vertical_physics() {
    
    // TODO: Consider better solution
    // Safety check. Ex: Enemies don't use coyote time (You don't need this if they do have the variable)
    if (!variable_instance_exists(id, "coyote_hang_timer")) {
    	coyote_hang_timer = 0;
    }
    
    // Only apply gravity if coyote hang has expired
    if (coyote_hang_timer <= 0) {
        y_speed += grav;
        y_speed = min(y_speed, term_vel); // Clamp vertical speed to prevent exceeding max falling speed
        set_on_ground(false); // Apply gravity if we DON'T have coyote time (time has run out, you are now considered NOT on ground)
    }

    // No upper clamp for y_speed when knocked back, allowing full upward impulse.
    // Otherwise, clamp to normal max upward speed for regular jumps.
    if (!knockback_active) {
        y_speed = max(y_speed, -term_vel);
    }
}

// -----------------------------------------------------------------------------------------

/// @description Helper script to check for a semi-solid platform.
/// @param {Real} _x checking instance's x position
/// @param {Real} _y checking instance's y position
function check_for_semi_solid_platform(_x, _y) {
    
    var _return = noone; // Holds the return value. Using "return" directly would exit the loop.
    
    // Only check for semi-solid collisions when moving downward
    if (y_speed >= 0 && place_meeting(_x, _y, objSemiSolidWall)) {
    	var _list = ds_list_create();
        var _list_size = instance_place_list(_x, _y, objSemiSolidWall, _list, false);
        
        // Loop through colliding instances; return one if its top is below the player’s bottom
        for (var i = 0; i < _list_size; i++) {
            
            var _list_instance = _list[| i];
            
            // Ensure the player’s bottom is above the instance’s top (adjusted by its vertical speed)
        	if ( _list_instance != forget_semi_solid && floor(bbox_bottom) <= ceil(_list_instance.bbox_top - _list_instance.y_speed)) {
                
                // Store the ID of the semi-solid platform
            	_return = _list_instance;
                i = _list_size; // Exit loop early once a valid platform is found
            }
        }
        ds_list_destroy(_list); // Always destroy ds_list to free memory and prevent leaks
    }
    return _return; // Return the ID of the semi-solid platform
}

// -----------------------------------------------------------------------------------------

/// @description Handles horizontal movement with and without collisions with non-moving objects.
function horizontal_movement() {
    if (place_meeting(x + x_speed, y, collision_tileset)) {
    
        // --- Moving up slopes ---
        var _sub_pixel = 0.5;
        if (!place_meeting(x + x_speed, y - abs(x_speed) - 1, collision_tileset)) {
        	while (place_meeting(x + x_speed, y, collision_tileset)) {
                y -= _sub_pixel;
            }
        } 
        
        else {
            // --- Slide along ceiling slopes (optional) ---
            if (!place_meeting(x + x_speed, y + abs(x_speed) + 1, collision_tileset)) {
                while (place_meeting(x + x_speed, y, collision_tileset)) {
                	y += _sub_pixel;
                }
            }
        
            // --- Normal movement (no slopes) ---
            else {
                var _x_pixel_step = _sub_pixel * sign(x_speed);
                while (!place_meeting(x + _x_pixel_step, y, collision_tileset)) {
                    x += _x_pixel_step;
                }
                
                x_speed = 0;
            }
        }
    }

    // --- Moving down slopes ---
    down_slope_semi_solid = noone; // Reset to default before checking below
    if (y_speed >= 0 && !place_meeting(x + x_speed, y + 1, collision_tileset) && place_meeting(x + x_speed, y + abs(x_speed) + 1, collision_tileset)) {
        
        // First check for a semi-solid object in the way
        down_slope_semi_solid = check_for_semi_solid_platform(x + x_speed, y + abs(x_speed) + 1);
        
        // Move down slope if there isn't a semi-solid in the way
        var _sub_pixel = 0.5;
        if (!instance_exists(down_slope_semi_solid)) {
        	while (!place_meeting(x + x_speed, y + _sub_pixel, collision_tileset)) {
                y += _sub_pixel;
            }
        }
    }
    
    // --- Commit to horizontal movement ---
    x += x_speed;
    
    // --- Clamp horizontal position to room bounds based on mask of the instance ---
    var _half_sprite_mask = .5 * (bbox_right - bbox_left);
    x = clamp(x, _half_sprite_mask, room_width - _half_sprite_mask);
}

// -----------------------------------------------------------------------------------------

/// @param {bool} _key_down down input
/// @param {bool} _key_jump jump input
/// @description Handles vertical movement with and without collisions with moving and non-moving objects.
// TODO: Enemies won't have key press. Update code to handle this.
function vertical_movement() {
    // Ceiling collisions
    if (y_speed < 0 && place_meeting(x, y + y_speed, collision_tileset)) {
        var _sub_pixel = 0.5;
        while (!place_meeting(x, y - _sub_pixel, collision_tileset)) {
            y -= _sub_pixel;
        }
        
        // BONK. You hit your head on a ceiling. Stop vertical speed
        jump_speed_sustain_timer = 0;
        y_speed = 0;
    }
    
    
    // Floor collisions (Solid and semi-solid platforms under instance)
    var _clamp_y_speed = max(0, y_speed); // Return 0 or positive y_speed (going down)
    var _list = ds_list_create();
    var _array = array_create(0);
    array_push(_array, objWall, objSemiSolidWall);
    
    // Check for collision and add colliding objects to a list
    var _list_size = instance_place_list(x, y + 1 + _clamp_y_speed + term_vel, _array, _list, false);
    
        // Bandaid fix for hi-res / high speed projects
        var _ycheck = y + 1 + _clamp_y_speed;
        if (instance_exists(my_floor_plat)) {
        	_ycheck += max(0, my_floor_plat.y_speed);
        }
        var _semi_solid = check_for_semi_solid_platform(x, _ycheck);
    
    // Loop through colliding instances. Only return one if it's top is below the player
    for (var i = 0; i < _list_size; i++) {
        
        // Get an instance of an object from the list
    	var _list_inst = _list[| i];
        
        // Avoid "magnnetism" a.k.a sticking to platforms
        if ( _list_inst != forget_semi_solid
        && (_list_inst.y_speed <= y_speed || instance_exists(my_floor_plat) ) 
        && (_list_inst.y_speed > 0 || place_meeting(x, y + 1 + _clamp_y_speed, _list_inst) ) 
        || (_list_inst == _semi_solid) ) { // Last argument associated with the bandaid "high res/speed" fix above
        
            // Return a solid wall or any semi-solid wall that are below the player
            if (_list_inst.object_index == objWall
                || object_is_ancestor(_list_inst.object_index, objWall)
                || floor(bbox_bottom) <= ceil(_list_inst.bbox_top - _list_inst.y_speed)) {
            	
                // Return the "highest" wall object
                if (!instance_exists(my_floor_plat) 
                    || _list_inst.bbox_top + _list_inst.y_speed <= my_floor_plat.bbox_top + my_floor_plat.y_speed
                    || _list_inst.bbox_top + _list_inst.y_speed <= bbox_bottom) {
                    
                	my_floor_plat = _list_inst;
                }
            }
        }
    }
    
    // Destroy the DS list to avoid memory leak
    ds_list_destroy(_list);
    
    // EXCEPTION: Downslope semi-solid for making sure we don't miss semi-solid's while going down slopes
    if (instance_exists(down_slope_semi_solid)) {
    	my_floor_plat = down_slope_semi_solid;
    }
    
    // Check to ensure a floor platform is actually below us
    if (instance_exists(my_floor_plat) && !place_meeting(x, y + term_vel, my_floor_plat)) {
    	my_floor_plat = noone;
    }
    
    // Land on the ground platform if there is one
    if (instance_exists(my_floor_plat)) {
        
    	// Move up to our wall precisely
        var _sub_pixel = 0.5;
        while (!place_meeting(x, y + _sub_pixel, my_floor_plat) && !place_meeting(x, y, objWall)) {
        	y += _sub_pixel;
        }
        
        // Make sure we don't end up below the top of a semi-solid
        if (my_floor_plat.object_index == objSemiSolidWall || object_is_ancestor(my_floor_plat.object_index, objSemiSolidWall)) {
        	while (place_meeting(x, y, my_floor_plat)) {
            	y -= _sub_pixel;
            }
        }
        
        // Floor the y position to remove floating point
        y = floor(y);
        
        // Collide with the ground
        y_speed = 0;
        set_on_ground(true);
    }
    
    /*
    // Enable jumping down through semi-solid platforms
    if (_key_down && _key_jump) {
        
    	// Ensure we are on a semi-solid object
        if ( instance_exists(my_floor_plat)
            && ( my_floor_plat.object_index == objSemiSolidWall || object_is_ancestor(my_floor_plat.object_index, objSemiSolidWall) ) ) {
            
        	var _y_check = max(1, my_floor_plat.y_speed + 1);
            if ( !place_meeting(x, y + _y_check, objWall) ) {
            	// Move below the platform
                y += 1;
                
                // Inherit any downward speed from my floor platform so it doesn't catch me
                y_speed = _y_check - 1;
                
                // Forget this platform for a brief time so we don't get caught again
                forget_semi_solid = my_floor_plat;
                
                // No more floor platform
                set_on_ground(false);
            }
        }
    }
     */
    
    // --- Commit Vertical Movement ---
    if (!place_meeting(x, y + y_speed, objWall) ) {
    	y += y_speed;
    }
    
    
    // Reset forget_semi_solid variable (fixes not being able to recollide with semi-solids)
    if ( instance_exists(forget_semi_solid) && !place_meeting(x, y, forget_semi_solid) ) {
    	forget_semi_solid = noone;
    }
    
    
    // --- Final moving platform collisions and movement ---
    
    // X - move_plat_x_speed and collision
    move_plat_x_speed = 0;
    if (instance_exists(my_floor_plat)) {
    	move_plat_x_speed = my_floor_plat.x_speed;
    }
    
    // Move with move_plat_x_speed only if we've moved early due to us being on top of a moving platform
    if (!early_moving_plat_x_speed) {
    	
        if (place_meeting(x + move_plat_x_speed, y, objWall)) {
        	var _sub_pixel = .5;
            var _x_pixel_step = _sub_pixel * sign(move_plat_x_speed);
            while (!place_meeting(x + _x_pixel_step, y, objWall)) {
            	x += _x_pixel_step;
            }
            
            move_plat_x_speed = 0;
        }
        
        // Move with platform
        x += move_plat_x_speed;
    }
    
    // Y - Snap to my_floor_plat if it's a moving vertically
    if (instance_exists(my_floor_plat) 
    && (my_floor_plat.y_speed != 0 
    || my_floor_plat.object_index == objMovingPlatform
    || object_is_ancestor(my_floor_plat.object_index, objMovingPlatform)
    || my_floor_plat.object_index == objSemiSolidMovingPlatform
    || object_is_ancestor(my_floor_plat.object_index, objSemiSolidMovingPlatform) )) {
            
    	// Snap to the top of the floor platform (un-floor() our y variable so it's not jittery
        if (!place_meeting(x, my_floor_plat.bbox_top, objWall) 
        && my_floor_plat.bbox_top >= bbox_bottom - term_vel) {
        	y = my_floor_plat.bbox_top;
        }
    }
    
    // Get pushed down through a semi-solid platform by a solid moving platform
    if (instance_exists(my_floor_plat) 
    && (my_floor_plat.object_index == objSemiSolidWall || object_is_ancestor(my_floor_plat.object_index, objSemiSolidWall) ) 
    && place_meeting(x, y, objWall) ) {
    	
        // If i'm already stuck in a wall at this point, try and move down to get below a semi-solid platform
        // If i'm still stuck afterwards, that just means i've been properly "crushed"
        
        // Also, don't check too far, we don't want to warp below walls
        var _max_push_distance = 10; // The farthest a moving platform can push the player down
        var _pushed_distance = 0;
        var _start_y = y;
        while (place_meeting(x, y, objWall) && _pushed_distance <= _max_push_distance) {
        	y++;
            _pushed_distance++;
        }
        
        my_floor_plat = noone; // You've been pushed through a semi-solid platform. You are now falling.
        
        // If i'm still in a wall at this point, i've been crushed regardless
        if (_pushed_distance > _max_push_distance) {
        	y = _start_y;
        }
    }
}


