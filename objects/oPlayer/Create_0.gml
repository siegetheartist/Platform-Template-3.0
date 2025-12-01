#region PLAYER HEALTH AND INVULNERABILITY
// Initialize player health in OgameManager. 
player_health = oGameManager.max_player_health; // Stores players current health and is updated in scr_apply_damage script
invulnerable_timer = 0; // Timer for player invulnerability frames
invulnerable_duration = 60; // How many frames player is invulnerable after taking damage (1 second at 60 FPS)
flash_timer = 0; // Timer for visual damage indicator (blinking)
flash_duration = 30; // How long the player sprite flashes after taking damage (0.5 seconds at 60 FPS).
#endregion


#region ATTACK MECHANICS
attack_timer = 0; // Timer for the attack animation
attack_frames = 18; // Duration of the attack state in frames (adjust as needed for sPlayerAttack sprite)
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
max_x_speed = 2.5; // Maximum horizontal speed the player can reach

// Acceleration and deceleration for smooth movement
accel = 0.3;
decel = 0.5;

// TODO: Add walk and run and swap to structs - access by utilizing dot notation ex: walk.accel
walk = {
    accel : .2,
    decel : .5,
    max_x_speed : 2.5
}

run = {
    accel : .2,
    decel : .5,
    max_x_speed : 2.5
}

// Vertical speed
y_speed = 0; // Vertical speed (pixels per frame)
#endregion


#region GRAVITY SETTINGS
// Gravity settings for normal falling
grav = 0.2; // Strength of gravity pulling the player down
term_vel = 7.5; // Maximum vertical speed due to normal gravity

// Gravity settings while sliding on a wall
grav_wall = 0.1; // Reduced gravity strength for wall sliding
grav_wall_max = 3.2; // Maximum vertical speed while wall sliding
#endregion


#region JUMPING MECHANICS
// Array is for [0] = Ground Jump, [1] = Air jump
jump_speed = [-2.3, -1.5]; // Jump Velocity
jump_speed_sustain_frames = [18, 10]; // "Sustain" windows. Constantly applies jump velocity for x amount of frames.
jump_speed_sustain_timer = 0;
jump_max = 1;
// jump_max = array_length(jump_speed); // Max amount of aerial multi-jump-sequences. Automatically matches array size
jump_count = 0; // Jump tracker

// Frames to buffer jump input before landing
jump_input_buffer_frames = 5; // Max frames to buffer a jump input (immediately derements 1 in the same frame. so add 1 to intended number)
jump_input_buffer_timer = 0;

// Frames after leaving ground where jump is still allowed (coyote jump time)
coyote_jump_frames = 6;
coyote_jump_timer = 0;

// Frames after leaving ground where gravity is ignored
coyote_hang_frames = 5;
coyote_hang_timer = 0;

// Jump sound-combo variables
consecutive_jumps = 0; // Tracks the number of consecutive jumps for variable sounds
jump_combo_timer = 0; // Timer to reset the combo if a new jump isn't performed
jump_combo_timeout = 120; // 2 seconds at 60 FPS
#endregion


#region WALL INTERACTIONS
ledge_grab_timer = 0;
ledge_grab_frames = 90; // How many frames player hangs on a ledge
ledge_jump_speed = -4.0; // Initial upward velocity for a ledge jump
ledge_regrab_lockout_frames = 15; // How many frames to lock out regrab
ledge_regrab_lockout_timer = 0; 

// Timer for how long the player "grabs" the wall before sliding
wall_grab_timer = 0;
wall_grab_frames = 10; // Max frames to "hang" on wall before sliding

// Wall jump
wall_jump_horizontal_push_off = 6; // Horizontal push when jumping off a wall
wall_jump_speed = -4.0; // Initial upward velocity for a wall jump

// Timer for how long horizontal control is disabled after wall jump
wall_jump_input_loss_timer = 0; // Current timer for wall jump input lockout
wall_jump_input_loss_frames = 20; // Max frames for horizontal input lockout after wall jump

wall_slide_dust_timer = 0;
wall_slide_dust_timer_max = 8; // Adjust for desired frequency
#endregion


#region MOVING PLATFORMS
my_floor_plat = noone;
early_moving_plat_x_speed = false;
down_slope_semi_solid = noone; // Will hold the ID of a semi solid platform, if we collide with one, while attempting to move down a slope
forget_semi_solid = noone;
move_plat_x_speed = 0;
move_plat_max_y_speed = term_vel; // How fast can the player follow a downwards moving platform
#endregion


#region PLAYER KNOCKBACK
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
    CROUCH,
    AIR,
    LEDGE_GRAB,
    WALL_GRAB,
    WALL_SLIDE,
    ATTACK,
    DEAD
}
player_state = PlayerState.IDLE; // Initialize the player's state
player_state_previous = PlayerState.IDLE; // NEW: Store the previous state for on-entry logic
#endregion


#region VISUALS
facing_direction = 1; // 1 for right, -1 for left
// depth = -30; // Can remove if prefer folder organization
#endregion

 
#region AUDIO VARIABLES
// Keeps track of which running sound to play next for a "pit, pat" effect.
current_step_sound = 0;
// Tracks the image index from the previous frame to prevent sounds from
// re-triggering on the same animation frame.
image_index_previous = 0;
#endregion

// TODO: ADD A LIST OF VARIABLES WITH ALL AVAILABLE SOUND EFFECTS TO THE PLAYER

on_ground = false; // Re-assigned in jump logic, vertical physics (via ending coyote timer) and vertical move/collide
on_wall = false;
on_ledge = false; // TODO: Build requirements for on_ledge consideration. Not started yet
//can_ledge_grab = false;
//can_wall_grab = false
can_wall_jump = false;


