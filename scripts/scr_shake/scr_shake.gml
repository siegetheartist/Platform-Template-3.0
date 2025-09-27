/// @function scr_shake(_instance)
/// @description Updates the shake effect for a given instance.
/// @arg {id} _instance The instance to apply shake updates to.
function scr_shake(_instance) {
    if (instance_exists(_instance) && _instance.is_shaking) {
        _instance.shake_timer--;
        show_debug_message("Timer :" + string(_instance.shake_timer));
        
        if (_instance.shake_timer > 0) {
            // Calculate decaying magnitude
            var _current_magnitude = (_instance.shake_timer / _instance.shake_duration_max) * _instance.shake_magnitude;

            if (_instance.shake_horizontal) {
                _instance.x = _instance.original_x + random_range(-_current_magnitude, _current_magnitude);
            } else {
                _instance.y = _instance.original_y + random_range(-_current_magnitude, _current_magnitude);
            }
        } else {
            // Shake finished — reset
            _instance.is_shaking = false;
            _instance.x = _instance.original_x;
            _instance.y = _instance.original_y;
        }
    }
}