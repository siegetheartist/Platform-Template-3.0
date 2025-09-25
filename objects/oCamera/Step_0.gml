
// --- SAFETY CHECK ---
if (!instance_exists(target)) {
    // Optionally, you can try to reacquire the player if it respawns later
    if (instance_exists(oPlayer)) {
        target = oPlayer;
    } else {
        exit; // Skip camera logic this frame
    }
}

if (instance_exists(target)) {
    // This tells the audio engine where the "ears" are.
    audio_listener_position(oPlayer.x, oPlayer.y, 0);
	// show_debug_message("Listener position: " + string(oPlayer.x));
}

 
// --- HORIZONTAL ANCHORING & THRESHOLD LOGIC ---
// 1. Calculate the player's X position relative to the camera's current center.
var player_relative_to_cam_center_x = target.x - cam_x;
 
// 2. Determine player's current horizontal movement direction.
var player_current_hsp_dir = sign(target.hsp);
 
// 3. Check for focus direction change based on player's relative position and movement.
//    Only change focus if the player is moving in the *opposite* direction of the current camera focus
//    AND has crossed the *outer* threshold for that opposite direction.
if (camera_focus_dir == 1) { // Currently focused right (player is ideally to the left of camera center)
    // If player is moving left AND has crossed the outer left threshold
    if (player_current_hsp_dir < 0 && player_relative_to_cam_center_x < -outer_threshold_offset) {
        camera_focus_dir = -1; // Switch focus to left
    }
} else { // Currently focused left (player is ideally to the right of camera center)
    // If player is moving right AND has crossed the outer right threshold
    if (player_current_hsp_dir > 0 && player_relative_to_cam_center_x > outer_threshold_offset) {
        camera_focus_dir = 1; // Switch focus to right
    }
}
 
// NEW: Smoothly adjust the look_ahead_offset_amount towards its target based on focus direction
var target_look_ahead_offset = camera_focus_dir * max_look_ahead_offset;
look_ahead_offset_amount = lerp(look_ahead_offset_amount, target_look_ahead_offset, look_ahead_lerp_speed);
 
// 4. Determine the ideal target X for the camera center based on the current `look_ahead_offset_amount`.
var ideal_cam_center_x = target.x + look_ahead_offset_amount; // Use the dynamically adjusted look_ahead_offset_amount
 
// 5. Determine the ideal target Y for the camera center (for vertical follow, usually just player's Y).
var ideal_cam_center_y = target.y;
 
// --- APPLY DEADZONE AND LERP LOGIC TO X ---
// The camera only moves horizontally if the `ideal_cam_center_x` is outside the `cam_margin_x` deadzone.
var dx = ideal_cam_center_x - cam_x;
if (abs(dx) > cam_margin_x) {
    cam_x += (dx - sign(dx) * cam_margin_x) * cam_lerp;
}
 
// --- APPLY DEADZONE AND LERP LOGIC TO Y (Existing vertical logic) ---
// The camera only moves vertically if the `ideal_cam_center_y` is outside the `cam_margin_y` deadzone.
var dy = ideal_cam_center_y - cam_y;
if (abs(dy) > cam_margin_y) {
    cam_y += (dy - sign(dy) * cam_margin_y) * cam_lerp;
}
 
// --- OPTIONAL: Clamp to room bounds ---
cam_x = clamp(cam_x, cam_width / 2, room_width - cam_width / 2);
cam_y = clamp(cam_y, cam_height / 2, room_height - cam_height / 2);
 
// --- UPDATE CAMERA POSITION ---
camera_set_view_pos(camera, cam_x - cam_width / 2, cam_y - cam_height / 2);