/// @function scr_obj_shake(_obj, start_delay, duration, magnitude, axis_mode)
/// @description Shakes an object after a delay. Fully self-contained.
/// @param {Instance} _obj          The object instance to shake
/// @param {Real}     start_delay   The delay in frames before the shaking starts
/// @param {Real}     duration      How long the shake should last, in frames
/// @param {Real}     magnitude     The maximum pixel offset for the shake
/// @param {String}   axis_mode     "horizontal", "vertical", or "random"

function scr_obj_shake(_obj, start_delay, duration, magnitude, axis_mode)
{
    if (!instance_exists(_obj)) return;

    // --- One-Time Initialization ---
    if (!variable_instance_exists(_obj, "shake_initialized")) {
        _obj.shake_state          = 0; // 0 = IDLE, 1 = DELAY, 2 = SHAKING
        _obj.shake_delay_timer    = 0;
        _obj.shake_duration_timer = 0;
        _obj.shake_original_x     = _obj.x;
        _obj.shake_original_y     = _obj.y;
        _obj.shake_initialized    = true;
    }

    // --- State Machine ---
    switch (_obj.shake_state) {
        
        case 0: // IDLE
            _obj.shake_state       = 1; // Move to DELAY
            _obj.shake_delay_timer = start_delay;
            break;
            
        case 1: // DELAY
            _obj.shake_delay_timer--;
            if (_obj.shake_delay_timer <= 0) {
                _obj.shake_state          = 2; // Move to SHAKING
                _obj.shake_duration_timer = duration;
                _obj.shake_axis_mode      = axis_mode;
                _obj.shake_magnitude      = magnitude;
            }
            break;
            
        case 2: // SHAKING
            _obj.shake_duration_timer--;
            if (_obj.shake_duration_timer <= 0) {
                // Reset to original position
                _obj.x = _obj.shake_original_x;
                _obj.y = _obj.shake_original_y;
                _obj.shake_state = 0;
            } else {
                var _offset = random_range(-_obj.shake_magnitude, _obj.shake_magnitude);

                switch (_obj.shake_axis_mode) {
                    case "horizontal":
                        _obj.x = _obj.shake_original_x + _offset;
                        _obj.y = _obj.shake_original_y;
                        break;

                    case "vertical":
                        _obj.y = _obj.shake_original_y + _offset;
                        _obj.x = _obj.shake_original_x;
                        break;

                    case "random":
                        // Randomly decide axis each frame
                        if (choose(true, false)) {
                            _obj.x = _obj.shake_original_x + _offset;
                            _obj.y = _obj.shake_original_y;
                        } else {
                            _obj.y = _obj.shake_original_y + _offset;
                            _obj.x = _obj.shake_original_x;
                        }
                        break;
                }
            }
            break;
    }
}
