#region INPUT AND VARIABLES
// Execute the script that handles all input.
var _player_input = scr_player_input();

// Declare and get local variables for the rest of the step event.
// These variables are now retrieved from the _player_input struct.
var _key_left = _player_input.key_left;
var _key_right = _player_input.key_right;
var _key_jump = _player_input.key_jump;
var _key_jump_held = _player_input.key_jump_held;
var _dir = _player_input.dir;

// --- Collision Tileset ---
var collision_tileset = layer_tilemap_get_id("t_Collision");
// var collision_slopes = layer_tilemap_get_id("t_Slopes"); // new layer to handle slopes
// var collision_layers = [collision_tileset, collision_slopes]; // new variable to hold all collidables


#endregion


#region COLLISION CHECKS
// --- Ground Check ---
var _on_ground = place_meeting(x, y + 1, collision_tileset);

// --- Vertical State Checks ---
var _is_ascending = vsp < 0;

// --- Wall Check ---
var _on_wall = place_meeting(x + 1, y, collision_tileset) - place_meeting(x - 1, y, collision_tileset);
var _is_touching_wall = (_on_wall != 0);
var _is_pressing_wall = (sign(_dir) == _on_wall) && (_dir != 0);
#endregion


#region TIMER MANAGEMENT
// --- Player Timers ---
if (invulnerable_timer > 0) invulnerable_timer--;
if (flash_timer > 0) flash_timer--;
    
// Different sound for jumps (names need to be changed to match intent. Currently, jump combo timer sounds like we are performing double jumps, and we are not. Consecutive jumps seems like it would be a counter for double jumps, and it's not.
// Suggest changing the names to something more easily understood. Like: jump_sound_counter_max and jump_sound_counter
if (jump_combo_timer > 0) {
    jump_combo_timer--;
} else {
    consecutive_jumps = 0;
}

// Wall grab timer
if (wall_jump_gravity_bypass > 0) wall_jump_gravity_bypass--;
// Wall jump move loss timer
if (wall_jump_move_loss > 0) wall_jump_move_loss--; 
    
// Check for Walljump Move-Loss timer (after a wall jump) If active, zero out horizontal input.
// Do not move, as this affects _dir. If placed elsewhere, other code that overrides _dir will be effected.
if (wall_jump_move_loss > 0) {
    wall_jump_move_loss--;
    _dir = 0;
    if (wall_jump_move_loss <= 0) {
        player_state = PlayerState.AIR;
    }
}
#endregion



#region JUMP LOGIC
// We check for jump input here, before state transitions, to ensure that
// a jump can be registered even in the brief window after leaving the ground (coyote time).
if (scr_player_jump_input(_key_jump, _on_ground)) {
}
#endregion



#region STATE TRANSITIONS
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
    if (_dir != 0) {
        player_state = PlayerState.RUN;
    } else {
        player_state = PlayerState.IDLE;
    }
}
// Universal transition from ground to air (e.g., walking off a ledge)
if (!_on_ground && (player_state == PlayerState.IDLE || player_state == PlayerState.RUN)) {
    player_state = PlayerState.AIR;
}
#endregion



#region HORIZONTAL MOVEMENT PHYSICS
// This block handles the direct application of horizontal input (acceleration)
// and general deceleration (friction) when no input is given.
// State-specific overrides (like wall grab/slide setting hsp=0) will happen in the state scripts.
 
// If player has horizontal input AND is not in a wall jump lockout
if (_dir != 0 && wall_jump_move_loss <= 0) {
    // Accelerate towards max speed in the input direction
    hsp += _dir * accel;
    hsp = clamp(hsp, -max_hsp, max_hsp);
} else {
    // If no horizontal input, or input is locked by wall jump, apply deceleration
    if (abs(hsp) > decel) {
        hsp -= sign(hsp) * decel;
    } else {
        hsp = 0; // Snap to zero
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
        scr_player_state_air(_key_jump_held, _on_wall, _is_touching_wall, _is_pressing_wall, _dir);
        break;
    case PlayerState.WALL_GRAB:
        scr_player_state_wall_grab(_on_wall, _is_pressing_wall, _key_jump);
        break;
    case PlayerState.WALL_SLIDE:
        scr_player_state_wall_slide(_on_wall, _is_touching_wall, _is_pressing_wall, _key_jump);
        break;
    case PlayerState.DEAD:
        // Add death logic here later
        hsp = 0;
        vsp = 0;
        break;
}
#endregion



#region MOVEMENT AND COLLISION
// --- Move horizontally until collision
if (place_meeting(x + hsp, y, collision_tileset)) {
    var _sub_pixel = .5;
    var _pixel_step = _sub_pixel * sign(hsp);
    while (!place_meeting(x + _pixel_step, y, collision_tileset)) {
        x += _pixel_step;
    }
    hsp = 0;
}

// --- Commit to horizontal movement ---
x += hsp;


// --- Move vertically until collision ---
if (place_meeting(x, y + vsp, collision_tileset)) {
    var _sub_pixel = .5;
    var _pixel_step = _sub_pixel * sign(vsp);
    while (!place_meeting(x, y + _pixel_step, collision_tileset)) {
        y += _pixel_step;
    }
    vsp = 0;
}

// --- Commit Vertical Movement ---
y += vsp;
#endregion



#region UPDATE VISUALS
// Update facing direction based on input or momentum
if (_dir != 0) {
    facing_direction = _dir;
} else if (hsp != 0) {
    facing_direction = sign(hsp);
}
#endregion


#region HAZARD & ENEMY DAMAGE
// --- Enemy/Hazard Collision and Damage ---
var _collided_enemy = instance_place(x, y, oEnemy);
var _collided_hazard = place_meeting(x, y, oHazard);

if ((_collided_enemy != noone || _collided_hazard) && invulnerable_timer <= 0) {
    var _damage_taken = 0;
    if (_collided_enemy != noone) {
        _damage_taken = _collided_enemy.enemy_damage;
    } else if (_collided_hazard) {
        _damage_taken = 1;
    }

    if (_damage_taken > 0) {
        if (player_health - _damage_taken > 0) {
            audio_play_sound(sndPlayerTakesDamage, 10, false);
        }
        player_health -= _damage_taken;
        invulnerable_timer = invulnerable_duration;
        flash_timer = flash_duration;
    }
}
#endregion

#region MISC LOGIC
// Update previous image index for animation sound logic
image_index_previous = image_index;
#endregion