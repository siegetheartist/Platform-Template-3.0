/// @description Initializes and applies a flash effect to an object.
/// @param {object} [object=id] The instance to apply the flash effect to.
/// @param {real} [duration=6] The duration of the flash in frames.
/// @param {colour} [color=c_white] The color of the flash.

function scr_obj_flash_initialize(_object = id, _duration = 6, _color = c_white) {
    // Check if flash variables are set up on the target object.
    if (!variable_instance_exists(_object, "flash_setup")) {
        _object.flash_setup = true;
        _object.flash_timer = 0;
        _object.flash_color = c_white;
    }

    // Apply the flash effect
    _object.flash_timer = _duration;
    _object.flash_color = _color;
}


/// @description Handles the drawing of the flash effect. Must be called from a Draw event.
function scr_obj_flash_draw() {
	// If the flash effect is not set up, just draw the instance normally.
    if (!variable_instance_exists(id, "flash_setup")) {
        draw_self();
        return;
    }

	// If the flash timer is active, draw the flash effect.
    if (flash_timer > 0) {
        flash_timer--; // Countdown the timer

        // This creates the "blinking" effect.
        if (flash_timer mod 6 < 3) {
            // Use a shader to apply the color flash
            shader_set(shd_flash);
            shader_set_uniform_f(shader_get_uniform(shd_flash, "flash_color"), color_get_red(flash_color)/255, color_get_green(flash_color)/255, color_get_blue(flash_color)/255);
            draw_self();
            shader_reset();
        } else {
            draw_self(); // Draw normally for the "off" blink
        }
    } else {
        draw_self(); // Draw normally when not flashing
    }
}