#region INITIALIZATION
hsp = 0; // Horizontal speed
vsp = 0; // Vertical speed

// New variables to store the enemy's starting position
start_x = x;
start_y = y;

// Initialize hsp_max here to prevent warnings. Its actual value will be set by the state machine.
hsp_max = 0; // Base horizontal speed (will be overridden by patrol_hsp_max or chase_hsp_max)
vsp_max = 10; // Maximum falling speed

current_dir = 1; // 1 is right, -1 is left (initial direction)
grav = 0.4; // Gravity strength
#endregion

#region ENEMY STATE AND BEHAVIOR SETTINGS
// Define the different states for the enemy
enum ENEMY_STATE {
    PATROL, // Default state: walks back and forth
    ALERT,  // Player spotted, but not yet chasing (e.g., investigating)
    CHASE   // Chasing state: moves towards the player
}

// Initialize the enemy's starting state
enemy_state = ENEMY_STATE.PATROL;

// Define movement speeds for different states
patrol_hsp_max = 1; // Slower speed for patrolling
chase_hsp_max = 3;  // Faster speed for chasing

// Acceleration and deceleration values for smoother movement
hsp_accel = 0.1; // How quickly the enemy speeds up
hsp_decel = 0.2; // How quickly the enemy slows down (can be faster to stop quickly)

// Define detection ranges for player interaction
alert_range = 200; // Distance at which the enemy will enter ALERT state
chase_range = 150; // Distance at which the enemy will enter CHASE state (must be < alert_range)
deaggro_range = 250; // Distance at which the enemy will stop chasing/alerting and return to patrol

// New variables for the alert timeout
alert_timer = 0; // The current countdown timer for the alert state
alert_timeout = 240; // The total time (in frames) before the enemy returns to patrol (e.g., 4 seconds at 60 FPS)

// New variables for the alert cooldown
alert_cooldown_timer = 0; // A timer to prevent immediate re-alerting
alert_cooldown_time = 180; // The total time (in frames) before a new alert can be triggered (e.g., 3 seconds)

// Offset for edge detection check. Adjust based on sprite width.
// This checks slightly ahead of the enemy's current position.
_edge_check_offset = sprite_width / 2 + 2; 
// Distance below the enemy to check for ground. Adjust based on sprite height.
_ground_check_offset = sprite_height / 2 + 1;

// Exclamation mark sprite - make sure you have a sprite named `spr_exclamation`
// You can make a simple '!' sprite, and we'll change its color dynamically.
// If you don't have this, create a simple sprite for it.
if (sprite_exists(spr_exclamation)) {
    exclamation_sprite = spr_exclamation;
} else {
    // Fallback if the sprite doesn't exist, will just draw nothing.
    // Or you could create a simple square/circle for debugging.
    exclamation_sprite = -1; 
    show_debug_message("Warning: spr_exclamation not found for enemy alarm indicator!");
}
#endregion