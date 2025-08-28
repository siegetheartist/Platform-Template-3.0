// --- Enemy Parent Movement, AI, and Collision Logic ---

#region VARIABLES
// --- Get tilemap ID for collision ---
var collision_tileset = layer_tilemap_get_id("t_Collision"); // Get the ID of the collision tilemap layer

// Declare all local variables used within this step event
var _player_instance = noone; // Reference to the player object
var _distance_to_player = 0; // Distance from enemy to player
var _line_of_sight_clear = false; // True if enemy has clear sight to player
var _target_hsp = 0; // Desired horizontal speed based on current state
var _pixel_step = 0; // For pixel-by-pixel collision adjustment
#endregion

#region PLAYER DETECTION & STATE TRANSITION
// Find the player object (assuming it's named oPlayer)
_player_instance = instance_find(oPlayer, 0); // Finds the first instance of oPlayer

// Decrement the alert cooldown timer
if (alert_cooldown_timer > 0) {
    alert_cooldown_timer--;
}

if (instance_exists(_player_instance)) {
    // Calculate the distance to the player
    _distance_to_player = point_distance(x, y, _player_instance.x, _player_instance.y);
    
    // Check for line of sight to the player using the collision tilemap
    _line_of_sight_clear = !collision_line(x, y, _player_instance.x, _player_instance.y, collision_tileset, false, true);

    switch (enemy_state) {
        case ENEMY_STATE.PATROL:
            hsp_max = patrol_hsp_max; // Set horizontal speed for patrolling
            // Transition to ALERT if player is in range and line of sight is clear AND cooldown is over
            if (_distance_to_player < alert_range && _line_of_sight_clear && alert_cooldown_timer <= 0) {
                enemy_state = ENEMY_STATE.ALERT;
                alert_timer = alert_timeout; // Start the alert countdown timer
                // show_debug_message("ENEMY STATE CHANGE: PATROL -> ALERT"); // Debug: Uncomment to see state changes
            }
            break;

        case ENEMY_STATE.ALERT:
            hsp_max = 0; // Stop horizontal movement in ALERT state
            // Transition to CHASE if player is closer and line of sight is clear
            if (_distance_to_player < chase_range && _line_of_sight_clear) {
                enemy_state = ENEMY_STATE.CHASE;
                // show_debug_message("ENEMY STATE CHANGE: ALERT -> CHASE"); // Debug: Uncomment to see state changes
            }
            // Transition back to PATROL if player is too far or line of sight is blocked
            else if (_distance_to_player > deaggro_range || !_line_of_sight_clear) {
                enemy_state = ENEMY_STATE.PATROL;
                alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
                // show_debug_message("ENEMY STATE CHANGE: ALERT -> PATROL (De-aggro/LOS Blocked)"); // Debug: Uncomment to see state changes
            }
            // Check if the alert timer has run out
            if (alert_timer > 0) {
                alert_timer--;
            }
            if (alert_timer <= 0) {
                enemy_state = ENEMY_STATE.PATROL; // Time's up, go back to patrolling
                alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
                // show_debug_message("ENEMY STATE CHANGE: ALERT -> PATROL (Timeout)"); // Debug: Uncomment to see state changes
            }
            break;

        case ENEMY_STATE.CHASE:
            hsp_max = chase_hsp_max; // Set horizontal speed for chasing
            // Turn towards the player if chasing
            if (_player_instance.x < x) {
                current_dir = -1; // Player is to the left, face left
            } else {
                current_dir = 1; // Player is to the right, face right
            }
            // Transition back to ALERT if player moves out of chase range or line of sight is blocked
            if (_distance_to_player > chase_range || !_line_of_sight_clear) {
                enemy_state = ENEMY_STATE.ALERT;
                alert_timer = alert_timeout; // Restart the alert countdown timer
                // show_debug_message("ENEMY STATE CHANGE: CHASE -> ALERT (Range/LOS Blocked)"); // Debug: Uncomment to see state changes
            }
            // If player is very far, transition directly to PATROL (skipping ALERT)
            if (_distance_to_player > deaggro_range) {
                enemy_state = ENEMY_STATE.PATROL;
                alert_cooldown_timer = alert_cooldown_time; // Start the cooldown timer
                // show_debug_message("ENEMY STATE CHANGE: CHASE -> PATROL (De-aggro)"); // Debug: Uncomment to see state changes
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

    // If there is no solid tile at the edge position, reverse direction
    if (!place_meeting(_edge_check_x, _edge_check_y, collision_tileset)) {
        current_dir *= -1; // Change direction
    }
}
#endregion

#region HORIZONTAL COLLISION
// Apply horizontal movement
x += hsp;

// Resolve horizontal collision with solid blocks (collision_tileset)
if (place_meeting(x, y, collision_tileset)) {
    // Determine the direction of collision (pixel by pixel adjustment)
    _pixel_step = sign(hsp);
    // Move the enemy back one pixel at a time until it's no longer colliding
    while (place_meeting(x, y, collision_tileset)) { // While *still* colliding
        x -= _pixel_step;
    }
    hsp = 0; // Stop horizontal movement
    current_dir *= -1; // Reverse direction (bounce off tilemap wall)
}

// Resolve horizontal collision with other bad entities/enemies (oEnemy, parent object)
// This will make enemies bounce off each other without getting stuck.
// IMPORTANT: For dynamic instances, avoid pixel-by-pixel `while` loops to prevent deadlocks.
if (place_meeting(x, y, oEnemy)) { // If colliding with any instance of oEnemy (including children)
    hsp = 0; // Stop horizontal movement immediately
    current_dir *= -1; // Reverse direction
}
#endregion

#region VERTICAL COLLISION
// --- Vertical Movement and Collision Resolution ---

// Check if currently on ground BEFORE applying movement for this frame
var _is_on_ground_before_move = place_meeting(x, y + 1, collision_tileset);

// If on ground, explicitly set vsp to 0 before applying frame's movement to prevent micro-vibrations
if (_is_on_ground_before_move) {
    vsp = 0;
}

// Apply vertical movement for this frame
y += vsp;

// Resolve vertical collision with solid blocks (collision_tileset)
if (place_meeting(x, y, collision_tileset)) {
    // Determine the direction of collision (pixel by pixel adjustment)
    _pixel_step = sign(vsp);
    // Move the enemy back one pixel at a time until it's no longer colliding
    while (place_meeting(x, y, collision_tileset)) { // While *still* colliding
        y -= _pixel_step;
    }
    vsp = 0; // Ensure vsp is zero after resolving collision
}
#endregion
