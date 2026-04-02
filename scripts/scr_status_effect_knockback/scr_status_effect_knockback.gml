/// @function scr_status_effect_knockback(_target_instance, _attacker_x, _inflicting_h_strength, _inflicting_v_strength)
/// @description Applies a knockback effect to a target instance if not on cooldown, considering target's resistance.
/// @arg {id} _target_instance The instance to receive knockback (e.g., id, other).
/// @arg {real} _attacker_x The x-coordinate of the attacker. Used to determine knockback direction.
/// @arg {real} _inflicting_h_strength The raw horizontal strength of the knockback impulse to be inflicted.
/// @arg {real} _inflicting_v_strength The raw vertical strength of the knockback impulse to be inflicted (should be negative for upward).
function scr_status_effect_knockback(_target_instance, _attacker_x, _inflicting_h_strength, _inflicting_v_strength) {
    // Ensure target exists and is not currently on knockback cooldown.
    if (instance_exists(_target_instance) && _target_instance.knockback_cooldown_timer <= 0) {
        // Determine knockback direction based on attacker's position relative to target.
        // If target is to the right of attacker, knockback_dir will be 1 (right).
        // If target is to the left of attacker, knockback_dir will be -1 (left).
        var _knockback_dir = sign(_target_instance.x - _attacker_x);
        
        // Apply target's resistance multipliers to the incoming knockback strengths.
        var _final_h_strength = _inflicting_h_strength;
        var _final_v_strength = _inflicting_v_strength;
        
        if (variable_instance_exists(_target_instance, "knockback_h_resistance")) {
            _final_h_strength *= _target_instance.knockback_h_resistance;
        }
        if (variable_instance_exists(_target_instance, "knockback_v_resistance")) {
            _final_v_strength *= _target_instance.knockback_v_resistance;
        }
 
        // Apply knockback impulse to the target's horizontal and vertical speeds.
        _target_instance.hsp = _knockback_dir * _final_h_strength;
        _target_instance.vsp = _final_v_strength;
 
        // Activate the knockback state and set up its duration and cooldown timers.
        _target_instance.knockback_active = true;
        _target_instance.knockback_duration_timer = _target_instance.knockback_duration;
        _target_instance.knockback_cooldown_timer = _target_instance.knockback_cooldown_duration;
        
        // Ensure knockback duration timer is at least 1, so the knockback effect applies for at least one frame.
        if (_target_instance.knockback_duration_timer <= 0) {
             _target_instance.knockback_duration_timer = 1;
        }
    }
}