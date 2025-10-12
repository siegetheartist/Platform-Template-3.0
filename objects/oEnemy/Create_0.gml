//  Enemy Parent Initialization Variables 

#region INITIALIZATION
hsp = 0; // Horizontal speed (pixels per frame)
vsp = 0; // Vertical speed (pixels per frame)

reset_on_respawn = true; // default, but you can toggle per 

// New variables to store the enemy's starting position
start_x = x; // Stores the enemy's initial X position
start_y = y; // Stores the enemy's initial Y position

// Base horizontal speed will be overridden by state-specific max speeds
hsp_max = 0; // Current maximum horizontal speed (dynamically set by state)
vsp_max = 10; // Maximum falling speed to prevent excessive velocity

current_dir = 1; // 1 is right, -1 is left (initial movement direction)
grav = 0.4; // Gravity strength pulling the enemy down
#endregion

#region ENEMY STATS
// Enemy health
max_enemy_health = 10; // Default maximum health for this enemy type. Children can override.
enemy_health = max_enemy_health; // Current health, initialized to max.

// Enemy damage
enemy_damage = 1; // Default damage this enemy deals (children will override)

// In oEnemy Create Event
invulnerable_timer = 0;
invulnerable_duration = 30; // This is about 0.5 seconds, you can adjust as needed.

// Knockback resistance (how much this enemy *resists* incoming knockback - multiplier)
knockback_h_resistance = 1.0;  // 1.0 = full knockback, 0.75 = 25% reduction
knockback_v_resistance = 1.0; // 1.0 = full knockback, 0.75 = 25% reduction
knockback_active = false;  // True when the enemy is currently in the knockback animation/movement
knockback_cooldown_timer = 0; // Timer to prevent repeated knockbacks (1 second cooldown)
knockback_cooldown_duration = 60; // 1 second at 60 FPS
knockback_duration = 15; // Duration of the knockback effect (e.g., 0.25 seconds)
knockback_duration_timer = 0; // Current countdown for knockback duration
knockback_h_friction = 0.2; // Horizontal friction applied during knockback
 
// Knockback inflicted by this enemy's attacks (strength)
knockback_h_strength = 0; // Horizontal knockback amount inflicted by this enemy's attack
knockback_v_strength = 0; // Vertical knockback amount inflicted by this enemy's attack (negative for up)
#endregion

#region ENEMY STATE AND BEHAVIOR SETTINGS
// Define the different states for the enemy
enum ENEMY_STATE {
    PATROL, // Default state: walks back and forth
    ALERT,  // Player spotted, but not yet chasing (e.g., investigating)
    CHASE,   // Chasing state: moves towards the player
    TAUNT,    // Enemy is taunting after hitting the player
    WAIT_AND_TURN, // Enemy stops, waits, then turns around
    ATTACK,
    HURT,
    DEATH
}

// Initialize the enemy's starting state
enemy_state = ENEMY_STATE.PATROL; // Sets the initial behavior state
enemy_state_previous = ENEMY_STATE.PATROL; // NEW: Store previous state for sound logic
sound_played_for_current_state = false; // NEW: Flag to prevent sound spamming on state entry

// Define movement speeds for different states (children can override these)
patrol_hsp_max = 1; // Default slower speed for patrolling
chase_hsp_max = 3;  // Default faster speed for chasing

// Acceleration and deceleration values for smoother movement
hsp_accel = 0.08; // How quickly the enemy speeds up horizontally
hsp_decel = 0.8; // How quickly the enemy slows down horizontally

// Consolidated detection ranges
sight_distance = 200; // Distance for front-facing, line-of-sight detection (triggers CHASE)
behind_alert_distance = 150; // Distance for player detection from behind (triggers ALERT)
behind_chase_distance = 125; // Closer distance for player detection from behind (triggers CHASE)
default_close_chase_distance = 100; // General close proximity detection (triggers CHASE regardless of direction/LOS)
deaggro_distance_from_chase = 250; // Distance at which the enemy will stop chasing/alerting and return to patrol

// Alert timeout
alert_timer = 0; // The current countdown timer for the alert state
alert_timeout = 120; // The total time (in frames) before the enemy returns to patrol (e.g., 2 seconds at 60 FPS)

// Alert cooldown
alert_cooldown_timer = 0; // A timer to prevent immediate re-alerting after de-aggro
alert_cooldown_time = 60; // The total time (in frames) before a new alert can be triggered (e.g., 2 seconds)

// Offset for edge detection check. These will be calculated by child objects
// based on their specific sprite_width/height.
_edge_check_offset = 0; // Initialize, will be set by children
_ground_check_offset = 0; // Initialize, will be set by children

// Placeholder for the exclamation mark sprite. Children will set their specific sprite.
exclamation_sprite = -1; 

//  TAUNT SETTINGS
taunt_timer = 0; // Timer for how long the enemy is in the TAUNT state
taunt_duration = 60; // How long the enemy taunts (1 second at 60 FPS)
 
// NEW: Attack properties (children will override)
attack_range = 0;         // Distance to trigger an attack
attack_h_speed = 0;       // Horizontal speed applied during attack
attack_v_speed = 0;       // Vertical speed applied during attack (negative for jump)
attack_duration = 0;      // How long the attack state lasts (frames)
attack_timer = 0;         // Current countdown for the attack duration
attack_cooldown_timer = 0;
attack_cooldown_duration = 0;
can_attack_player = true; // Set to false when on cooldown

// Patrol stopping
patrol_stop_timer = 0; // Timer for the 1-second stop before turning
patrol_stop_duration = 60; // 1 second at 60 FPS
ledge_detect_distance = 48; // Distance from a ledge to trigger a stop and turn
enemy_detect_distance = 24; // Distance from another enemy to trigger a stop and turn

// Damage feedback variables
flash_timer = 0; // Timer for visual damage indicator (blinking)
flash_duration = 10; // How long the enemy sprite flashes after taking damage (0.5 seconds at 60 FPS)

// NEW: Variables for hit animation
is_hit_animating = false; // Flag to indicate if the enemy is currently playing a hit animation.
original_sprite_index = noone; // Stores the sprite_index before playing the hit animation.
original_image_speed = 1; // Stores the image_speed before playing the hit animation.
original_image_index = 0; // Stores the image_index before playing the hit animation.
#endregion

#region SPRITES + EFFECTS
// Placeholder sprite variables for animation (children will set these)
spr_idle = -1; // Stores the specific idle sprite for this enemy type.
spr_alerted = -1;
spr_patrol = -1; // Default sprite for moving during patrol/alert
spr_chase = -1;  // Default sprite for moving during chase
spr_taunt = -1; // NEW: Stores the specific taunt sprite for this enemy type.
spr_attack = -1; // NEW: Specific attack animation sprite
spr_hurt = -1;
spr_death = -1; // Placeholder for the death animation sprite
obj_death_effect = noone; // Placeholder for the death effect object
#endregion

// Sprite checks
_edge_check_offset = self.sprite_width / 2 + 2;
_ground_check_offset = 1;

#region AUDIO SETTINGS
snd_alert = noone;
snd_chase = noone;
snd_taunt = noone;
snd_hit = noone;
snd_death = noone;
snd_attack = noone;
#endregion