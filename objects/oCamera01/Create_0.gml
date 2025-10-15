/// @description No regions. Soft camera follow

// --- CAMERA CONFIG ---
cam_width = 640;
cam_height = 320;
cam_x_deadzone = 48;   // Horizontal deadzone before camera starts moving
cam_y_deadzone = 32;   // Vertical deadzone before camera starts moving
cam_lerp = 0.1;      // Lerp smoothing factor (0 = instant, 1 = no movement)

// --- FORWARD FOCUS CONFIG ---
focus_offset_max = 48;      // Max offset in pixels
focus_offset_speed = 0.2;   // How quickly the offset changes
focus_offset_x = 0;         // Current offset


// --- INITIAL CAMERA SETUP ---
target = oPlayer; // The object to follow
cam_x = target.x;
cam_y = target.y;

// --- CREATE CAMERA AND ASSIGN TO VIEWPORT 0 ---
camera = camera_create_view(cam_x, cam_y, cam_width, cam_height);
view_set_camera(0, camera);