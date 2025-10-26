#region VARIABLES

collision_tileset_env = global.collision_environment;
 
// Declare all local variables
var _player_instance = instance_find(oPlayer, 0); // Reference to the player object
_on_ground = place_meeting(x, y + 1, collision_tileset_env);
var _distance_to_player = 0; // Distance from enemy to player
var _line_of_sight_clear = false; // True if enemy has clear sight to player
var _target_x_speed = 0; // Desired horizontal speed based on current state
var _pixel_step = 0; // For pixel-by-pixel collision adjustment
var _player_is_in_front = false;
var _player_is_behind = false;
#endregion


// --- HIGH PRIORITY CHECK: DEATH (Must run before timers) ---
if (enemy_health <= 0 && enemy_state != ENEMY_STATE.DEATH) { 
    enemy_state = ENEMY_STATE.DEATH; 
    state_initialized = false; 
}
 

#region STATUS EFFECT & TIMER MANAGEMENT
// Standard Timers (Taunt, Flash, Cooldowns, etc)
if (flash_timer > 0) { flash_timer--; }
if (knockback_cooldown_timer > 0) { knockback_cooldown_timer--; }
if (alert_cooldown_timer > 0) { alert_cooldown_timer--; }
if (attack_cooldown_timer > 0) {
    attack_cooldown_timer--;
    if (attack_cooldown_timer <= 0) {
        can_attack_player = true;
    }
}
if (knockback_active && knockback_duration_timer > 0) {
    knockback_duration_timer--; 
}
#endregion


#region PLAYER DETECTION 
if (enemy_state != ENEMY_STATE.DEATH) {
    if (instance_exists(_player_instance)) {

        _distance_to_player = point_distance(x, y, _player_instance.x, _player_instance.y);
        
        // Calculate a Y-coordinate for Line of Sight checks 
        var _enemy_los_y = y - 20; // Enemy's vertical center bottom -2
        var _player_los_y = _player_instance.y - 20; // Player's vertical center bottom -2
        
        // Check for line of sight to the player using the collision tilemap
        // The line should be from the enemy's feet to the player feet,
        _line_of_sight_clear = !collision_line(x, _enemy_los_y, _player_instance.x, _player_los_y, collision_tileset_env, false, true);
    
        // Determine if player is in front or behind
        _player_is_in_front = (sign(_player_instance.x - x) == current_dir);
        _player_is_behind = (sign(_player_instance.x - x) == -current_dir); 
    } else {
        // If no player exists, ensure AI defaults to patrol mode
        enemy_state = ENEMY_STATE.PATROL;
        state_initialized = false;
    }
}
#endregion


#region STATE TRANSITIONS - In order of priority

// --- HURT/KNOCKBACK --- Do BEFORE attack checks so a hit always interrupts an attack windup.
if (knockback_active && enemy_state != ENEMY_STATE.HURT) {
    // This is needed so HURT can return to the correct state (CHASE, PATROL, etc.).
    enemy_state_previous = enemy_state;
    enemy_state = ENEMY_STATE.HURT;
    state_initialized = false;
}


// --- ATTACK CHECK ---
if (enemy_state != ENEMY_STATE.ATTACK && enemy_state != ENEMY_STATE.HURT && can_attack_player && _line_of_sight_clear && instance_exists(_player_instance)) {
    if (_distance_to_player < attack_range) {
        current_dir = sign(_player_instance.x - x);
        enemy_state = ENEMY_STATE.ATTACK;
        state_initialized = false;
    }
}


