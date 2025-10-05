// --- SAFETY CHECK ---
if (!instance_exists(target)) {
    if (instance_exists(oPlayer)) {
        target = oPlayer;
    } else {
        exit; // Skip camera logic this frame
    }
}

// --- HORIZONTAL ANCHORING & THRESHOLD LOGIC ---
// [ YOUR EXISTING HORIZONTAL LOGIC REMAINS UNCHANGED ]
var player_relative_to_cam_center_x = target.x - cam_x;
var player_current_hsp_dir = sign(target.hsp);
if (camera_focus_dir == 1) {
    if (player_current_hsp_dir < 0 && player_relative_to_cam_center_x < -outer_threshold_offset) {
        camera_focus_dir = -1;
    }
} else {
    if (player_current_hsp_dir > 0 && player_relative_to_cam_center_x > outer_threshold_offset) {
        camera_focus_dir = 1;
    }
}
var target_look_ahead_offset = camera_focus_dir * max_look_ahead_offset;
look_ahead_offset_amount = lerp(look_ahead_offset_amount, target_look_ahead_offset, look_ahead_lerp_speed);
var ideal_cam_center_x = target.x + look_ahead_offset_amount;

// --- APPLY DEADZONE AND LERP LOGIC TO X ---
// [ YOUR EXISTING HORIZONTAL LERP LOGIC REMAINS UNCHANGED ]
var dx = ideal_cam_center_x - cam_x;
if (abs(dx) > cam_margin_x) {
    cam_x += (dx - sign(dx) * cam_margin_x) * cam_lerp;
}


// --- NEW VERTICAL LOGIC ---
// This logic keeps the camera vertically still while the player is in the air,
// and adjusts only after the player lands on new ground.

// IMPORTANT: This assumes your player object has a variable
// named 'on_ground' which is true when on the ground, and false otherwise.
if (target.is_on_ground) {
    // When the player is on the ground, update the camera's target Y-position.
    // This sets the goal to be the player's current height, minus the offset.
    cam_target_y = target.y - cam_vertical_offset;
}

// ALWAYS smoothly move the camera's actual Y towards the target Y.
// Because cam_target_y only updates when the player is on the ground, the camera will
// appear to wait until the player lands before moving.
cam_y = lerp(cam_y, cam_target_y, cam_lerp);


// --- OPTIONAL: Clamp to room bounds ---
cam_x = clamp(cam_x, cam_width / 2, room_width - cam_width / 2);
cam_y = clamp(cam_y, cam_height / 2, room_height - cam_height / 2);

// --- UPDATE CAMERA POSITION ---
camera_set_view_pos(camera, cam_x - cam_width / 2, cam_y - cam_height / 2);