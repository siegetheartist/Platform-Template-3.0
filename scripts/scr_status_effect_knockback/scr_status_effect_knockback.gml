/// @function scr_status_effect_knockback(_target_instance, _attacker_x, _h_strength, _v_strength)
/// @description Applies a knockback effect to a target instance if not on cooldown.
/// @arg {id} _target_instance The instance to receive knockback (e.g., id, other).
/// @arg {real} _attacker_x The x-coordinate of the attacker. Used to determine knockback direction.
/// @arg {real} _h_strength The horizontal strength of the knockback impulse.
/// @arg {real} _v_strength The vertical strength of the knockback impulse (should be negative for upward).
function scr_status_effect_knockback(_target_instance, _attacker_x, _h_strength, _v_strength) {
    // Ensure target exists and is not currently on knockback cooldown.
    if (instance_exists(_target_instance) && _target_instance.knockback_cooldown_timer <= 0) {
        // Determine knockback direction based on attacker's position relative to target.
        // If target is to the right of attacker, knockback_dir will be 1 (right).
        // If target is to the left of attacker, knockback_dir will be -1 (left).
        var _knockback_dir = sign(_target_instance.x - _attacker_x);
 
        // Apply knockback impulse to the target's horizontal and vertical speeds.
        _target_instance.hsp = _knockback_dir * _h_strength;
        _target_instance.vsp = _v_strength;
 
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