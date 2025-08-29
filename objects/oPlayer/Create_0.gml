// --- Player Initialization Variables ---




#region CHECKPOINT SYSTEM
// Stores the player's last checkpoint position for respawn logic
global.checkpoint_x = x; // Stores current X position as checkpoint
global.checkpoint_y = y; // Stores current Y position as checkpoint
#endregion

#region CINEMATIC CONTROL
// Determines whether the player can move or act (used during cutscenes or transitions)
can_control = false; // Flag to enable/disable player input
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
max_hsp = 4; // Maximum horizontal speed the player can reach

// Gravity settings for normal falling
grav = 0.5; // Strength of gravity pulling the player down
grav_max = 12; // Maximum vertical speed due to normal gravity

// Gravity settings while sliding on a wall
grav_wall = 0.1; // Reduced gravity strength for wall sliding
grav_max_wall = 5; // Maximum vertical speed while wall sliding
#endregion

#region JUMPING VARIABLES
// Distance to check below player for ground detection
ground_check_dist = 4; // Pixels below player to check for solid ground

// Frames after leaving ground where jump is still allowed (coyote time)
coyote_time = 6; // Frames to allow jumping after leaving a platform

// Minimum jump height when releasing jump early
jump_height_min = -3; // Minimum upward velocity when jump key is released early

// Standard jump velocity
jump_height = -8; // Initial upward velocity for a full jump

// Frames to buffer jump input before landing
jump_buffer = 0; // Timer to store a jump input if pressed slightly before landing

// Horizontal push when jumping off a wall
wall_jump_distance = 6; // Horizontal force applied during a wall jump

// Vertical velocity for wall jump
jump_height_wall = -8; // Initial upward velocity for a wall jump
#endregion

#region WALL JUMP STATE MACHINE
// Enum to manage wall interaction states
enum WallJumpState {
    NONE,        // Not interacting with a wall
    GRAB,        // Brief pause after hitting wall (gravity suppressed)
    SLIDE,       // Sliding down wall with reduced gravity
    JUMP,        // Just performed a wall jump
    RECOVER      // Regaining control after wall jump (input lockout)
}
wall_jump_state = WallJumpState.NONE; // Initialize wall jump state
#endregion

#region WALL INTERACTION TIMERS
// Timer for how long the player "grabs" the wall before sliding
wall_grab_timer = 0; // Current timer for wall grab duration
wall_grab_timer_max = 8; // Max frames to "hang" on wall before sliding

// Timer for how long horizontal control is disabled after wall jump
wall_jump_delay = 0; // Current timer for wall jump input lockout
wall_jump_delay_max = 8; // Max frames for horizontal input lockout after wall jump

// Timer to suppress gravity after wall jump or wall grab
wall_jump_gravity_bypass = 0; // Current timer for gravity suppression
wall_jump_gravity_bypass_max = 5; // Max frames to bypass gravity after wall interaction
#endregion
