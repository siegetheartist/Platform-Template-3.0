#region INPUT AND VARIABLES
// -- Universal Input Handling --
if (can_control && player_state != PlayerState.DEAD) {
    // Get the raw input from our universal script.
    input = scr_player_get_input(); 
} else {
    // If we can't control the player, create a "zeroed-out" input struct
    // to prevent the rest of the code from crashing.
    input = {
        left_held: 0, right_held: 0, jump_held: 0,
        left_pressed: 0, right_pressed: 0, jump_pressed: 0, attack_pressed: 0,
        dir: 0
    };
}

// -- Local Variables for This Event --
// We create local variables from the 'input' struct for easier use below.
var _key_left = input.left_held;
var _key_right = input.right_held;
var _key_jump = input.jump_pressed;
var _key_jump_held = input.jump_held;
var _key_attack_pressed = input.attack_pressed;
var _dir = input.dir;

// --- Collision Tileset ---
var collision_cave01 = layer_tilemap_get_id("tsCollision"); // main room titleset
var collision_slopes = layer_tilemap_get_id("tlSlopes"); // new layer to handle slopes
var collision_tileset = [collision_cave01, collision_slopes, objSlope, objDestructableWall, objTimedPlatform, oInvisibleBlock, objSlope01, objSlope02, objSlope03, objSlope04, objSlope05]; // Holds all collidables
// rename collision solids?

// This group contains only the objects that should NOT allow wall grabs.
var non_grabbable_solids = [oInvisibleBlock];
#endregion


#region COLLISION CHECKS
// --- Ground Check ---
var _on_ground = place_meeting(x, y + 1, collision_tileset);
is_on_ground = _on_ground; // Make the ground state public for the camera

// --- Vertical State Checks ---
var _is_ascending = vsp < 0;

// --- Wall Check ---
var _on_wall = place_meeting(x + 1, y, collision_tileset) - place_meeting(x - 1, y, collision_tileset);
var _is_touching_wall = (_on_wall != 0);
var _is_pressing_wall = (sign(_dir) == _on_wall) && (_dir != 0);

// Check if the wall being touched is GRABBABLE
var _is_touching_grabbable_wall = false;
if (_is_touching_wall) {
    // A wall is grabbable if it is NOT in the non-grabbable list.
    if (!place_meeting(x + _on_wall, y, non_grabbable_solids)) {
        _is_touching_grabbable_wall = true;
    }
}
#endregion


#region PLAYER TIMER MANAGEMENT

if (invulnerable_timer > 0) { invulnerable_timer--; }
if (flash_timer > 0) { flash_timer--; }
if (attack_timer > 0) { attack_timer--; }
    
// Knockback Timers
if (knockback_cooldown_timer > 0) { knockback_cooldown_timer--; }
if (knockback_duration_timer > 0) { knockback_duration_timer--; }
    
// Jump combo logic
if (jump_combo_timer > 0) {
    jump_combo_timer--;
} else {
    consecutive_jumps = 0;
}

// // Wall grab timer and wall jump gravity bypass
if (wall_jump_gravity_bypass > 0) {
    wall_jump_gravity_bypass--;
}
    
// Wall jump move loss timer
if (wall_jump_move_loss > 0) {
    wall_jump_move_loss--;
    _dir = 0; // Input is locked during wall jump move loss
    // Only transition to AIR if not currently attacking when the move loss ends
    if (wall_jump_move_loss <= 0 && player_state != PlayerState.ATTACK) {
        player_state = PlayerState.AIR;
    }
}
#endregion


#region GENERAL VERTICAL MOVEMENT PHYSICS
// Wall slide and wall grab states handle their own vertical movement, overriding default gravity.
// Therefore, only apply general gravity if not in those states.
if (player_state != PlayerState.WALL_SLIDE && player_state != PlayerState.WALL_GRAB) {
    // Apply gravity to vertical speed.
    vsp += grav;
    vsp = min(vsp, grav_max); // Clamp vertical speed to prevent it from exceeding max falling speed.
    
    // No upper clamp for vsp when knocked back, allowing full upward impulse.
    // Otherwise, clamp to normal max upward speed for regular jumps.
    if (!knockback_active) {
        vsp = max(vsp, -grav_max);
    }
}
#endregion


