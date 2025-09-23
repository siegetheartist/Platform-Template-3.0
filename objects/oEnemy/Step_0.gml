//  Enemy Parent Movement, AI, and Collision Logic 
 
#region VARIABLES
//  Get tilemap ID for collision 
var _main_tileset = layer_tilemap_get_id("t_Collision"); // Get the ID of the collision tilemap layer
var collision_tileset = [_main_tileset, oInvisibleBlock, objBreakableWall]; // Get the ID of the collision tilemap layer
 
// Declare all local variables used within this step event
var _player_instance = noone; // Reference to the player object
var _distance_to_player = 0; // Distance from enemy to player
var _line_of_sight_clear = false; // True if enemy has clear sight to player
var _target_hsp = 0; // Desired horizontal speed based on current state
var _pixel_step = 0; // For pixel-by-pixel collision adjustment
 
// NEW: Variables for player relative position
var _player_is_in_front = false;
var _player_is_behind = false;
#endregion
 
#region TIMER MANAGEMENT (NEW)
//  Taunt Timer Management 
if (taunt_timer > 0) {
    taunt_timer--; // Decrement taunt timer
}
 
//  Flash Timer Management 
if (flash_timer > 0) {
    flash_timer--; // Decrement flash timer
}
 
//  Knockback Cooldown Timer Management (NEW)
if (knockback_cooldown_timer > 0) {
    knockback_cooldown_timer--;
}
// NEW: Knockback Duration Timer Management
if (knockback_duration_timer > 0) {
    knockback_duration_timer--;
}
 
//  Patrol Stop Timer Management (NEW)
if (patrol_stop_timer > 0) {
    patrol_stop_timer--;
}
 
// Decrement the alert cooldown timer
if (alert_cooldown_timer > 0) {
    alert_cooldown_timer--;
}
 
// NEW: Attack Timer Management
if (attack_timer > 0) {
    attack_timer--;
}
 
