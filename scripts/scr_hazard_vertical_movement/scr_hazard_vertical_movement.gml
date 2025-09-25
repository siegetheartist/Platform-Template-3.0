/// @function scr_hazard_vertical_movement()
/// @description Manages vertical movement cycle for a hazard instance.
///              Requires instance to have the following variables defined in its Create event:
///              - enum HazardVerticalMoveState
///              - vmove_state, vmove_timer
///              - y_start, y_target_up, vmove_up_distance
///              - vmove_windup_frames, vmove_windup_oscillation_amount
///              - vmove_move_up_lerp_factor, vmove_hold_up_frames,
///              - vmove_move_down_lerp_factor, vmove_pause_frames_min, vmove_pause_frames_max, vmove_randomize_pause_duration
/// @arg {asset.GMSound} snd_move_up The sound to play when the hazard starts moving up.
/// @arg {asset.GMSound} snd_move_down The sound to play when the hazard starts moving down.
function scr_hazard_vertical_movement(snd_move_up, snd_move_down) {
    var _inst = self; // Reference self for clarity
 
    switch (_inst.vmove_state) {
        case HazardVerticalMoveState.PAUSE:
            _inst.vmove_timer--;
            // Keep y at the start position during pause
            _inst.y = _inst.y_start;
            if (_inst.vmove_timer <= 0) {
                _inst.vmove_state = HazardVerticalMoveState.WINDUP;
                _inst.vmove_timer = _inst.vmove_windup_frames; // Reset timer for next windup
            }
            break;
 
        case HazardVerticalMoveState.WINDUP:
            _inst.vmove_timer--;
            // Apply visual oscillation around the stored y_start
            _inst.y = _inst.y_start + sin(current_time * 0.1) * _inst.vmove_windup_oscillation_amount;
 
            if (_inst.vmove_timer <= 0) {
                _inst.vmove_state = HazardVerticalMoveState.MOVING_UP;
                _inst.y = _inst.y_start; // Ensure it starts from y_start before lerping up
                
                // Play audio queue going up FROM THE EMITTER
                if (snd_move_up != noone) {
                    // Update the emitter's 3D position to match the trap's current position
                    audio_play_sound_on(spike_emitter, snd_move_up, false, 1);
                }
            }
            break;
 
        case HazardVerticalMoveState.MOVING_UP:
            _inst.y = lerp(_inst.y, _inst.y_target_up, _inst.vmove_move_up_lerp_factor);
            // Check if close enough to target Y to snap and transition
            if (abs(_inst.y - _inst.y_target_up) < 0.5) {
                _inst.y = _inst.y_target_up; // Snap to target
                _inst.vmove_state = HazardVerticalMoveState.HOLD_UP;
                // Use fixed hold duration
                _inst.vmove_timer = _inst.vmove_hold_up_frames;
            }
            break;
 
        case HazardVerticalMoveState.HOLD_UP:
            _inst.vmove_timer--;
            // Keep y at the target_up position during hold
            _inst.y = _inst.y_target_up;
            if (_inst.vmove_timer <= 0) {
                _inst.vmove_state = HazardVerticalMoveState.MOVING_DOWN;
                
                // Play audio queue going down FROM THE EMITTER
                if (snd_move_down != noone) {
                    // Update the emitter's 3D position to match the trap's current position
                    audio_play_sound_on(spike_emitter, snd_move_down, false, 1);
                }
            }
            break;
 
        case HazardVerticalMoveState.MOVING_DOWN:
            _inst.y = lerp(_inst.y, _inst.y_start, _inst.vmove_move_down_lerp_factor);
            // Check if close enough to start Y to snap and transition
            if (abs(_inst.y - _inst.y_start) < 0.5) {
                _inst.y = _inst.y_start; // Snap to start
                _inst.vmove_state = HazardVerticalMoveState.PAUSE; // Transition to PAUSE state
                // Apply pause duration based on randomization toggle
                if (_inst.vmove_randomize_pause_duration) {
                    _inst.vmove_timer = irandom_range(_inst.vmove_pause_frames_min, _inst.vmove_pause_frames_max);
                } else {
                    _inst.vmove_timer = _inst.vmove_pause_frames_min; // Use the min value as the fixed duration
                }
            }
            break;
    }
}
 