// --- GENERAL AI TRANSITIONS ---
// Skip general transitions if currently in ATTACK or HURT (they handle their own exits).
if (enemy_state != ENEMY_STATE.ATTACK && enemy_state != ENEMY_STATE.HURT && instance_exists(_player_instance)) {
    
    // Helper function to initialize CHASE state transition
    function transition_to_chase() {
        // Only initialize if we are coming from a different state.
        if (enemy_state != ENEMY_STATE.CHASE) {
            enemy_state = ENEMY_STATE.CHASE;
            state_initialized = false;
        }
    }
    
    // 1. HIGHEST PRIORITY: Default Close Chase
    if (_distance_to_player < default_close_chase_distance && _line_of_sight_clear) {
        transition_to_chase();
        show_debug_message("Default close chase.");
    }
    // 1.5. ALERT to CHASE escalation
    else if (enemy_state == ENEMY_STATE.ALERT && _distance_to_player < default_close_chase_distance && _line_of_sight_clear && _player_is_in_front) {
        transition_to_chase();
        show_debug_message("ALERT -> CHASE");
    }
    // 2. Next Priority: Sight-Based Detection to chase
    else if (enemy_state != ENEMY_STATE.ALERT && _distance_to_player < sight_distance && _line_of_sight_clear && _player_is_in_front) {
        transition_to_chase();
        show_debug_message("Sight based detection PATROL -> CHASE.");
    }
    // 3. Next Priority: Behind Detection - Chase
    else if (_distance_to_player < behind_chase_distance && _player_is_behind && _line_of_sight_clear) {
        transition_to_chase();
        show_debug_message("Behind detection. PATROL -> Chase");
    }
    // 4. Lowest Priority: Behind Detection - Alert
    else if (enemy_state == ENEMY_STATE.PATROL && _distance_to_player < behind_alert_distance && _player_is_behind && _line_of_sight_clear && alert_cooldown_timer <= 0) {
        enemy_state = ENEMY_STATE.ALERT;
        state_initialized = false;
        show_debug_message("Behind detection. PATROL -> ALERT");
    }
    // De-aggro logic for CHASE state (must run AFTER all re-aggro logic)
    else if (enemy_state == ENEMY_STATE.CHASE) { 
        var _is_chase_condition_met = 
            (_distance_to_player < default_close_chase_distance && _line_of_sight_clear) || 
            (_distance_to_player < sight_distance && _line_of_sight_clear && _player_is_in_front) || 
            (_distance_to_player < behind_chase_distance && _player_is_behind && _line_of_sight_clear);

        if (!_is_chase_condition_met || _distance_to_player > deaggro_distance_from_chase) { 
            enemy_state = ENEMY_STATE.TAUNT;
            state_initialized = false;
            show_debug_message("CHASE -> TAUNT");
        }
    }
}
#endregion


