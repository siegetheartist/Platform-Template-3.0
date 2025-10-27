// --- SAFETY CHECK ---
// Make sure the target instance exists before running any camera logic.
if (!instance_exists(target)) {
    // If the target is gone, try to find the player object again.
    if (instance_exists(oPlayer)) {
        target = oPlayer;
    } else {
        // If no player exists, skip all camera logic for this frame.
        exit;
    }
}

// --- HORIZONTAL ANCHORING & THRESHOLD LOGIC ---
// 1. Calculate the player's X position relative to the camera's current center.
var player_relative_to_cam_center_x = target.x - cam_x;

// 2. Determine player's current horizontal movement direction.
var player_current_x_speed_dir = sign(target.x_speed);

// 3. Check for focus direction change based on player's relative position and movement.
if (camera_focus_dir == 1) { // Currently focused right
    if (player_current_x_speed_dir < 0 && player_relative_to_cam_center_x < -outer_threshold_offset) {
        camera_focus_dir = -1; // Flip focus to the left
    }
} else { // Currently focused left
    if (player_current_x_speed_dir > 0 && player_relative_to_cam_center_x > outer_threshold_offset) {
        camera_focus_dir = 1; // Flip focus to the right
    }
}

// Smoothly adjust the look_ahead_offset_amount towards its target
var target_look_ahead_offset = camera_focus_dir * max_look_ahead_offset;
look_ahead_offset_amount = lerp(look_ahead_offset_amount, target_look_ahead_offset, look_ahead_lerp_speed);

// 4. Determine the ideal target X for the camera center
var ideal_cam_center_x = target.x + look_ahead_offset_amount;

// --- APPLY DEADZONE AND LERP LOGIC TO X ---
var dx = ideal_cam_center_x - cam_x;
if (abs(dx) > cam_x_deadzone) {
    cam_x += (dx - sign(dx) * cam_x_deadzone) * cam_lerp;
}

// --- VERTICAL LOGIC (STATE-BASED) ---

// 1. Handle the GROUNDED state. This is also where we RESET the camera's fall mode.
if (target.on_ground && target.y_speed == 0) {
    camera_fall_mode = false; // Reset the camera's state upon landing.
    
    // Smoothly lerp to the standard grounded position.
    var desired_y = target.y - (vertical_offset + cam_y_deadzone);
    cam_y = lerp(cam_y, desired_y, vertical_ground_lerp);

} 
// 2. Handle the AERIAL state (Jumping or Falling).
else {

    // First, check if we need to ENTER fall mode.
    // We only check this if we aren't already in fall mode.
    if (!camera_fall_mode) {
        var ideal_y_check = target.y - vertical_offset;
        var dy_check = ideal_y_check - cam_y;

        // Condition to enter fall mode:
        // - Player is below the vertical deadzone AND
        // - Player's coyote time has expired.
        // - The camera is NOT already at the bottom of the room.
        if (dy_check > cam_y_deadzone && target.coyote_jump_timer <= 0 && cam_y < room_height - cam_height / 2) {
            camera_fall_mode = true;
        }
    }

    // Now, apply camera movement based on the current state.
    if (camera_fall_mode) {
        // --- FALL MODE LOGIC ---
        // The camera has committed to falling.
        // Remove vertical offset to see more of what's below.
        var fall_ideal_y = target.y;
        
        // Define the target Y, which is the bottom edge of the deadzone relative to the player.
        var target_y = fall_ideal_y - cam_y_deadzone;
        
        // Smoothly LERP towards the target Y position for a smoother fall-follow.
        cam_y = lerp(cam_y, target_y, cam_fall_lerp);

    } else {
        // --- NORMAL AERIAL / JUMPING LOGIC ---
        // The camera is not in fall mode, so use the original smooth upward movement.
        var ideal_y = target.y - vertical_offset;
        var dy = ideal_y - cam_y;
        if (dy < -cam_y_deadzone) {
            cam_y += (dy + cam_y_deadzone) * cam_lerp;
        }
    }
}

// --- OPTIONAL: Clamp to room bounds ---
// Prevents the camera from showing areas outside the room.
cam_x = clamp(cam_x, cam_width / 2, room_width - cam_width / 2);
cam_y = clamp(cam_y, cam_height / 2, room_height - cam_height / 2);

// --- UPDATE CAMERA POSITION ---
// Apply the final calculated position to the game's camera.
camera_set_view_pos(camera, cam_x - cam_width / 2, cam_y - cam_height / 2);

// Keep updating the shake each frame
scr_camera_shake(view_camera[0], 0, 0);
