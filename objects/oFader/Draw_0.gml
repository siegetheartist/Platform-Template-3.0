// Get the current camera's position and size to draw a rectangle that covers the view.
var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_width = camera_get_view_width(view_camera[0]);
var _cam_height = camera_get_view_height(view_camera[0]);

// Set the color and transparency.
draw_set_alpha(alpha);
draw_set_color(c_black);

// Draw a rectangle over the entire screen, using the camera's dimensions.
draw_rectangle(_cam_x, _cam_y, _cam_x + _cam_width, _cam_y + _cam_height, false);

// Reset the drawing settings.
draw_set_alpha(1);
draw_set_color(c_white);