#region ENEMY STATE MACHINE
switch (enemy_state) {
    case ENEMY_STATE.PATROL:
        x_speed_max = patrol_x_speed_max;

        if (!state_initialized) {
            sprite_index = spr_patrol;
            image_index = 0;
            image_speed = 1; 

            state_initialized = true;
        }
        
        function enemy_start_wait_and_turn() {
            enemy_state = ENEMY_STATE.WAIT_AND_TURN;
            state_initialized = false;
            
            // Halt horizontal movement immediately to prevent sliding into collision
            if (!knockback_active) { 
                x_speed = 0; 
            }
        }

        // --- PROACTIVE CHECKS (AI) ---
        // 1. Proactive Ledge Detection (Highest Priority)
        var _proactive_ledge_check_x = x + (current_dir * ledge_detect_distance);
        var _proactive_ledge_check_y = y + _ground_check_offset;
        var _proactive_wall_check_x = x + (current_dir * wall_detect_distance);
        
        if (!place_meeting(_proactive_ledge_check_x, _proactive_ledge_check_y, collision_tileset_env)) {
            // Ledge detected!
            enemy_start_wait_and_turn();
        } 
        
        // 2. Proactive Wall Detection
        else if (place_meeting(_proactive_wall_check_x, y, collision_tileset_env)) {
            // Wall detected!
            enemy_start_wait_and_turn();
        }

        // 3. Proactive Enemy Detection (Only runs if no Ledge or Wall was detected)
        else {
            var _check_left, _check_right, _check_top, _check_bottom;
            
            _check_top = bbox_top;
            _check_bottom = bbox_bottom;
            
            // Create a detection rectangle extending from the front of the enemy
            if (current_dir == 1) { // Facing right
                _check_left = bbox_right;
                _check_right = bbox_right + enemy_detect_distance;
            } else { // Facing left
                _check_right = bbox_left;
                _check_left = bbox_left - enemy_detect_distance;
            }

            var _list = ds_list_create();
            var _num_enemies = collision_rectangle_list(_check_left, _check_top, _check_right, _check_bottom, oEnemy, false, true, _list, false);

            var _found_other_enemy = false;
            if (_num_enemies > 0) {
                for (var i = 0; i < _num_enemies; i++) {
                    if (_list[| i] != id) {
                        _found_other_enemy = true;
                        break;
                    }
                }
            }
            ds_list_destroy(_list);

            if (_found_other_enemy) {
                enemy_start_wait_and_turn();
            }
        }
        
    break;
    case ENEMY_STATE.WAIT_AND_TURN:
        show_debug_message("ENEMY STATE: WAIT AND TURN");
        // Interupt WAIT_AND_TURN and enter CHASE if player is close enough during animation
        if (_distance_to_player < default_close_chase_distance && _line_of_sight_clear) {
            transition_to_chase();
            // Use 'break' to immediately exit the switch case and prevent the PATROL exit logic from running.
            break; 
        }
        x_speed_max = 0; // Ensure no horizontal movement while waiting
        
        if (!state_initialized) {
            sprite_index = spr_inspect;
            image_index = 0;
            image_speed = 1;
            state_initialized = true;
        }
        
        
        
        // Exit WAIT_AND_TURN. Enter PATROL
        if (image_index >= image_number - 1) {
            current_dir *= -1; // Reverse direction after waiting
            enemy_state = ENEMY_STATE.PATROL; // Resume patrolling
            state_initialized = false;
        }
        break;
    case ENEMY_STATE.ALERT:
        x_speed_max = 0;
        
        if (!state_initialized) {
            if (snd_alert != noone) { 
                audio_play_sound(snd_alert, 10, false); 
            }
            sprite_index = spr_alerted; 
            image_index = 0;
            image_speed = 1; 
            state_initialized = true;
        }
        
        
        // State Exit Logic (Handled in STATE TRANSITIONS region for ALERT/CHASE/PATROL)
        /*
        // If player moves out of behind alert range OR line of sight is blocked OR alert timer runs out, revert to patrol
        if (_distance_to_player > behind_alert_distance || !_line_of_sight_clear) {
            enemy_state = ENEMY_STATE.PATROL;
            alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
        }
        */
        
        if (image_index >= image_number - 1) {
            enemy_state = ENEMY_STATE.PATROL; // Time's up, go back to patrolling
            state_initialized = false;
            alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
        }
         

        break;
    case ENEMY_STATE.CHASE:
        if (instance_exists(oPlayer)) {
            current_dir = sign(oPlayer.x - x); // Continuously update direction towards the player.
        }
        x_speed_max = chase_x_speed_max;
        
        if (!state_initialized) {
            if (snd_chase != noone && enemy_state_previous != ENEMY_STATE.HURT) { 
                audio_play_sound(snd_chase, 10, false); 
            }
            sprite_index = spr_chase;
            image_index = 0;
            image_speed = 1;
            state_initialized = true;
        }
        break;
    case ENEMY_STATE.TAUNT:
        x_speed_max = 0;
        
        if (!state_initialized) {
            if (snd_taunt != noone) { audio_play_sound(snd_taunt, 10, false); }
            sprite_index = spr_taunt;
            image_index = 0;
            image_speed = 1;
            state_initialized = true;
        }

        if (image_index >= image_number - 1) {
            enemy_state = ENEMY_STATE.PATROL; // Return to patrol after taunt
            state_initialized = false;
            alert_cooldown_timer = alert_cooldown_time; // Start cooldown before re-alerting
        }
        break;
    case ENEMY_STATE.ATTACK:
        show_debug_message("ENEMY STATE: ATTACK");
        x_speed_max = 0; // Stop horizontal movement

        // --- STATE INITIALIZATION (Runs once) ---
        if (!state_initialized) {
            // Only start a new attack if the cooldown is over
            if (can_attack_player) {
                attack_finished = false; // Reset attack flag
                state_initialized = true;
                can_attack_player = false; // Prevent re-attacking immediately
                // The child object should set 'attack_cooldown_duration' in its Create Event
                attack_cooldown_timer = attack_cooldown_duration;
            } else {
                // If on cooldown, immediately transition out of the attack state
                // and chase the player if they are still nearby.
                if (instance_exists(oPlayer) && point_distance(x, y, oPlayer.x, oPlayer.y) < deaggro_distance_from_chase) {
                     enemy_state = ENEMY_STATE.CHASE;
                } else {
                     enemy_state = ENEMY_STATE.PATROL;
                }
                state_initialized = false;
            }
        }
    
        // --- DYNAMIC ATTACK BEHAVIOR ---
        if (state_initialized && !attack_finished) {
            if (enemy_attack_behavior != noone) {
                enemy_attack_behavior();
            }
        }
    
        // --- STATE EXIT LOGIC ---
        if (attack_finished) {
            // Attack is over, decide what to do next based on player position.
            var _player_exists = instance_exists(oPlayer);
            if (_player_exists && point_distance(x, y, oPlayer.x, oPlayer.y) < deaggro_distance_from_chase) {
                // If player is out of attack range but still close, chase them.
                enemy_state = ENEMY_STATE.CHASE;
                state_initialized = false;
            } else {
                // If player is far away or gone, go back to patrolling.
                enemy_state = ENEMY_STATE.PATROL;
                state_initialized = false;
            }
        }
        break;
    case ENEMY_STATE.HURT:
        x_speed_max = 0;
        if (!state_initialized) {
            if (snd_hurt != noone) { 
                audio_play_sound(snd_hurt, 10, false); 
            }
            sprite_index = spr_hurt; // Show the hit animation
            image_index = 0;
            image_speed = 1;
            // The drawing is handled by the Draw Event using the flash_timer
            state_initialized = true;
        }

        // Transition out of HURT once the physics override is finished
        if (!knockback_active && _on_ground) {
            enemy_state = enemy_state_previous;
            enemy_state_previous = ENEMY_STATE.HURT; // Use in other states to prevent loops.
            state_initialized = false;
        }
        break;
    case ENEMY_STATE.DEATH:
        // Stop all movement immediately
        x_speed = 0;
        y_speed = 0;
                
        // On the first frame of entering the death state...
        if (!state_initialized) {
            // Play death sound
            if (snd_death != noone) {
                audio_play_sound(snd_death, 10, false);
            }
    
            // Change to death sprite and start animation
            if (spr_death != -1) {
                sprite_index = spr_death;
                image_index = 0;
                image_speed = 1;
                mask_index = sprNoCollision;
            }
            
            // Spawn the death effect object
            if (obj_death_effect != noone) {
                instance_create_layer(x, y, "alForeground", obj_death_effect);
            }
            
            state_initialized = true; 
        }
    
        // --- Destruction Logic ---
        // 1. If there's a death animation, wait for it to finish.
        if (sprite_index == spr_death) {
            if (image_index >= image_number - 1) {
                instance_destroy();
            }
            return; // Don't run anymore code. enemy is dead. Just finish animating.
        }
        // 2. Fallback: If no animation destroy immediately.
        else {
            instance_destroy();
        }
        break;
}
#endregion

 
#region EDGE DETECTION - prevent walking off platforms
if (enemy_state == ENEMY_STATE.PATROL && !knockback_active && enemy_state != ENEMY_STATE.ATTACK) {
    var _edge_check_x = x + (current_dir * _edge_check_offset);
    var _edge_check_y = y + _ground_check_offset;
 
    if (!place_meeting(_edge_check_x, _edge_check_y, collision_tileset_env)) {
        current_dir *= -1;
    }
}
#endregion


