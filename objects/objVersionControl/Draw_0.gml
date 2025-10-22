draw_self();

var margin = 10;
var cam    = view_camera[0];
var xx     = camera_get_view_x(cam) + camera_get_view_width(cam)  - margin;
var yy     = camera_get_view_y(cam) + camera_get_view_height(cam) - margin;

draw_set_color(c_white);
draw_set_font(fnt_start_txt);

// align to bottom‑right corner
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);

// draw the INI build number
draw_text(xx, yy, version_string);

// reset alignment so it doesn’t affect other draw calls
draw_set_halign(fa_left);
draw_set_valign(fa_top);
