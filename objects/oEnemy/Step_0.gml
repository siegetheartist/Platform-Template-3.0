//  Enemy Parent Movement, AI, and Collision Logic 
 
#region VARIABLES
//  Get tilemap ID for collision 
var collision_tileset = layer_tilemap_get_id("t_Collision"); // Get the ID of the collision tilemap layer
 
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
#endregion
 
// Only AI logic and target_hsp calculation happens if not actively knocked back.
if (!knockback_active) {
 
    #region WAIT AND TURN LOGIC (PRIORITY OVER PLAYER DETECTION)
    // Handle WAIT_AND_TURN state first, as it's a temporary pause in other AI and detection.
    if (enemy_state == ENEMY_STATE.WAIT_AND_TURN) {
        hsp_max = 0; // Ensure no horizontal movement while waiting
        if (patrol_stop_timer <= 0) {
            current_dir *= -1; // Reverse direction after waiting
            enemy_state = ENEMY_STATE.PATROL; // Resume patrolling
        }
    }
    #endregion
 
    // Only proceed with player detection and AI if not in WAIT_AND_TURN state
    else {
        #region PLAYER DETECTION & STATE TRANSITION
        // Find the player object (assuming it's named oPlayer)
        _player_instance = instance_find(oPlayer, 0); // Finds the first instance of oPlayer
 
        if (instance_exists(_player_instance)) {
            // Calculate the distance to the player
            _distance_to_player = point_distance(x, y, _player_instance.x, _player_instance.y);
            
            // Calculate a more appropriate Y-coordinate for Line of Sight checks (e.g., center of sprite)
            var _enemy_los_y = y - (sprite_height / 2); // Enemy's vertical center
            var _player_los_y = _player_instance.y - (_player_instance.sprite_height / 2); // Player's vertical center
            
            // Check for line of sight to the player using the collision tilemap
            // The line should be from the enemy's vertical center to the player's vertical center,
            // avoiding collision with the ground they are standing on.
            _line_of_sight_clear = !collision_line(x, _enemy_los_y, _player_instance.x, _player_los_y, collision_tileset, false, true);
 
            // Determine if player is in front or behind based on enemy's current_dir
            _player_is_in_front = (sign(_player_instance.x - x) == current_dir);
            _player_is_behind = (sign(_player_instance.x - x) == -current_dir);
 
            // --- Player Detection and State Transition Logic (Ordered by Priority) ---
 
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
 
                    // Removed: current_dir = sign(_player_instance.x - x); // Enemy should not turn in ALERT state
 
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
                
                case ENEMY_STATE.TAUNT: // NEW: Handle Taunt state
                    hsp_max = 0; // Enemy stops all horizontal movement while taunting
                    if (taunt_timer <= 0) {
                        enemy_state = ENEMY_STATE.PATROL; // Return to patrol after taunt
                        alert_cooldown_timer = alert_cooldown_time; // Start cooldown before re-alerting
                    }
                    break;
            }
        } else {
            // If no player exists, ensure the enemy is in patrol mode
            enemy_state = ENEMY_STATE.PATROL;
            hsp_max = patrol_hsp_max;
        }
    }
    #endregion
 
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
} // End of !knockback_active block
 
#region MOVEMENT ACCELERATION / DECELERATION
if (knockback_active) {
    // Apply knockback-specific friction/deceleration
    if (abs(hsp) > knockback_h_friction) {
        hsp -= sign(hsp) * knockback_h_friction;
    } else {
        hsp = 0; // Snap to zero if movement is minimal
    }
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
 
// Resolve horizontal collision with other bad entities/enemies (oEnemy, parent object)
// This will make enemies bounce off each other without getting stuck.
if (place_meeting(x, y, oEnemy)) { // If colliding with any instance of oEnemy (including children)
    // Store the original intended direction of movement before reversing
    var _original_move_dir = sign(hsp); // Use current hsp to determine direction of collision
    if (_original_move_dir == 0) _original_move_dir = current_dir; // Fallback if hsp was 0
 
    hsp = 0; // Stop horizontal movement immediately
    if (!knockback_active) { // Only reverse direction if not actively knocked back
        current_dir *= -1; // Reverse direction (will start moving in new direction next frame)
    }
 
    // Push the enemy back one pixel in the opposite direction of its original movement
    // This immediately separates them to prevent re-collision in the next step. (Should be current_dir not original_move_dir if not changing dir during knockback)
    // No, _original_move_dir here is the direction of collision. It should still be correct.
    x -= _original_move_dir; 
}
#endregion
 
#region VERTICAL COLLISION
//  Vertical Movement and Collision Resolution 
 
// Check if currently on ground BEFORE applying movement for this frame
var _is_on_ground_before_move = place_meeting(x, y + 1, collision_tileset);
 
// If on ground, explicitly set vsp to 0 before applying frame's movement to prevent micro-vibrations
// UNLESS the enemy is currently being knocked back, in which case the knockback's vsp should apply.
if (_is_on_ground_before_move && !knockback_active) {
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