#region JUMP LOGIC
// We check for jump input here, before state transitions, to ensure that
// a jump can be registered even in the brief window after leaving the ground (coyote time).
if (scr_player_input_jump(_key_jump, _on_ground)) {
}
#endregion


#region STATE TRANSITIONS

// Attack Input Check (takes priority over other transitions)
scr_player_input_attack(_key_attack_pressed); // This script will handle the transition to ATTACK state

// Transition from wall slide to ground
if (_on_ground && player_state == PlayerState.WALL_SLIDE) {
    if (_dir != 0) {
        player_state = PlayerState.RUN;
    } else {
        player_state = PlayerState.IDLE;
    }
}


// Universal transition from air to ground
if (_on_ground && player_state == PlayerState.AIR) {

    // Check if the player was truly in an AIR state in the previous frame
    // to prevent playing the landing sound immediately after initiating a jump.
    if (player_state_previous == PlayerState.AIR) {
        audio_play_sound(sndPlayerJumpLanding, 10, false);
        scr_spawn_dust_cloud(x, y, facing_direction);
    }
    
    // Transition to appropriate ground state
    if (_dir != 0) {
        player_state = PlayerState.RUN;
    } else {
        player_state = PlayerState.IDLE;
    }
}

// Universal transition from ground to air (e.g., walking off a ledge)
// Also ensure we don't transition if actively in knockback.
if (!_on_ground && (player_state == PlayerState.IDLE || player_state == PlayerState.RUN) && player_state != PlayerState.ATTACK && !knockback_active) {
    player_state = PlayerState.AIR;
}

// Check for DEATH transition (if not already dead)
if ((player_health <= 0 || y > fall_threshold) && player_state != PlayerState.DEAD) {
    player_state = PlayerState.DEAD;
}
#endregion


#region HORIZONTAL MOVEMENT PHYSICS (DEFAULT AND KNOCKBACK)
if (knockback_active) {
    // Apply knockback-specific friction/deceleration
    if (abs(hsp) > knockback_h_friction) {
        hsp -= sign(hsp) * knockback_h_friction;
    } else {
        hsp = 0;
    }
    // End knockback if duration timer runs out
    if (knockback_duration_timer <= 0) {
        knockback_active = false;
        hsp = 0;
        vsp = 0;
    }
} else { // Normal movement physics if not knocked back
    if (_dir != 0) {
        // Accelerate towards max speed in the input direction
        hsp += _dir * accel;
        hsp = clamp(hsp, -max_hsp, max_hsp);
    } else {
        // If no horizontal input, apply deceleration
        if (abs(hsp) > decel) {
            hsp -= sign(hsp) * decel;
        } else {
            hsp = 0;
        }
    }
}
#endregion


#region STATE MACHINE LOGIC
// Execute the logic for the current state
switch (player_state) {
    case PlayerState.IDLE:
        scr_player_state_idle(_dir);
        break;
    case PlayerState.RUN:
        scr_player_state_run(_dir);
        break;
    case PlayerState.AIR:
        scr_player_state_air(_key_jump_held, _on_wall, _is_touching_grabbable_wall, _is_pressing_wall, _dir);
        break;
    case PlayerState.WALL_GRAB:
        scr_player_state_wall_grab(_on_wall, _is_pressing_wall, _key_jump);
        break;
    case PlayerState.WALL_SLIDE:
        scr_player_state_wall_slide(_on_wall, _is_touching_wall, _is_pressing_wall, _key_jump);
        break;
    case PlayerState.ATTACK: 
        scr_player_state_attack(_on_ground); // Pass _on_ground to determine return state and modify hsp if needed
        break;
    case PlayerState.DEAD:
        scr_player_state_death(id);
        break;
}
#endregion


#region MOVEMENT AND COLLISION
scr_move_and_collide(collision_tileset);
#endregion


#region UPDATE VISUALS
// Update facing direction based on input or momentum
if (player_state != PlayerState.ATTACK && !knockback_active) { // Prevent changing direction during attack or knockback
    if (_dir != 0) {
        facing_direction = _dir;
    } else if (hsp != 0) {
        facing_direction = sign(hsp);
    }
}
#endregion



// Keep track of previous variable values
image_index_previous = image_index; // // Update previous image index for animation sound logic
player_state_previous = player_state;