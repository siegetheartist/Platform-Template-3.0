/// @function scr_shake_initialize(_instance, _magnitude, _duration, _horizontal) 
/// @description Applies a shake effect to a given instance. 
/// @arg {id} _instance The instance to shake. 
/// /// @arg {real} _magnitude The maximum offset in pixels for the shake. 
/// /// @arg {real} _duration The duration of the shake effect in frames. 
/// /// @arg {boolean} _horizontal True for horizontal shake, false for vertical. 

function scr_shake_initialize(_instance, _magnitude, _duration, _horizontal) { 
    if (instance_exists(_instance)) { 

        show_debug_message("Initialize ");
        // Store the instance's current *actual* position as the origin for shaking. 
        // This is important if the object is already moving or positioned away from its creation (x,y). 
        _instance.original_x = _instance.x; 
        _instance.original_y = _instance.y; 
        _instance.is_shaking = true; 
        _instance.shake_magnitude = _magnitude; 
        _instance.shake_duration_max = _duration; 
        
        // Store max duration to calculate decay 
        _instance.shake_timer = _duration; 
        _instance.shake_horizontal = _horizontal; 
    } 
}