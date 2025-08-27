#region CHECKPOINT SYSTEM
// Stores the player's last checkpoint position for respawn logic
global.checkpoint_x = x;
global.checkpoint_y = y;
#endregion

#region CINEMATIC CONTROL
// Determines whether the player can move or act (used during cutscenes or transitions)
can_control = false;
#endregion

#region MOVEMENT VARIABLES
// Horizontal and vertical speed
hsp = 0;
vsp = 0;

// Acceleration and deceleration for smooth movement
accel = 0.5;
decel = 0.3;
#endregion

#region SPEED LIMITS
// Maximum horizontal speed
max_hsp = 5;

// Gravity settings for normal falling
grav = 0.5;
grav_max = 12;

// Gravity settings while sliding on a wall
grav_wall = 0.1;
grav_max_wall = 5;
#endregion

#region JUMPING VARIABLES
// Distance to check below player for ground detection
ground_check_dist = 12;

// Frames after leaving ground where jump is still allowed (coyote time)
coyote_time = 10;

// Minimum jump height when releasing jump early
jump_height_min = -3;

// Standard jump velocity
jump_height = -12;

// Frames to buffer jump input before landing
jump_buffer = 0;

// Horizontal push when jumping off a wall
wall_jump_distance = 7;

// Vertical velocity for wall jump
jump_height_wall = -12;
#endregion

#region WALL JUMP STATE MACHINE
// Enum to manage wall interaction states
enum WallJumpState {
    NONE,       // Not interacting with wall
    GRAB,       // Brief pause after hitting wall (gravity suppressed)
    SLIDE,      // Sliding down wall with reduced gravity
    JUMP,       // Just performed a wall jump
    RECOVER     // Regaining control after wall jump
}
wall_jump_state = WallJumpState.NONE;
#endregion

#region WALL INTERACTION TIMERS
// Timer for how long the player "grabs" the wall before sliding
wall_grab_timer = 0;
wall_grab_timer_max = 8; // hang time

// Timer for how long horizontal control is disabled after wall jump
wall_jump_delay = 0;
wall_jump_delay_max = 8;

// Timer to suppress gravity after wall jump or wall grab
wall_jump_gravity_bypass = 0;
wall_jump_gravity_bypass_max = 5;
#endregion