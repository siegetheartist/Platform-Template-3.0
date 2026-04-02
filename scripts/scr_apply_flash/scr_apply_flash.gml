/// @description Applies a flash effect to a target instance.
/// @param target_instance The instance to apply the flash effect to.

function scr_apply_flash(target_instance) {
    target_instance.flash_timer = target_instance.flash_duration;
}