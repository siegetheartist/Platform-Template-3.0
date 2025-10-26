/// @description 2 Inner region camera snapping triggered by 2 threshold regions.
// Mario horizontally + vertical offset + vertical platform lerp snapping + fall snapping
// TERMS:   deadzone: (area where you can move before camera responds
//          damping: ease between player and camera position "add lerp
//          look-ahead: an offset from the player in a direction (to see more in a given direction)
//          camera shake: shaking, stalling, zoom, freeze, slow down, etc.

// --- CAMERA CONFIG ---
cam_width = 480; //440
cam_height = 270; //248
cam_x_deadzone = 40;   // Horizontal deadzone: player can move x pixels left and right, from camera's center before, camera starts moving
cam_y_deadzone = 30;   // Vertical deadzone before camera starts moving
cam_lerp = 0.1;      // Lerp smoothing factor (1 = instant, 0 = no movement) (Used to be 0.1)
cam_fall_lerp = 1.0; // A dedicated lerp for falling DOWN. Lower is smoother.
 
// --- FORWARD FOCUS CONFIG ---
// These define the look-ahead behavior
max_look_ahead_offset = 60; // Max offset from player to camera center for 'look-ahead' 60
look_ahead_lerp_speed = .8; // How quickly the current look_ahead_offset_amount adjusts .8
look_ahead_offset_amount = 0; // The actual current horizontal offset the camera applies
 
// --- HORIZONTAL ANCHORING & THRESHOLD CONFIG (NEW) ---
camera_focus_dir = 1; // 1 for right, -1 for left. Initial direction.
outer_threshold_offset = 40; // Distance from camera center to the outer threshold lines. Player must cross this to flip focus_dir. 40
inner_focus_zone_offset = 20; // Distance from camera center to the inner "ideal" player position lines. 20
                              // This defines the "anchor" zones (inner flags) for debug drawing.

// --- VERTICAL OFFSET (NEW) ---
vertical_offset = 24; // Pushes camera up from player origin
vertical_ground_lerp = .08; // Easing for vertical camera follow on ground snapping
camera_fall_mode = false; // Tracks if the camera is in its special "falling" state
 
// --- INITIAL CAMERA SETUP ---
target = oPlayer; // The object to follow
cam_x = target.x;
cam_y = target.y - (vertical_offset + cam_y_deadzone); // Apply offset immediately
 
// --- CREATE CAMERA AND ASSIGN TO VIEWPORT 0 ---
camera = camera_create_view(cam_x, cam_y, cam_width, cam_height);
view_set_camera(0, camera);
 