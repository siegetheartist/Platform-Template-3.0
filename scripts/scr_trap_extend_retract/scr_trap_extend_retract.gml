/// @function                scr_hazard_extend_retract(direction, move_amount, type, [sounds_struct])
/// @description             Moves an object along an axis and then returns it. 100% self-contained with audio emitters.
/// @param {String}          direction       "up", "down", "left", or "right"
/// @param {Real}            move_amount     The number of pixels to move.
/// @param {String}          type            "auto_repeat" or "triggered".
/// @param {Struct}          [sounds_struct] Optional: A struct with sound assets { start, extend, retract }

function scr_trap_extend_retract(_direction, _move_amount, _type, _sounds = {}) {
    
    // --- ONE-TIME INITIALIZATION ---
    if (!variable_instance_exists(id, "hazard_initialized")) {
        
        // State machine
        enum HazardMoveState {
            IDLE,
            WINDUP,
            EXTENDING,
            HOLDING,
            RETURNING
        }
        hazard_state = HazardMoveState.IDLE;
        hazard_timer = 60;
        
        // Store positions
        hazard_start_x = x;
        hazard_start_y = y;
        hazard_target_x = x;
        hazard_target_y = y;
        
        switch (_direction) {
            case "up":    hazard_target_y -= _move_amount; break;
            case "down":  hazard_target_y += _move_amount; break;
            case "left":  hazard_target_x -= _move_amount; break;
            case "right": hazard_target_x += _move_amount; break;
        }

        // --- Configuration (All in one place) ---
        hazard_config = {
            extend_speed: 0.3,
            return_speed: 0.05,
            hold_time: 30,
            pause_time: 60,
            windup_time: 20,
            windup_shake: 2,
            sounds: {
                start: variable_struct_exists(_sounds, "start") ? _sounds.start : sndSpikeTrapStart,
                extend: variable_struct_exists(_sounds, "extend") ? _sounds.extend : sndSpikeTrapThrust,
                retract: variable_struct_exists(_sounds, "retract") ? _sounds.retract : sndSpikeTrapCrank
            }
        };
        
        // --- Audio Emitter Setup ---
        hazard_emitter = audio_emitter_create();
        audio_emitter_position(hazard_emitter, x, y, 0);
        audio_emitter_falloff(hazard_emitter, 150, 500, 1);
        audio_falloff_set_model(audio_falloff_exponent_distance_scaled);
        
        hazard_initialized = true;
    }
    
    // --- STATE MACHINE ---
        switch (hazard_state) {
            
            case HazardMoveState.IDLE:
        var _should_trigger = false;
        if (_type == "auto_repeat") {
            hazard_timer--;
            if (hazard_timer <= 0) {
                _should_trigger = true;
            }
        } 
        else if (_type == "triggered" && instance_exists(oPlayer)) {
            // Find the nearest player
            var _player_inst = instance_nearest(x, y, oPlayer);
            
            // Check if the player is within a x-pixel radius (DEPENDS ON YOUR MASK)
            if (point_distance(x, y, _player_inst.x, _player_inst.y) <= 66) {
                
                // Optional but recommended: Also check if the player is in the correct direction
                var _is_in_path = false;
                switch (_direction) {
                    case "up":    if (_player_inst.y < y) _is_in_path = true; break;
                    case "down":  if (_player_inst.y > y) _is_in_path = true; break;
                    case "left":  if (_player_inst.x < x) _is_in_path = true; break;
                    case "right": if (_player_inst.x > x) _is_in_path = true; break;
                }
                
                if (_is_in_path) {
                    _should_trigger = true;
                }
            }
        }
        
        // If a trigger condition was met, start the windup sequence
        if (_should_trigger) {
            hazard_state = HazardMoveState.WINDUP;
            hazard_timer = hazard_config.windup_time;
            if (hazard_config.sounds.start != noone) {
                audio_play_sound_on(hazard_emitter, hazard_config.sounds.start, false, 10);
            }
        }
        break;

        case HazardMoveState.WINDUP:
            hazard_timer--;
            // Shake effect
            x = hazard_start_x + random_range(-hazard_config.windup_shake, hazard_config.windup_shake);
            y = hazard_start_y + random_range(-hazard_config.windup_shake, hazard_config.windup_shake);
            
            if (hazard_timer <= 0) {
                x = hazard_start_x;
                y = hazard_start_y;
                hazard_state = HazardMoveState.EXTENDING;
                if (hazard_config.sounds.extend != noone) {
                    audio_play_sound_on(hazard_emitter, hazard_config.sounds.extend, false, 10);
                }
            }
            break;
            
        case HazardMoveState.EXTENDING:
            x = lerp(x, hazard_target_x, hazard_config.extend_speed);
            y = lerp(y, hazard_target_y, hazard_config.extend_speed);
            
            if (point_distance(x, y, hazard_target_x, hazard_target_y) < 1) {
                x = hazard_target_x;
                y = hazard_target_y;
                hazard_state = HazardMoveState.HOLDING;
                hazard_timer = hazard_config.hold_time;
            }
            break;
            
        case HazardMoveState.HOLDING:
            hazard_timer--;
            if (hazard_timer <= 0) {
                hazard_state = HazardMoveState.RETURNING;
                if (hazard_config.sounds.retract != noone) {
                    audio_play_sound_on(hazard_emitter, hazard_config.sounds.retract, false, 10);
                }
            }
            break;
            
        case HazardMoveState.RETURNING:
            x = lerp(x, hazard_start_x, hazard_config.return_speed);
            y = lerp(y, hazard_start_y, hazard_config.return_speed);
            
            if (point_distance(x, y, hazard_start_x, hazard_start_y) < 1) {
                x = hazard_start_x;
                y = hazard_start_y;
                hazard_state = HazardMoveState.IDLE;
                hazard_timer = hazard_config.pause_time;
            }
            break;
    }
}