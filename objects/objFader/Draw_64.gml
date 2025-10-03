// Set color and alpha
draw_set_alpha(fade_alpha);
draw_set_color(fade_color);

// This draws the fade effect on top of the entire game screen
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

// Reset draw settings so it doesn't affect other objects
draw_set_alpha(1);