// NEW: Attack Cooldown Timer Management
if (attack_cooldown_timer > 0) {
    attack_cooldown_timer--;
    if (attack_cooldown_timer <= 0) {
        can_attack_player = true;
    }
}
#endregion
 
 
#region STATE SOUND LOGIC (NEW)
// Reset sound_played_for_current_state if the enemy's state has changed
if (enemy_state != enemy_state_previous) {
    sound_played_for_current_state = false;
}
#endregion
 
 
// Only AI logic and target_hsp calculation happens if not actively knocked back.
if (!knockback_active) {
 
    #region WAIT AND TURN LOGIC (PRIORITY OVER PLAYER DETECTION)
    // Handle WAIT_AND_TURN state first, as it's a temporary pause in other AI and detection.
    if (enemy_state == ENEMY_STATE.WAIT_AND_TURN) {
        hsp_max = 0; // Ensure no horizontal movement while waitinglol
        if (patrol_stop_timer <= 0) {
            current_dir *= -1; // Reverse direction after waiting
            enemy_state = ENEMY_STATE.PATROL; // Resume patrolling
        }
    }
    #endregion
 
    // Only proceed with player detection and AI if not in WAIT_AND_TURN state
    else {
        // PLAYER DETECTION & STATE TRANSITION
        // Find the player object
        _player_instance = instance_find(oPlayer, 0); // Finds the first instance of oPlayer
 
        if (instance_exists(_player_instance)) {
            // Calculate the distance to the player
            _distance_to_player = point_distance(x, y, _player_instance.x, _player_instance.y);
            
            // Calculate a Y-coordinate for Line of Sight checks 
            var _enemy_los_y = y - 2; // Enemy's vertical center bottom -2
            var _player_los_y = _player_instance.y - 2; // Player's vertical center bottom -2
            
            // Check for line of sight to the player using the collision tilemap
            // The line should be from the enemy's feet to the player feet,
            _line_of_sight_clear = !collision_line(x, _enemy_los_y, _player_instance.x, _player_los_y, collision_tileset, false, true);
 
            // Determine if player is in front or behind based on enemy's current_dir
            _player_is_in_front = (sign(_player_instance.x - x) == current_dir);
            _player_is_behind = (sign(_player_instance.x - x) == -current_dir);
 
            // --- Player Detection and State Transition Logic (Ordered by Priority) ---
            
            // NEW: Check for attack opportunity if conditions met and not currently attacking
            if (enemy_state != ENEMY_STATE.ATTACK && can_attack_player && _line_of_sight_clear) {
                // Player must be within attack range (children will define 'attack_range')
                if (_distance_to_player < attack_range) {
                    // Determine attack direction and initiate
                    current_dir = sign(_player_instance.x - x); // Face player
                    enemy_state = ENEMY_STATE.ATTACK;
                    
                    // On-entry logic for attack
                    hsp = current_dir * attack_h_speed; // Set initial horizontal speed
                    vsp = attack_v_speed;              // Set initial vertical speed (negative for upward)
                    image_index = 0;                   // Start attack animation from beginning
                    attack_timer = attack_duration;    // Start attack duration timer
                    
                    if (snd_attack != noone) {
                        audio_play_sound(snd_attack, 10, false);
                    }
                    
                    can_attack_player = false;           // Go on cooldown
                    attack_cooldown_timer = attack_cooldown_duration;
                }
            }
            
            // --- Original state transition logic (now adjusted to prioritize ATTACK) ---
            // If not in ATTACK state, proceed with other state transitions
            if (enemy_state != ENEMY_STATE.ATTACK) {
                // 1. HIGHEST PRIORITY: Default Close Chase (100px, visible, ANY state)
                if (_distance_to_player < default_close_chase_distance && _line_of_sight_clear) {
                    enemy_state = ENEMY_STATE.CHASE;
                    current_dir = sign(_player_instance.x - x); // Face player immediately
                }
                // 1.5. ALERT to CHASE escalation (if ALREADY in ALERT and player is close AND in front)
                else if (enemy_state == ENEMY_STATE.ALERT && _distance_to_player < default_close_chase_distance && _line_of_sight_clear && _player_is_in_front) {
                    enemy_state = ENEMY_STATE.CHASE;
                    current_dir = sign(_player_instance.x - x); // Face player immediately
                }
                // 2. Next Priority: Sight-Based Detection (250px, front, visible, NOT ALERT state)
                else if (enemy_state != ENEMY_STATE.ALERT && _distance_to_player < sight_distance && _line_of_sight_clear && _player_is_in_front) {
                    enemy_state = ENEMY_STATE.CHASE;
                    current_dir = sign(_player_instance.x - x); // Face player immediately
                }
                // 3. Next Priority: Behind Detection - Chase (125px, behind, visible, ANY state)
                else if (_distance_to_player < behind_chase_distance && _player_is_behind && _line_of_sight_clear) {
                    enemy_state = ENEMY_STATE.CHASE;
                    current_dir = sign(_player_instance.x - x); // Turn to face player immediately
                }
                // 4. Lowest Priority: Behind Detection - Alert (150px, behind, visible, PATROL state ONLY)
                else if (enemy_state == ENEMY_STATE.PATROL && _distance_to_player < behind_alert_distance && _player_is_behind && _line_of_sight_clear && alert_cooldown_timer <= 0) {
                    enemy_state = ENEMY_STATE.ALERT;
                    // current_dir = sign(_player_instance.x - x); // Removed: Enemy should not turn in ALERT state
                    alert_timer = alert_timeout; // Start the alert countdown timer
                }
            }
            // --- END PLAYER DETECTION LOGIC ---
 
            // Now handle state-specific logic based on the *current* enemy_state (which might have just changed)
            switch (enemy_state) {
                case ENEMY_STATE.PATROL:
                    hsp_max = patrol_hsp_max; // Set horizontal speed for patrolling
 
                    // NEW: Proactive Ledge Detection (only if not already stopping for another enemy)
                    var _proactive_ledge_check_x = x + (current_dir * ledge_detect_distance);
                    var _proactive_ledge_check_y = y + _ground_check_offset;
                    if (!place_meeting(_proactive_ledge_check_x, _proactive_ledge_check_y, collision_tileset)) {
                        enemy_state = ENEMY_STATE.WAIT_AND_TURN;
                        patrol_stop_timer = patrol_stop_duration;
                        hsp = 0; // Immediately stop horizontal movement
                    } else {
                        // NEW: Proactive Enemy Detection (only if not already stopping for a ledge)
                        var _check_left, _check_right, _check_top, _check_bottom;
                        
                        _check_top = bbox_top;
                        _check_bottom = bbox_bottom;
                        
                        // Create a detection rectangle extending from the front of the enemy
                        if (current_dir == 1) { // Facing right
                            _check_left = bbox_right; // Start at the current enemy's right edge
                            _check_right = bbox_right + enemy_detect_distance; // Extend forward by detect distance
                        } else { // Facing left
                            _check_right = bbox_left; // Start at the current enemy's left edge
                            _check_left = bbox_left - enemy_detect_distance; // Extend backward by detect distance
                        }
 
                        var _list = ds_list_create();
                        // Check for other enemies within the forward-facing rectangle
                        var _num_enemies = collision_rectangle_list(_check_left, _check_top, _check_right, _check_bottom, oEnemy, false, true, _list, false); // Added 'false' for ordered_by_distance
 
                        var _found_other_enemy = false;
                        if (_num_enemies > 0) {
                            for (var i = 0; i < _num_enemies; i++) {
                                if (_list[| i] != id) { // Make sure it's not 'self'
                                    _found_other_enemy = true;
                                    break;
                                }
                            }
                        }
                        ds_list_destroy(_list);
 
                        if (_found_other_enemy) {
                            enemy_state = ENEMY_STATE.WAIT_AND_TURN;
                            patrol_stop_timer = patrol_stop_duration;
                            hsp = 0; // Immediately stop horizontal movement
                        }
                    }
                    break;
 
                case ENEMY_STATE.ALERT:
                    hsp_max = 0; // Stop horizontal movement in ALERT state
                     
                    // Play alert sound
                    if (!sound_played_for_current_state && snd_alert != noone) {
                        audio_play_sound(snd_alert, 10, false);
                        sound_played_for_current_state = true;
                    }
 
                    // If player moves out of behind alert range OR line of sight is blocked OR alert timer runs out, revert to patrol
                    if (_distance_to_player > behind_alert_distance || !_line_of_sight_clear) {
                        enemy_state = ENEMY_STATE.PATROL;
                        alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
                    }
                    
                    if (alert_timer > 0) {
                        alert_timer--;
                    }
                    if (alert_timer <= 0) {
                        enemy_state = ENEMY_STATE.PATROL; // Time's up, go back to patrolling
                        alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
                    }
                    break;
 
                case ENEMY_STATE.CHASE:
                    hsp_max = chase_hsp_max; // Set horizontal speed for chasing
                    
                    // Play chase sound
                    if (!sound_played_for_current_state && snd_chase != noone) {
                        audio_play_sound(snd_chase, 10, false);
                        sound_played_for_current_state = true;
                    }
                
                    // Always turn towards the player when chasing
                    current_dir = sign(_player_instance.x - x);
                    
                    // De-aggro logic for CHASE state
                    var _is_chase_condition_met = 
                        (_distance_to_player < default_close_chase_distance && _line_of_sight_clear) || 
                        (_distance_to_player < sight_distance && _line_of_sight_clear && _player_is_in_front) || 
                        (_distance_to_player < behind_chase_distance && _player_is_behind && _line_of_sight_clear);
 
                    if (!_is_chase_condition_met || _distance_to_player > deaggro_distance_from_chase) { 
                        enemy_state = ENEMY_STATE.TAUNT; // Player escaped, enter TAUNT state
                        taunt_timer = taunt_duration; // Start taunt countdown
                        // Keep current_dir to face where player was seen last/escaped
                    }
                    break;
                
                case ENEMY_STATE.TAUNT: // Handle Taunt state
                    hsp_max = 0; // Enemy stops all horizontal movement while taunting
                    
                    // Play taunt sound
                    if (!sound_played_for_current_state && snd_taunt != noone) {
                        audio_play_sound(snd_taunt, 10, false);
                        sound_played_for_current_state = true;
                    }
 
                    if (taunt_timer <= 0) {
                        enemy_state = ENEMY_STATE.PATROL; // Return to patrol after taunt
                        alert_cooldown_timer = alert_cooldown_time; // Start cooldown before re-alerting
                    }
                    break;
                    
                case ENEMY_STATE.ATTACK: // NEW
                    hsp_max = 0; // Enemy's horizontal speed is governed by initial impulse, not hsp_max.
                    // Gravity and collisions still apply, affecting vsp.
        
                    if (attack_timer <= 0) {
                        // Attack animation/duration is over, transition back to CHASE or PATROL
                        // Check player distance again to decide next state
                        var _player_exists_after_attack = instance_exists(_player_instance);
                        if (_player_exists_after_attack && point_distance(x, y, _player_instance.x, _player_instance.y) < deaggro_distance_from_chase) {
                            enemy_state = ENEMY_STATE.CHASE;
                        } else {
                            enemy_state = ENEMY_STATE.PATROL;
                        }
                        sound_played_for_current_state = false; // Reset for new state
                    }
                    break;
            }
        } else {
            // If no player exists, ensure the enemy is in patrol mode
            enemy_state = ENEMY_STATE.PATROL;
            hsp_max = patrol_hsp_max;
        }
    }
} // End of !knockback_active block
 
