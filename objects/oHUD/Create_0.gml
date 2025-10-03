#region CAMERAS AND GUI
// --- Camera and Viewport Setup ---
// Get the width and height of the camera view
var _camera_width = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

// Set the GUI (Heads-Up Display) size to match the camera's resolution
// This ensures that HUD elements are drawn at a 1:1 pixel scale, preventing distortion.
display_set_gui_size(_camera_width, _camera_height);

// The rest of your camera and GUI setup code follows...
#endregion