// Make checkpoint variables global to be accessed by other objects.
// CHECKPOINT SYSTEM
global.checkpoint_x = x; // Stores the player's x-coordinate at the last checkpoint.
global.checkpoint_y = y; // Stores the player's y-coordinate at the last checkpoint.

// CINEMATICS
can_control = false; // Player cannot control movement by default.

// The rest of your CREATE EVENT code follows below...
// MOMENTUM
hsp = 0;
vsp = 0;
accel = 0.5; // acceleration
decel = 0.3; // deceleration

// SPEEDS
max_hsp = 5; //max horizontal speed
grav = 0.5;  // gravity
grav_max = 12; // max fall speed
grav_wall = 0.1 // reduced gravity when sliding on a wall
grav_max_wall = 5; // max falling speed when wall sliding


// JUMPING
ground_check_dist = 12; // lets us jump if we're at least 12 pixels close
coyote_time = 10; //frames after leaving ground where we can still jump
jump_height_min = -3; // sets the min jump height
jump_height = -12; // a jump height or jump speed variable
jump_buffer = 0; // Jump buffer
wall_jump_distance = 7; // max hsp for moving away from a wall during a wall jump
jump_height_wall = -8; // how high you jump during a wall jump

// WALL JUMP CONTROL
wall_jump_delay = 0; // Current counter for horizontal control loss after a wall jump
wall_jump_delay_max = 15; // Max frames player loses horizontal control after a wall jump