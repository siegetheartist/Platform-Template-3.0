/// @function scr_obj_shake(start_delay, duration, magnitude, is_horizontal);
/// @description Shakes an object after a delay. Fully self-contained.
/// @param {Real} start_delay        The delay in frames before the shaking starts.
/// @param {Real} duration           How long the shake should last, in frames.
/// @param {Real} magnitude          The maximum pixel offset for the shake.
/// @param {Boolean} is_horizontal   True for horizontal shake, false for vertical.

function scr_obj_shake(start_delay, duration, magnitude, is_horizontal) {
    
    // --- One-Time Initialization ---
    // This block runs only once per instance to set up all necessary variables.
    if (!variable_instance_exists(id, "shake_initialized")) {
        shake_state = 0; // 0 = IDLE, 1 = DELAY, 2 = SHAKING
        shake_delay_timer = 0;
        shake_duration_timer = 0;
        shake_original_x = x;
        shake_original_y = y;
        shake_initialized = true;
    }
    
    // --- State Machine ---
    switch (shake_state) {
        
        case 0: // IDLE
            // In the idle state, we wait for the function to be called to start the process.
            // When called from the Step event, we immediately move to the DELAY state.
            shake_state = 1; // Move to DELAY
            shake_delay_timer = start_delay;
            break;
            
        case 1: // DELAY
            // Countdown the initial delay before the shaking begins.
            shake_delay_timer--;
            if (shake_delay_timer <= 0) {
                shake_state = 2; // Move to SHAKING
                shake_duration_timer = duration;
            }
            break;
            
        case 2: // SHAKING
            // Countdown the duration of the shake.
            shake_duration_timer--;
            if (shake_duration_timer <= 0) {
                // Shake is over. Reset to original position and return to IDLE.
                x = shake_original_x;
                y = shake_original_y;
                shake_state = 0; // Back to IDLE
            } else {
                // Apply the shake effect.
                var _offset = random_range(-magnitude, magnitude);
                if (is_horizontal) {
                    x = shake_original_x + _offset;
                } else {
                    y = shake_original_y + _offset;
                }
            }
            break;
    }
}