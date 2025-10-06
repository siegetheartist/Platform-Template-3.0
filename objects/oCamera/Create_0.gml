/// @description 2 Inner region camera snapping triggered by 2 threshold regions.
// Mario horizontally + vertical platform lerp snapping

// --- CAMERA CONFIG ---
cam_width = 352;
cam_height = 224;
cam_margin_x = 40;   // Horizontal deadzone: player can move x pixels left and right, from camera's center before, camera starts moving
cam_margin_y = 30;   // Vertical deadzone before camera starts moving
cam_lerp = 0.1;      // Lerp smoothing factor (1 = instant, 0 = no movement) (Used to be 0.1)
 
// --- FORWARD FOCUS CONFIG ---
// These define the look-ahead behavior
max_look_ahead_offset = 60; // Max offset from player to camera center for 'look-ahead'
look_ahead_lerp_speed = 0.1; // How quickly the current look_ahead_offset_amount adjusts
look_ahead_offset_amount = 0; // The actual current horizontal offset the camera applies
 
// --- HORIZONTAL ANCHORING & THRESHOLD CONFIG (NEW) ---
camera_focus_dir = 1; // 1 for right, -1 for left. Initial direction.
outer_threshold_offset = 40; // Distance from camera center to the outer threshold lines. Player must cross this to flip focus_dir.
inner_focus_zone_offset = 20; // Distance from camera center to the inner "ideal" player position lines.
                              // This defines the "anchor" zones (inner flags) for debug drawing.

// --- VERTICAL OFFSET (NEW) ---
vertical_offset = 24; // Pushes camera up from player origin
vertical_ground_lerp = .1; // Easing for vertical camera follow on ground snapping
 
// --- INITIAL CAMERA SETUP ---
target = oPlayer; // The object to follow
cam_x = target.x;
cam_y = target.y - (vertical_offset + cam_margin_y); // Apply offset immediately
 
// --- CREATE CAMERA AND ASSIGN TO VIEWPORT 0 ---
camera = camera_create_view(cam_x, cam_y, cam_width, cam_height);
view_set_camera(0, camera);
 