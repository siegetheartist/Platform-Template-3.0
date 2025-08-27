#region PLAYER DETECTION & STATE TRANSITION
// Find the player object (assuming it's named oPlayer)
var _player_instance = instance_find(oPlayer, 0); // Finds the first instance of oPlayer

// Decrement the alert cooldown timer
if (alert_cooldown_timer > 0) {
    alert_cooldown_timer--;
}

if (instance_exists(_player_instance)) {
    // Calculate the distance to the player
    var _distance_to_player = point_distance(x, y, _player_instance.x, _player_instance.y);
    
    // Check for line of sight to the player
    // This will return 'noone' if there's no oBlock between the enemy and the player
    var _line_of_sight_clear = !collision_line(x, y, _player_instance.x, _player_instance.y, oBlock, false, true);

    switch (enemy_state) {
        case ENEMY_STATE.PATROL:
            hsp_max = patrol_hsp_max; // Set horizontal speed for patrolling
            // Transition to ALERT if player is in range and line of sight is clear AND cooldown is over
            if (_distance_to_player < alert_range && _line_of_sight_clear && alert_cooldown_timer <= 0) {
                enemy_state = ENEMY_STATE.ALERT;
                alert_timer = alert_timeout; // Start the timer
            }
            break;

        case ENEMY_STATE.ALERT:
            hsp_max = 0; // Stop horizontal movement in ALERT state
            // Transition to CHASE if player is closer and line of sight is clear
            if (_distance_to_player < chase_range && _line_of_sight_clear) {
                enemy_state = ENEMY_STATE.CHASE;
            }
            // Transition back to PATROL if player is too far or line of sight is blocked
            else if (_distance_to_player > deaggro_range || !_line_of_sight_clear) {
                enemy_state = ENEMY_STATE.PATROL;
                alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
            }
            // Check if the alert timer has run out
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
            // Turn towards the player if chasing
            if (_player_instance.x < x) {
                current_dir = -1; // Player is to the left
            } else {
                current_dir = 1; // Player is to the right
            }
            // Transition back to ALERT if player moves out of chase range or line of sight is blocked
            if (_distance_to_player > chase_range || !_line_of_sight_clear) {
                enemy_state = ENEMY_STATE.ALERT;
                alert_timer = alert_timeout; // Restart the timer
            }
            // If player is very far, transition directly to PATROL (skipping ALERT)
            if (_distance_to_player > deaggro_range) {
                 enemy_state = ENEMY_STATE.PATROL;
                 alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
            }
            break;
    }
} else {
    // If no player exists, ensure the enemy is in patrol mode
    enemy_state = ENEMY_STATE.PATROL;
    hsp_max = patrol_hsp_max;
}
#endregion

#region MOVEMENT ACCELERATION / DECELERATION
// Calculate the target horizontal speed based on current direction and dynamic max speed
var _target_hsp = current_dir * hsp_max;

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

// Apply gravity to vertical speed
vsp += grav;
// Clamp vertical speed to prevent it from exceeding max falling speed
vsp = clamp(vsp, -vsp_max, vsp_max);
#endregion

#region EDGE DETECTION (Patrol Mode Only)
// Only perform edge detection when patrolling to prevent walking off platforms
if (enemy_state == ENEMY_STATE.PATROL) {
    // Calculate the position to check for ground ahead
    var _edge_check_x = x + (current_dir * _edge_check_offset);
    var _edge_check_y = y + _ground_check_offset;

    // If there is no solid block at the edge position, reverse direction
    if (!place_meeting(_edge_check_x, _edge_check_y, oBlock)) {
        current_dir *= -1; // Change direction
    }
}
#endregion

#region HORIZONTAL COLLISION
// Check for horizontal collision with solid blocks (oBlock)
if (place_meeting(x + hsp, y, oBlock)) {
    // Determine the direction of collision (pixel by pixel adjustment)
    var _pixel_step = sign(hsp);
    // Move the enemy back one pixel at a time until it's no longer colliding
    while (!place_meeting(x + _pixel_step, y, oBlock)) {
        x += _pixel_step;
    }
    hsp = 0; // Stop horizontal movement
    current_dir *= -1; // Reverse direction
}

// Check for horizontal collision with other bad entities/enemies (oBad)
// This will make enemies bounce off each other
if (place_meeting(x + hsp, y, oBad)) {
    // Determine the direction of collision (pixel by pixel adjustment)
    var _pixel_step = sign(hsp);
    // Move the enemy back one pixel at a time until it's no longer colliding
    while (!place_meeting(x + _pixel_step, y, oBad)) {
        x += _pixel_step;
    }
    hsp = 0; // Stop horizontal movement
    current_dir *= -1; // Reverse direction
}
#endregion

#region VERTICAL COLLISION
// Check for vertical collision with solid blocks (oBlock)
if (place_meeting(x, y + vsp, oBlock)) {
    // Determine the direction of collision (pixel by pixel adjustment)
    var _pixel_step = sign(vsp);
    // Move the enemy back one pixel at a time until it's no longer colliding
    while (!place_meeting(x, y + _pixel_step, oBlock)) {
        y += _pixel_step;
    }
    vsp = 0; // Stop vertical movement
}
#endregion

#region ANIMATION & SPRITE ORIENTATION
// Set the sprite based on the enemy's current state.
switch (enemy_state) {
    case ENEMY_STATE.PATROL:
    case ENEMY_STATE.ALERT:
        // Use the base enemy sprite for patrol and alert states.
        sprite_index = sEnemyPatrol;
        break;

    case ENEMY_STATE.CHASE:
        // Use the dedicated chase sprite for the chase state.
        if (sprite_exists(sEnemyChase)) {
            sprite_index = sEnemyChase;
        } else {
            // Fallback to the default sprite if the chase sprite is missing.
            sprite_index = sEnemyPatrol;
        }
        break;
}

// Flip the sprite horizontally based on the current direction.
if (current_dir == 1) {
    image_xscale = 1; // Face right
} else {
    image_xscale = -1; // Face left (flipped)
}

// Control animation speed based on horizontal movement.
if (hsp != 0) {
    // If moving, play the animation.
    image_speed = 1;
} else {
    // If not moving, stop the animation.
    image_speed = 0;
    image_index = 0; // Reset to first frame.
}
#endregion

#region FINAL MOVEMENT
// Apply the calculated horizontal and vertical speeds to the enemy's position
x += hsp;
y += vsp;
#endregion