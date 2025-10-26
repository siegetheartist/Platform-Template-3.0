// --- SAFETY CHECK ---
if (!instance_exists(target)) {
    // Optionally, you can try to reacquire the player if it respawns later
    if (instance_exists(oPlayer)) {
        target = oPlayer;
    } else {
        exit; // Skip camera logic this frame
    }
}


// --- DETERMINE PLAYER DIRECTION ---
var move_dir = sign(target.x_speed); // Assuming target.x_speed is horizontal speed

// --- UPDATE FORWARD OFFSET ---
var desired_offset = move_dir * focus_offset_max;
focus_offset_x = lerp(focus_offset_x, desired_offset, focus_offset_speed);

// --- GET TARGET POSITION WITH OFFSET ---
var tx = target.x + focus_offset_x;
var ty = target.y;

// --- CALCULATE DEADZONE ---
var dx = tx - cam_x;
var dy = ty - cam_y;

// --- APPLY DEADZONE LOGIC ---
if (abs(dx) > cam_x_deadzone) {
    cam_x += (dx - sign(dx) * cam_x_deadzone) * cam_lerp;
}
if (abs(dy) > cam_y_deadzone) {
    cam_y += (dy - sign(dy) * cam_y_deadzone) * cam_lerp;
}

// --- OPTIONAL: Clamp to room bounds ---
cam_x = clamp(cam_x, cam_width / 2, room_width - cam_width / 2);
cam_y = clamp(cam_y, cam_height / 2, room_height - cam_height / 2);

// --- UPDATE CAMERA POSITION ---
camera_set_view_pos(camera, cam_x - cam_width / 2, cam_y - cam_height / 2);
