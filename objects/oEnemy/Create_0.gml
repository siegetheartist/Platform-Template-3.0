// --- Enemy Parent Initialization Variables ---

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

#region ENEMY STATE AND BEHAVIOR SETTINGS
// Define the different states for the enemy
enum ENEMY_STATE {
    PATROL, // Default state: walks back and forth
    ALERT,  // Player spotted, but not yet chasing (e.g., investigating)
    CHASE,   // Chasing state: moves towards the player
    TAUNT    // NEW: Enemy is taunting after hitting the player
}

// Initialize the enemy's starting state
enemy_state = ENEMY_STATE.PATROL; // Sets the initial behavior state

// Define movement speeds for different states (children can override these)
patrol_hsp_max = 1; // Default slower speed for patrolling
chase_hsp_max = 3;  // Default faster speed for chasing

// Acceleration and deceleration values for smoother movement
hsp_accel = 0.1; // How quickly the enemy speeds up horizontally
hsp_decel = 0.3; // How quickly the enemy slows down horizontally

// Define detection ranges for player interaction (children can override these)
alert_range = 200; // Distance at which the enemy will enter ALERT state
chase_range = 150; // Distance at which the enemy will enter CHASE state (must be < alert_range)
deaggro_range = 250; // Distance at which the enemy will stop chasing/alerting and return to patrol

// New variables for the alert timeout
alert_timer = 0; // The current countdown timer for the alert state
alert_timeout = 120; // The total time (in frames) before the enemy returns to patrol (e.g., 2 seconds at 60 FPS)

// New variables for the alert cooldown
alert_cooldown_timer = 0; // A timer to prevent immediate re-alerting after de-aggro
alert_cooldown_time = 120; // The total time (in frames) before a new alert can be triggered (e.g., 2 seconds)

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

// --- ENEMY DAMAGE AND TAUNT SETTINGS (NEW) ---
enemy_damage = 1; // Default damage this enemy deals (children will override)
taunt_timer = 0; // Timer for how long the enemy is in the TAUNT state
taunt_duration = 60; // How long the enemy taunts (1 second at 60 FPS)
#endregion
