draw_self();

draw_set_color(c_white);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);

//var margin = 10;
//var cam = view_camera[0];
//var xx = camera_get_view_x(cam) + camera_get_view_width(cam) - margin;
//var yy = camera_get_view_y(cam) + camera_get_view_height(cam) - margin;

draw_set_font(fnt_start_txt);
draw_text(32, 32, date_time_string(GM_build_date));
draw_text(32, 64, "v" + GM_version);
draw_text(32, 96, "Runtime " + GM_runtime_version);

// Reset alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);
