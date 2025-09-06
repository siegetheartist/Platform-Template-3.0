#region CINEMATIC CONTROL
// Determines whether the player can move or act (used during cutscenes or transitions)
can_control = (room != rStartMenu);
#endregion

#region MOVEMENT VARIABLES
// Horizontal and vertical speed
hsp = 0; // Horizontal speed (pixels per frame)
vsp = 0; // Vertical speed (pixels per frame)

// Acceleration and deceleration for smooth movement
accel = 0.5; // Rate at which horizontal speed increases
decel = 0.3; // Rate at which horizontal speed decreases
#endregion

#region SPEED LIMITS
// Maximum horizontal speed
max_hsp = 3; // Maximum horizontal speed the player can reach

// Gravity settings for normal falling
grav = 0.5; // Strength of gravity pulling the player down
grav_max = 12; // Maximum vertical speed due to normal gravity

// Gravity settings while sliding on a wall
grav_wall = 0.1; // Reduced gravity strength for wall sliding
grav_max_wall = 5; // Maximum vertical speed while wall sliding
#endregion

#region JUMPING VARIABLES
// Distance to check below player for ground detection
ground_check_dist = 12; // Pixels below player to check for solid ground

// Frames after leaving ground where jump is still allowed (coyote time)
coyote_time_max = 10;
coyote_time = 0;

// Minimum jump height when releasing jump early
jump_height_min = -3; // Minimum upward velocity when jump key is released early

// Standard jump velocity
jump_height = -8; // Initial upward velocity for a full jump

// Frames to buffer jump input before landing
jump_buffer_max = 10; // Max frames to buffer a jump input
jump_buffer = 0;

// Horizontal push when jumping off a wall
wall_jump_distance = 6; // Horizontal force applied during a wall jump

// Vertical velocity for wall jump
jump_height_wall = -8; // Initial upward velocity for a wall jump

// Jump combo variables
consecutive_jumps = 0; // Tracks the number of consecutive jumps for variable sounds
jump_combo_timer = 0; // Timer to reset the combo if a new jump isn't performed
jump_combo_timeout = 120; // 2 seconds at 60 FPS
#endregion

#region WALL JUMP TIMERS
// Timer for how long horizontal control is disabled after wall jump
wall_jump_delay_max = 8; // Max frames for horizontal input lockout after wall jump
wall_jump_delay = 0; // Current timer for wall jump input lockout

// Timer to suppress gravity after wall jump or wall grab
wall_jump_gravity_bypass_max = 5; // Max frames to bypass gravity after wall interaction
wall_jump_gravity_bypass = 0; // Current timer for gravity suppression
#endregion

#region PLAYER HEALTH AND INVULNERABILITY
player_health = 3; // Player's current health, starts at 3
invulnerable_timer = 0; // Timer for player invulnerability frames
invulnerable_duration = 60; // How many frames player is invulnerable after taking damage (1 second at 60 FPS)
flash_timer = 0; // Timer for visual damage indicator (blinking)
flash_duration = 30; // How long the player sprite flashes after taking damage (0.5 seconds at 60 FPS)
#endregion

#region DEATH CONDITIONS
// Distance below the room where the player dies
fall_threshold = room_height + 64; // 64 pixels below the bottom of the room
#endregion

#region AUDIO VARIABLES
// Keeps track of which running sound to play next for a "pit, pat" effect.
current_step_sound = 0;
// Tracks the image index from the previous frame to prevent sounds from
// re-triggering on the same animation frame.
image_index_previous = 0;
#endregion

#region STATE MACHINE
// Enum to manage the player's current state
enum PlayerState {
    IDLE,
    RUN,
    AIR,
    WALL_GRAB,
    WALL_SLIDE,
    DEAD
}
player_state = PlayerState.IDLE; // Initialize the player's state
#endregion

#region VISUALS
facing_direction = 1; // 1 for right, -1 for left
#endregion

#region WALL INTERACTION VARIABLES
// Timer for how long the player "grabs" the wall before sliding
wall_grab_timer = 0;
wall_grab_timer_max = 8; // Max frames to "hang" on wall before sliding
#endregion