#region EDGE DETECTION (Patrol Mode Only)
// Only perform edge detection when patrolling to prevent walking off platforms
if (enemy_state == ENEMY_STATE.PATROL) {
    // Calculate the position to check for ground ahead
    var _edge_check_x = x + (current_dir * _edge_check_offset);
    var _edge_check_y = y + _ground_check_offset;
 
    // If there is no solid tile at the edge position, reverse direction
    if (!place_meeting(_edge_check_x, _edge_check_y, collision_tileset)) {
        current_dir *= -1; // Change direction
    }
}
#endregion
 
#region MOVEMENT ACCELERATION / DECELERATION
if (knockback_active) {
    // Apply knockback-specific friction/deceleration
    if (abs(hsp) > knockback_h_friction) {
        hsp -= sign(hsp) * knockback_h_friction;
    } else {
        hsp = 0; // Snap to zero if movement is minimal
    }
} else if (enemy_state == ENEMY_STATE.ATTACK) {
    // In ATTACK state, hsp is set directly on state entry. 
    // No further acceleration/deceleration needed from this general block.
    // Only gravity and collision resolution will affect hsp/vsp.
} else { // Normal AI movement
    // Calculate the target horizontal speed based on current direction and dynamic max speed
    _target_hsp = current_dir * hsp_max;
 
    // If the enemy needs to change speed (either accelerate or decelerate)
    if (hsp != _target_hsp) {
        // If the target speed is 0 (e.g., in ALERT state or stopping), use deceleration
        if (_target_hsp == 0) {
            if (abs(hsp) < hsp_decel) { // If very close to 0, snap to 0
                hsp = 0;
            } else { // Decelerate towards 0
                hsp -= sign(hsp) * hsp_decel;
            }
        }    
        // Otherwise, accelerate towards the target speed
        else {
            if (abs(_target_hsp - hsp) < hsp_accel) { // If very close to target, snap to target
                hsp = _target_hsp;
            } else { // Accelerate towards target
                hsp += sign(_target_hsp - hsp) * hsp_accel;
            }
        }
    }
}
#endregion
 