/// @description Decrements all jump-related timers
timers_jump = function () {
    // --- Variable jump sustain timer ---
    if (jump_speed_sustain_timer > 0) { jump_speed_sustain_timer--; } 

    // --- Coyote timers ---
    if (coyote_jump_timer > 0) { coyote_jump_timer--; } 
    if (coyote_hang_timer > 0) { coyote_hang_timer--; } 
        
    // --- Jump Input Buffer timer ---
    if (jump_input_buffer_timer > 0) { jump_input_buffer_timer--; } 
        
    // --- Jump Sound Combo timer ---
    if (jump_combo_timer > 0) { jump_combo_timer--; } 
    else { consecutive_jumps = 0; } 
}

/// @description Determines what kind of jump is requested.
/// @arg {bool} _key_jump
/// @arg {bool} _key_down
action_request_jump = function (_key_jump, _key_down) {
    
    var _floor_is_solid = false;
    if ( instance_exists(my_floor_plat)
    && ( my_floor_plat.object_index == objWall || object_is_ancestor(my_floor_plat.object_index, objWall) ) ) {
    	_floor_is_solid = true;
    }

    // --- Jump Input Buffer --- TODO: Add on_ledge once it's made
    if (_key_jump && !on_ground && !on_wall) {
            jump_input_buffer_timer = jump_input_buffer_frames;
    }
    
    // --- JUMP TYPES: Buffered or direct input ---
    if (_key_jump || jump_input_buffer_timer > 0) {
        
        // Wall Jump
        if ((player_state == PlayerState.WALL_GRAB || player_state == PlayerState.WALL_SLIDE) && jump_count < jump_max 
            || (player_state == PlayerState.AIR && can_wall_jump)) {

            // Kick-off reset
            if (player_state == PlayerState.AIR && can_wall_jump) {
                jump_count = 0;
            }
            
            return "wall";
        }

        // Ground Jump
        if ((on_ground || coyote_jump_timer > 0) && jump_count < jump_max && (!_key_down || _floor_is_solid) ) {
            return "ground";
        }
    }

    // --- Direct key input only ---
    if (_key_jump) {
        
        // Ledge Jump
        if (player_state == PlayerState.LEDGE_GRAB && jump_count < jump_max) {
            return "ledge";
        }
        
        // Air Jump
        var _about_to_hit_wall = place_meeting(x + x_speed * 5, y, collision_tileset);
        if (player_state == PlayerState.AIR && jump_count < jump_max && !_about_to_hit_wall) {
            return "air";
        }
    }

    // No valid jump
    return "";
}

/// @description Executes a jump of the given type and sounds.
/// @arg {string} _jump_type The type of jump ("ground" or "wall").
/// @arg {real} [_wall_dir] Optional. The direction of the wall (-1 or 1) for a wall jump.
action_execute_jump = function (_jump_type, _wall_dir=0) {
	
	#region	JUMP SOUNDS
    /// Play the correct jump sound based on the player's consecutive jumps and manages the jump combo.
    consecutive_jumps++;
    jump_combo_timer = jump_combo_timeout;
    var _jump_sound_to_play = sndPlayerJump; // Default to the first sound.
    switch (consecutive_jumps) {
        case 1:
            _jump_sound_to_play = sndPlayerJump;
            break;
        case 2:
            _jump_sound_to_play = sndPlayerJump02;
            break;
        case 3:
            _jump_sound_to_play = sndPlayerJump03;
            break;
        default:
            // After the third jump, loop back to the first sound.
            _jump_sound_to_play = sndPlayerJump;
            consecutive_jumps = 1;
            break;
    }
    audio_play_sound(_jump_sound_to_play, 10, false);
	#endregion
    
    #region JUMP LOGIC
    
    jump_count++;
    if (_jump_type != "air") { jump_input_buffer_timer = 0 }; // Consume buffer except in air
    set_on_ground(false);
    
    // --- SPECIFIC LOGIC (Based on jump type) ---
    switch (_jump_type) {
        case "ground":
            coyote_jump_timer = 0;
            coyote_hang_timer = 0;
            y_speed = jump_speed[jump_count - 1];
            jump_speed_sustain_timer = jump_speed_sustain_frames[jump_count - 1];
            break;
        case "air":
            y_speed = jump_speed[jump_count - 1];
            jump_speed_sustain_timer = jump_speed_sustain_frames[jump_count - 1];
            break;
        case "wall":
            y_speed = wall_jump_speed;
            x_speed = -_wall_dir * wall_jump_horizontal_push_off;
            wall_jump_input_loss_timer = wall_jump_input_loss_frames;
            last_wall_dir = _wall_dir; // remember which wall we jumped from for input lockout
            audio_stop_sound(sndPlayerWallSlide);
            break;
        case "ledge":
            y_speed = ledge_jump_speed;
            ledge_grab_timer = 0;
            coyote_hang_timer = 0;
            ledge_regrab_lockout_timer = ledge_regrab_lockout_frames;
            break;
    }
    #endregion
}


/// @description Set's on ground / air variables (i.e: on_ground, jump_count, jump_speed_sustain_timer, coyote_hang_timer, coyote_jump_timer).
set_on_ground = function (_val = true) {
    
    if (_val == true) {
        on_ground = true;
        
        // Reset jump count otherwise you won't be able to jump anymore.
        jump_count = 0;
        jump_speed_sustain_timer = 0;
        
        // Refill coyote timers
        coyote_hang_timer = coyote_hang_frames;
        coyote_jump_timer = coyote_jump_frames;
    } else {
        on_ground = false;
        my_floor_plat = noone; // if we are not on ground, forget platform
        coyote_hang_timer = 0;
    }
}