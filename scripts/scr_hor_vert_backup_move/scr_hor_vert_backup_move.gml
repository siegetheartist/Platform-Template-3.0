// Can opt to use this more verbose code instead of just flat ceilings
// to handle sloped ceilings. It slides the player across slopes ceilings when jumping at them
// i.e has upward velocity
function handle_all_upward_collisions() {
    
    #region HORIZONTAL MOVEMENT RESOLUTION

var _sub_pixel = .5;

if (place_meeting(x + x_speed, y, collision_tileset)) {
    
    // Moving up slopes
    if (!place_meeting(x + x_speed, y - abs(x_speed) - 1, collision_tileset)) {
        while (place_meeting(x + x_speed, y, collision_tileset)) {
            y -= _sub_pixel;
        }
    } else { 
        
        // Handle cieling downward slopes (optional)
        if (!place_meeting(x + x_speed, y + abs(x_speed) + 1, collision_tileset)) {
        	while (place_meeting(x + x_speed, y, collision_tileset)) {
            	y += _sub_pixel;
            }
        }
        
        // Normal left/right movement (no slopes)
        else { 
            var _x_pixel_step = _sub_pixel * sign(x_speed);
            while (!place_meeting(x + _x_pixel_step, y, collision_tileset)) {
                x += _x_pixel_step;
            }
            x_speed = 0;
        }
    }
}

// Handle moving down slopes
if (y_speed >= 0 && !place_meeting(x + x_speed, y + 1, collision_tileset) && place_meeting(x + x_speed, y + abs(x_speed) + 1, collision_tileset)) {
    while (!place_meeting(x + x_speed, y + _sub_pixel, collision_tileset)) {
        y += _sub_pixel;
    }
}

// --- Commit to horizontal movement ---
x += x_speed;

// --- Flush out of wall to prevent corner clipping --- TODO: do I need this? Bandaid fix to ledge grabing?
if (on_wall != 0) { // only if we know which side we're on
    while (place_meeting(x, y, collision_tileset)) {
        x -= _sub_pixel * on_wall; // push out opposite the wall direction
    }
}

// --- Clamp horizontal position to room bounds based on mask of the instance ---
var _half_sprite_mask = .5 * (bbox_right - bbox_left);
x = clamp(x, _half_sprite_mask, room_width - _half_sprite_mask);
#endregion
    
    #region VERTICAL MOVEMENT RESOLUTION
    // Ceiling collisions
    if (y_speed < 0 && place_meeting(x, y + y_speed, collision_tileset)) {
        
        var _slid_on_ceiling_slope = false;
        
        // Handle jumping TOP LEFT into sloped ceiling 
        if (_dir == 0 && !place_meeting(x - abs(y_speed) -1, y + y_speed, collision_tileset)) {
        	while (place_meeting(x , y + y_speed, collision_tileset)) {
            	x -= 1;
                _slid_on_ceiling_slope = true;
            }
        }
        
        // Handle jumping TOP RIGHT into sloped ceiling 
        if (_dir == 0 && !place_meeting(x + abs(y_speed) + 1, y + y_speed, collision_tileset)) {
        	while (place_meeting(x, y + y_speed, collision_tileset)) {
            	x += 1;
                _slid_on_ceiling_slope = true;
            }
        }
        
        // Normal ceiling collision (less than 45 degree slope or no slope)
        if (!_slid_on_ceiling_slope) {
            
            var _y_pixel_step = _sub_pixel * sign(y_speed);
            
            while (!place_meeting(x, y + _y_pixel_step, collision_tileset)) {
                y += _y_pixel_step;
            }
            
            // BONK. You hit your head on a ceiling. Stop vertical speed
            if (y_speed < 0) {
            	jump_speed_sustain_timer = 0;
            }
            
            y_speed = 0;
        }
    }
    #endregion
}