#region MOVEMENT ACCELERATION / DECELERATION
if (knockback_active) {
    // KNOCKBACK MOVEMENT: Apply friction to quickly stop horizontal movement.
    if (abs(x_speed) > knockback_h_friction) {
        x_speed -= sign(x_speed) * knockback_h_friction;
    } else {
        x_speed = 0; // Snap to zero if movement is minimal
    }
} else if (enemy_state == ENEMY_STATE.ATTACK) {
    // x_speed/y_speed is set directly on state entry. No further manipulation here.
} else { // Normal AI movement
    _target_x_speed = current_dir * x_speed_max;
 
    // If the enemy needs to change speed (either accelerate or decelerate)
    if (x_speed != _target_x_speed) {
        // If the target speed is 0 (e.g., in ALERT state or stopping), use deceleration
        if (_target_x_speed == 0) {
            if (abs(x_speed) < x_speed_decel) { // If very close to 0, snap to 0
                x_speed = 0;
            } else { // Decelerate towards 0
                x_speed -= sign(x_speed) * x_speed_decel;
            }
        }    
        // Otherwise, accelerate towards the target speed
        else {
            if (abs(_target_x_speed - x_speed) < x_speed_accel) { // If very close to target, snap to target
                x_speed = _target_x_speed;
            } else { // Accelerate towards target
                x_speed += sign(_target_x_speed - x_speed) * x_speed_accel;
            }
        }
    }
}
#endregion
 

#region VERTICAL SPEED / GRAVITY & KNOCKBACK CLEANUP
// Apply gravity and clamp speed (always applies)
y_speed += grav;
y_speed = clamp(y_speed, -y_speed_max, y_speed_max);
 
// Knockback Duration Cleanup (PHYSICS OVERRIDE EXIT)
if (knockback_active && knockback_duration_timer <= 0) {
    knockback_active = false;
    x_speed = 0; // Snap to stop any residual physics movement
    y_speed = 0; // Snap to stop any residual physics movement
 
    // Re-evaluate AI direction immediately after knockback ends.
    if (instance_exists(_player_instance)) {
        if (enemy_state == ENEMY_STATE.CHASE) { 
            current_dir = sign(_player_instance.x - x);
        }
    }
}

// If on ground, only set y_speed=0 if NOT actively being knocked or performing an attack leap.
if (_on_ground && !knockback_active && enemy_state != ENEMY_STATE.ATTACK) {
    y_speed = 0;
}
#endregion

// need to modify new player movement for use
// Commit to movement
//scr_move_and_collide(collision_tileset_env);


// Flip the sprite horizontally based on the current direction.
if (current_dir == 1) {
    image_xscale = 1; // Face right
} else {
    image_xscale = -1; // Face left (flipped)
}
