//  Enemy Parent Initialization Variables 

#region INITIALIZATION
hsp = 0; // Horizontal speed (pixels per frame)
vsp = 0; // Vertical speed (pixels per frame)

// New variables to store the enemy's starting position
start_x = x; // Stores the enemy's initial X position
start_y = y; // Stores the enemy's initial Y position

// Base horizontal speed will be overridden by state-specific max speeds
hsp_max = 0; // Current maximum horizontal speed (dynamically set by state)
vsp_max = 10; // Maximum falling speed to prevent excessive velocity

current_dir = 1; // 1 is right, -1 is left (initial movement direction)
grav = 0.4; // Gravity strength pulling the enemy down
#endregion

#region ENEMY STATS // NEW: Add health to enemies
enemy_health = 10; // Default health for this enemy type. Children can override.
 
// Damage feedback variables
flash_timer = 0; // Timer for visual damage indicator (blinking)
flash_duration = 30; // How long the enemy sprite flashes after taking damage (0.5 seconds at 60 FPS)

// Knockback variables (NEW)
knockback_h_strength = 3;  // Horizontal knockback pixel amount (Increased for more effect)
knockback_v_strength = -2; // Vertical knockback pixel amount (Increased for more effect)
knockback_active = false;  // True when the enemy is currently in the knockback animation/movement
knockback_cooldown_timer = 0; // Timer to prevent repeated knockbacks (1 second cooldown)
knockback_cooldown_duration = 60; // 1 second at 60 FPS
knockback_duration = 15; // NEW: Duration of the knockback effect (e.g., 0.25 seconds)
knockback_duration_timer = 0; // NEW: Current countdown for knockback duration
knockback_h_friction = 0.2; // NEW: Horizontal friction applied during knockback
#endregion

#region ENEMY STATE AND BEHAVIOR SETTINGS
// Define the different states for the enemy
enum ENEMY_STATE {
    PATROL, // Default state: walks back and forth
    ALERT,  // Player spotted, but not yet chasing (e.g., investigating)
    CHASE,   // Chasing state: moves towards the player
    TAUNT,    // Enemy is taunting after hitting the player
    WAIT_AND_TURN // Enemy stops, waits, then turns around
}

// Initialize the enemy's starting state
enemy_state = ENEMY_STATE.PATROL; // Sets the initial behavior state

// Define movement speeds for different states (children can override these)
patrol_hsp_max = 1; // Default slower speed for patrolling
chase_hsp_max = 3;  // Default faster speed for chasing

// Acceleration and deceleration values for smoother movement
hsp_accel = 0.08; // How quickly the enemy speeds up horizontally
hsp_decel = 0.8; // How quickly the enemy slows down horizontally

// NEW: Consolidated detection ranges
sight_distance = 200; // Distance for front-facing, line-of-sight detection (triggers CHASE)
behind_alert_distance = 150; // Distance for player detection from behind (triggers ALERT)
behind_chase_distance = 125; // Closer distance for player detection from behind (triggers CHASE)
default_close_chase_distance = 100; // General close proximity detection (triggers CHASE regardless of direction/LOS)
deaggro_distance_from_chase = 250; // Distance at which the enemy will stop chasing/alerting and return to patrol

// New variables for the alert timeout
alert_timer = 0; // The current countdown timer for the alert state
alert_timeout = 120; // The total time (in frames) before the enemy returns to patrol (e.g., 2 seconds at 60 FPS)

// New variables for the alert cooldown
alert_cooldown_timer = 0; // A timer to prevent immediate re-alerting after de-aggro
alert_cooldown_time = 60; // The total time (in frames) before a new alert can be triggered (e.g., 2 seconds)

// Offset for edge detection check. These will be calculated by child objects
// based on their specific sprite_width/height.
_edge_check_offset = 0; // Initialize, will be set by children
_ground_check_offset = 0; // Initialize, will be set by children

// Placeholder for the exclamation mark sprite. Children will set their specific sprite.
exclamation_sprite = -1; 

// Placeholder sprite variables for animation (children will set these)
spr_idle_specific = -1; // Stores the specific idle sprite for this enemy type.
spr_patrol_move = -1; // Default sprite for moving during patrol/alert
spr_chase_move = -1;  // Default sprite for moving during chase
spr_taunt_specific = -1; // NEW: Stores the specific taunt sprite for this enemy type.

//  ENEMY DAMAGE AND TAUNT SETTINGS
enemy_damage = 1; // Default damage this enemy deals (children will override)
taunt_timer = 0; // Timer for how long the enemy is in the TAUNT state
taunt_duration = 60; // How long the enemy taunts (1 second at 60 FPS)


// NEW: Patrol stopping variables
patrol_stop_timer = 0; // Timer for the 1-second stop before turning
patrol_stop_duration = 60; // 1 second at 60 FPS
ledge_detect_distance = 48; // Distance from a ledge to trigger a stop and turn
enemy_detect_distance = 24; // Distance from another enemy to trigger a stop and turn
#endregion
