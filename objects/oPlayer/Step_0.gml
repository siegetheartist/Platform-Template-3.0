#region CHECKS

// --- Ground Check ---
var _on_ground = place_meeting(x, y + 1, oBlock);

// --- Movement check ---
var _is_moving = hsp != 0;

// --- Vertical State Checks ---
var _is_ascending = vsp < 0; // True if moving upwards
var _is_descending = vsp > 0; // True if moving downwards

//  --- Touching wall check
// Returns: 1 if wall on right, -1 on left, and 0 if no wall
var _on_wall = place_meeting(x+1, y, oBlock) - place_meeting(x-1, y, oBlock); 

#endregion

#region GET INPUTS
// Only get inputs if the player has control.
if (can_control) {
    var _key_left = keyboard_check(ord("A"));
    var _key_right = keyboard_check(ord("D"));
    var _key_jump = keyboard_check_pressed(vk_space);
    var _key_jump_held = keyboard_check(vk_space);
    var _key_down = keyboard_check(ord("S")); // Check for 'S' key for fast fall/drop
}
#endregion

#region HORIZONTAL MOVEMENT
if (can_control) {
    // --- Decrement wall jump delay ---
    // Reduces the delay counter by 1 each frame, ensuring it doesn't go below 0.
    wall_jump_delay = max(wall_jump_delay - 1, 0);

    var _dir = 0; // Initialize _dir to 0. This will be the *effective* direction for acceleration.

    // Only get raw directional input if the wall jump delay has expired
    if (wall_jump_delay == 0) {
        _dir = _key_right - _key_left;
    }

    // Determine if the player is in a 'wall clinging' state (airborne, on wall, not fast-falling)
    var _is_wall_clinging = (_on_wall != 0) && (!_on_ground) && (!_key_down);

    // If airborne wall clinging, nullify input and kill hsp
    if (_is_wall_clinging) {
        _dir = 0; // Nullify horizontal input if clinging to a wall (without fast-falling)
        hsp = 0; // Explicitly kill horizontal speed to prevent jitter when airborne wall clinging
    }
    // NEW: Jitter fix for when on ground and pressing into a wall
    else if (_on_ground && _dir != 0 && place_meeting(x + _dir, y, oBlock)) {
        hsp = 0; // If on the ground and trying to move into a wall, immediately set hsp to 0
        _dir = 0; // Also nullify _dir for this frame to prevent further acceleration
    }


    // --- Apply Acceleration/Deceleration ---
    // This block now applies acceleration/deceleration based on the (potentially nullified) _dir.
    // If _is_wall_clinging or grounded-against-wall fix applied, _dir is 0 and hsp is already 0,
    // so this block won't accidentally re-introduce movement or unnecessary deceleration calculations.
    if (_dir != 0) { 
        hsp += _dir * accel; 
    } else { 
        if (hsp > 0) {
            hsp = max(hsp - decel, 0);
        } else {
            hsp = min(hsp + decel, 0);
        }
    }

    // --- Set Max Speed ---
    // This applies regardless of wall jump delay, as current speed should always be clamped.
    hsp = clamp(hsp, -max_hsp, max_hsp);

    // --- Wall Jump ---
    if (_on_wall !=0) && (!_on_ground) && (_key_jump) { // If: on wall, in air, and space bar pressed
        // Change hsp to be opposite the wall, jump away from the wall
        hsp = -_on_wall * wall_jump_distance;
        // Change vsp to jump vertically differently than from the ground
        vsp = jump_height_wall;
        
        // --- Activate wall jump delay ---
        // Player loses horizontal control for wall_jump_delay_max frames after a wall jump.
        wall_jump_delay = wall_jump_delay_max;
    }
} else {
    // If player has no control, stop horizontal movement immediately.
    hsp = 0;
}
#endregion

