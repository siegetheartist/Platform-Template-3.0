/// @description 2 Inner region camera snapping triggered by 2 threshold regions.

// --- CAMERA CONFIG ---
cam_width = 352;
cam_height = 224;
cam_margin_x = 40;      // Horizontal deadzone before camera starts moving
cam_lerp = 0.1;         // Lerp smoothing factor (1 = instant, 0 = no movement)

// --- NEW: VERTICAL POSITIONING CONFIG ---
// This offset positions the player in the lower part of the screen.
// A positive value shifts the camera UP relative to the player.
// (cam_height / 6) positions the player roughly 1/3 from the bottom.
cam_vertical_offset = cam_height / 3; //6

// --- FORWARD FOCUS CONFIG ---
max_look_ahead_offset = 60;
look_ahead_lerp_speed = 0.1;
look_ahead_offset_amount = 0;

// --- HORIZONTAL ANCHORING & THRESHOLD CONFIG ---
camera_focus_dir = 1;
outer_threshold_offset = 40;
inner_focus_zone_offset = 20;

// --- INITIAL CAMERA SETUP ---
target = oPlayer; // The object to follow
cam_x = target.x;

// NEW: Start camera at the desired vertical offset from the player
cam_y = target.y - cam_vertical_offset;

// NEW: This variable will hold the "goal" y-position for the camera.
// It only updates when the player is on the ground.
cam_target_y = cam_y;

// --- CREATE CAMERA AND ASSIGN TO VIEWPORT 0 ---
camera = camera_create_view(cam_x, cam_y, cam_width, cam_height);
view_set_camera(0, camera);