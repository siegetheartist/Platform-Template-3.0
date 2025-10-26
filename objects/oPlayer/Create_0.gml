#region PLAYER HEALTH AND INVULNERABILITY
// Initialize player health in OgameManager. 
player_health = oGameManager.max_player_health; // Stores players current health and is updated in scr_apply_damage script
invulnerable_timer = 0; // Timer for player invulnerability frames
invulnerable_duration = 60; // How many frames player is invulnerable after taking damage (1 second at 60 FPS)
flash_timer = 0; // Timer for visual damage indicator (blinking)
flash_duration = 30; // How long the player sprite flashes after taking damage (0.5 seconds at 60 FPS)
#endregion


// dead = false; // Have this set itself if made into a script


#region ATTACK MECHANICS
attack_timer = 0; // Timer for the attack animation
attack_duration = 18; // Duration of the attack state in frames (adjust as needed for sPlayerAttack sprite)
current_attack_slash = noone; // Stores the ID of the created oPlayerAttackSlash instance
attack_slash_desired_gap = -34; // Sets the distance between the player and the slash
#endregion


#region CINEMATIC CONTROL
// Determines whether the player can move or act (used during cutscenes or transitions)
can_control = false;
#endregion


#region BASE MOVEMENT 
// Horizontal speedS
x_speed = 0; // Horizontal speed (pixels per frame)
max_x_speed = 2.50; // Maximum horizontal speed the player can reach (Original speed 3)

// vertical speedS
y_speed = 0; // Vertical speed (pixels per frame)

// Acceleration and deceleration for smooth movement
accel = 0.3; // Rate at which horizontal speed increases
decel = 0.5; // Rate at which horizontal speed decreases
#endregion


#region GRAVITY SETTINGS
// Gravity settings for normal falling
grav = 0.2; // Strength of gravity pulling the player down
grav_max = 10; // Maximum vertical speed due to normal gravity

// Gravity settings while sliding on a wall
grav_wall = 0.1; // Reduced gravity strength for wall sliding
grav_wall_max = 3.25; // Maximum vertical speed while wall sliding
#endregion


#region JUMPING MECHANICS
// Distance to check below player for ground detection
ground_check_dist = 12; // Pixels below player to check for solid ground

// Jumping
jump_height_min = -1.5; // Minimum upward velocity when jump key is released early
jump_height = -4.5; // Initial upward velocity for a full jump

// Frames to buffer jump input before landing
jump_buffer_max = 4; // Max frames to buffer a jump input (immediately derements 1 in the same frame. so add 1 to intended number)
jump_buffer = 0;

// Frames after leaving ground where jump is still allowed (coyote time)
coyote_time_max = 6;
coyote_time = 0;
// Jump combo variables
consecutive_jumps = 0; // Tracks the number of consecutive jumps for variable sounds
jump_combo_timer = 0; // Timer to reset the combo if a new jump isn't performed
jump_combo_timeout = 120; // 2 seconds at 60 FPS
#endregion


#region WALL INTERACTIONS
// Timer for how long the player "grabs" the wall before sliding
wall_grab_timer = 0;
wall_grab_timer_max = 8; // Max frames to "hang" on wall before sliding

// Wall jump
wall_jump_horizontal_push_off = 2; // Horizontal push when jumping off a wall
wall_jump_height = -4.5; // Initial upward velocity for a wall jump

// Timer to suppress gravity after wall jump or wall grab
wall_jump_gravity_bypass_max = 5; // Max frames to bypass gravity after wall interaction
wall_jump_gravity_bypass = 0; // Current timer for gravity suppression

// Timer for how long horizontal control is disabled after wall jump
wall_jump_move_loss = 0; // Current timer for wall jump input lockout
wall_jump_move_loss_max = 4; // Max frames for horizontal input lockout after wall jump

wall_slide_dust_timer = 0;
wall_slide_dust_timer_max = 8; // Adjust for desired frequency
#endregion


#region PLAYER KNOCKBACK (NEW)
knockback_h_resistance = 1.0;  // Horizontal knockback resistance multiplier for player
knockback_v_resistance = 1.0;   // Vertical knockback resistance multiplier for player
knockback_active = false;    // True when the player is currently in the knockback state
knockback_duration = 10;     // Duration of the player's knockback effect (e.g., 0.16 seconds)
knockback_duration_timer = 0; // Current countdown for knockback duration
knockback_cooldown_duration = 20; // Cooldown before another knockback can be applied (to prevent spamming)
knockback_cooldown_timer = 0; // Current countdown for knockback cooldown
knockback_h_friction = 0.3;  // Horizontal friction applied during player knockback
#endregion


#region DEATH CONDITIONS
// Distance below the room where the player dies
fall_threshold = room_height + 64; // 64 pixels below the bottom of the room
#endregion


#region STATE MACHINE
// Enum to manage the player's current state
enum PlayerState {
    IDLE,
    RUN,
    AIR,
    WALL_GRAB,
    WALL_SLIDE,
    ATTACK,
    DEAD
}
player_state = PlayerState.IDLE; // Initialize the player's state
player_state_previous = PlayerState.IDLE; // NEW: Store the previous state for on-entry logic
#endregion

// Add these public variables for camera to track
is_on_ground = false;


#region VISUALS
facing_direction = 1; // 1 for right, -1 for left
#endregion

 
#region AUDIO VARIABLES
// Keeps track of which running sound to play next for a "pit, pat" effect.
current_step_sound = 0;
// Tracks the image index from the previous frame to prevent sounds from
// re-triggering on the same animation frame.
image_index_previous = 0;
#endregion

// ADD A LIST OF VARIABLES WITH ALL AVAILABLE SOUND EFFECTS TO THE PLAYER

