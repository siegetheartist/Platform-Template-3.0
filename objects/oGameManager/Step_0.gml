#region PARALLAX SCROLLING

// --- Parallax Scrolling Logic ---
// Get the camera's current X position.
var _camera_x = camera_get_view_x(view_camera[0]);

// Calculate the horizontal offset for each layer based on the camera's movement and
// each layer's scroll speed multiplier.
var _bg_1_x_offset = _camera_x * bg_1_scroll_speed;
var _bg_2_x_offset = _camera_x * bg_2_scroll_speed;
var _bg_3_x_offset = _camera_x * bg_3_scroll_speed;

// Apply the calculated offset to each layer.
// The Background_0 (static) layer does not need to move.
layer_x("Background_1", _bg_1_x_offset);
layer_x("Background_2", _bg_2_x_offset);
layer_x("Background_3", _bg_3_x_offset);

#endregion
