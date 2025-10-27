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

// --- VERTICAL LOGIC ---
// This block handles both grounded and aerial camera movement cleanly.
if (target.on_ground && target.y_speed == 0) { // was >= 0
    // --- GROUNDED LOGIC ---
    // Goal: Align the player's feet (target.y) with the bottom of the camera's vertical deadzone.
    var desired_y = target.y - (vertical_offset + cam_y_deadzone);
    // Smoothly lerp to the target Y position.
    cam_y = lerp(cam_y, desired_y, vertical_ground_lerp); // You can tweak the 0.08 smoothing factor
} else {
    // --- AERIAL LOGIC ---
    // When in the air, use the original deadzone logic with a vertical offset.
    var ideal_cam_center_y = target.y - vertical_offset;
    var dy = ideal_cam_center_y - cam_y;
    if (abs(dy) > cam_y_deadzone) {
        cam_y += (dy - sign(dy) * cam_y_deadzone) * cam_lerp;
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