#region VERTICAL MOVEMENT
if (can_control) {
    // --- Jump Buffer Input ---
    if (_key_jump) {
        jump_buffer = 10; // Set jump buffer for 10 frames
    }
    jump_buffer--; // Decrement jump buffer each frame

    // --- Apply Gravity ---
    var _grav_final = grav; // Default gravity
    var _grav_max_final = grav_max; // Default max fall speed
    var _vsp_min_clamp = jump_height; // Default minimum vsp for clamping (allows upward movement during jump)

    // If player is on a wall AND not on the ground, AND NOT actively wall jumping this frame, AND NOT currently ascending
    if (_on_wall != 0) && (!_on_ground) && (!(_key_jump)) && (!_is_ascending) { 
        // Check if 'down' key is pressed to initiate a fast fall from the wall
        if (_key_down) {
            _grav_final = grav; // Revert to normal gravity for a faster fall
            _grav_max_final = grav_max; // Revert to normal max fall speed
        } else {
            _grav_final = grav_wall; // Apply slower wall slide gravity
            _grav_max_final = grav_max_wall; // Apply slower max fall speed when wall sliding
        }
        _vsp_min_clamp = 0; // When wall sliding (and not jumping away or ascending), cap upward movement at 0
    }

    vsp += _grav_final; // Apply the calculated gravity to vertical speed
    vsp = clamp(vsp, _vsp_min_clamp, _grav_max_final); // Clamp vertical speed using the determined minimum

    // --- Vertical Movement Logic & Coyote Time ---
    if (_on_ground) {
        vsp = 0; // Reset vertical speed when on the ground
        coyote_time = 10; // Reset coyote time when on the ground
        
        // Check for buffered jump
        if (jump_buffer > 0) {
            vsp = jump_height; // Perform jump
            jump_buffer = 0; // Consume jump buffer
        }
    } else { // If not on the ground
        // Gravity is already applied above by 'vsp += _grav_final;', so no need to add 'vsp += grav;' here again.
        coyote_time--; // Decrement coyote time in air
        
        // Check for coyote time jump
        if (_key_jump && (coyote_time > 0)) {
            vsp = jump_height; // Perform jump
            coyote_time = 0; // Consume coyote time
        }
    }

    // --- Variable Jumps ---
    // If ascending and jump key is released, reduce jump height
    if (_is_ascending) && (!_key_jump_held) {
        vsp = max(vsp, jump_height_min);
    }
} else {
    // If player has no control, stop vertical movement immediately.
    vsp = 0;
}
#endregion

#region COLLISIONS AND MOVEMENT

// --- Horizontal Movement and Collision --
x += hsp; // Apply horizontal movement
if (place_meeting(x, y, oBlock)) { // Check for horizontal collision at new position
    var _pixel_step = sign(hsp); // Determine direction to move back (1 or -1)
    // Move player back one pixel at a time until no longer colliding
    while (place_meeting(x, y, oBlock)) {
        x -= _pixel_step;
    }
    hsp = 0; // Stop horizontal movement on collision
}

// --- Vertical Movement and Collision ---
y += vsp; // Apply vertical movement
if (place_meeting(x, y, oBlock)) { // Check for vertical collision at new position
    var _pixel_step = sign(vsp); // Determine direction to move back (1 or -1)
    // Move player back one pixel at a time until no longer colliding
    while (place_meeting(x, y, oBlock)) {
        y -= _pixel_step;
    }
    vsp = 0; // Stop vertical movement on collision
}

#endregion

#region ANIMATIONS

// --- Orient sprite to face movement direction ---
if (hsp != 0) {
    image_xscale = sign(hsp);
}

// --- Set Animation Based on State ---
if (!_on_ground) { // If in the air
    // Check if the player is against a wall
    if (_on_wall != 0) {
        sprite_index = sPlayerOnWall;
        image_speed = 0; // Freeze the animation if it's a single frame
        image_xscale = -_on_wall; // FLIP the sprite to face the wall
    } else {
        // Normal airborne animation
        sprite_index = sPlayerInAir;

        if (vsp < 0) { // If ascending
            image_index = 0; // First frame for ascending
            image_speed = 0; // Freeze animation
        } else { // If descending (vsp >= 0)
            image_index = 1; // Second frame for descending
            image_speed = 0; // Freeze animation
        }
    }
} else { // If on the ground
    if (_is_moving) {
        sprite_index = sPlayerRun;
        image_speed = 1; // Play run animation
    } else {
        sprite_index = sPlayer; // Idle sprite
        image_speed = 1; // Play idle animation
    }
}

#endregion

#region ENEMIES

// Game over
if (place_meeting(x, y, oBad)) {
    // Player triggers a fade-out to respawn.
    instance_create_layer(0, 0, "l_Faders", oFader);
    oFader.fader_mode = "respawn";
}

#endregion

#region DELETE BEFORE PUBLISHING
if (keyboard_check(vk_enter)) {
    // Player triggers a fade-out to respawn.
    instance_create_layer(0, 0, "l_Faders", oFader);
    oFader.fader_mode = "respawn";
}
#endregion