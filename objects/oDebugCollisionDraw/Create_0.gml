/// @description Separate toggles for each debug category
global.debug_draw_collision = false;
global.debug_draw_camera = false;
global.debug_draw_audio = false;

/**
 * @function draw_spatial_sound_debug
 * @description Draws debug circles for spatial audio falloff.
 * This function is designed to be called from WITHIN a 'with' block
 * so that 'x', 'y', 'falloff_ref', and 'falloff_max' are in the
 * correct instance scope.
 */
draw_spatial_sound_debug = function() {
    // Preserve draw settings
    var _prev_alpha = draw_get_alpha();
    var _prev_color = draw_get_color();

    // Visualize full volume zone
    draw_set_alpha(0.20);
    draw_set_color(c_lime);
    draw_circle(x, y, falloff_ref, false); // 'x', 'y', 'falloff_ref' from the instance in 'with'

    // Visualize fade-out boundary
    draw_set_alpha(0.60);
    draw_set_color(c_lime);
    draw_circle(x, y, falloff_max, true); // 'falloff_max' from the instance in 'with'

    // Restore draw settings
    draw_set_alpha(_prev_alpha);
    draw_set_color(_prev_color);
}
