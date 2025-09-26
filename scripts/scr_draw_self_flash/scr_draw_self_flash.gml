/// @description Draws the instance with a flashing effect if the flash_timer is active.
function scr_draw_self_flash() {
    if (sprite_index != noone) {
        if (flash_timer > 0) {
            if (flash_timer mod 6 < 3) { // Blink every 3 frames
                draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
            } else {
                draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, 0); // Transparent
            }
        } else {
            draw_self();
        }
    }
}