// Apply gravity to vertical speed (always applies, even if knocked back)
vsp += grav;
// Clamp vertical speed to prevent it from exceeding max falling speed (always applies)
vsp = clamp(vsp, -vsp_max, vsp_max);
 
// Check if knockback should end (if it was active)
if (knockback_active) {
    // Knockback duration has expired
    if (knockback_duration_timer <= 0) {
        knockback_active = false;
        hsp = 0; // Snap to stop any residual knockback hsp
        vsp = 0; // Snap to stop any residual knockback vsp
 
        // --- Re-evaluate AI direction immediately after knockback ends. ---
        // This ensures the enemy resumes facing their target (player) if applicable.
        _player_instance = instance_find(oPlayer, 0); // Re-find player
        if (instance_exists(_player_instance)) {
            // Only update direction to face player if in CHASE state
            if (enemy_state == ENEMY_STATE.CHASE) { 
                current_dir = sign(_player_instance.x - x); // Face player
            }
        }
    }
} 
 
#region HORIZONTAL COLLISION
// Apply horizontal movement
x += hsp;
 
// Resolve horizontal collision with solid blocks (collision_tileset)
if (place_meeting(x, y, collision_tileset)) {
    // Determine the direction of collision (pixel by pixel adjustment)
    _pixel_step = sign(hsp);
    if (_pixel_step == 0) { // CRITICAL FIX: If hsp is 0 but still colliding, choose a direction to push out
        _pixel_step = current_dir; // Push out in the enemy's current facing/intended direction
        if (_pixel_step == 0) _pixel_step = 1; // Failsafe: if current_dir is also 0 (unlikely for patrolling)
    }
    // Move the enemy back one pixel at a time until it's no longer colliding
    while (place_meeting(x, y, collision_tileset)) { // While *still* colliding
        x -= _pixel_step;
    }
    hsp = 0; // Stop horizontal movement
    if (!knockback_active) { // Only reverse direction if not actively knocked back
        current_dir *= -1; // Reverse direction (bounce off tilemap wall)
    }
}
#endregion
 
#region VERTICAL COLLISION
//  Vertical Movement and Collision Resolution 
 
// Check if currently on ground BEFORE applying movement for this frame
var _is_on_ground_before_move = place_meeting(x, y + 1, collision_tileset);
 
// If on ground, explicitly set vsp to 0 before applying movement for this frame
// UNLESS the enemy is currently being knocked back, OR is in the ATTACK state initiating a leap.
if (_is_on_ground_before_move && !knockback_active && enemy_state != ENEMY_STATE.ATTACK) {
    vsp = 0;
}
 
// Apply vertical movement for this frame
y += vsp;
 
// Resolve vertical collision with solid blocks (collision_tileset)
if (place_meeting(x, y, collision_tileset)) {
    // Determine the direction of collision (pixel by pixel adjustment)
    _pixel_step = sign(vsp);
    if (_pixel_step == 0) { // CRITICAL FIX: If vsp is 0 but still colliding, push up as a default
        _pixel_step = -1; // Push up (against gravity)
    }
    // Move the enemy back one pixel at a time until it's no longer colliding
    while (place_meeting(x, y, collision_tileset)) { // While *still* colliding
        y -= _pixel_step;
    }
    vsp = 0; // Ensure vsp is zero after resolving collision
}
#endregion
 
// Update previous state for next frame's sound logic
enemy_state_previous = enemy_state;