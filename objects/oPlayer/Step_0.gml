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

// Check for Walljump Move-Loss timer (after a wall jump) If active, zero out horizontal input.
// Do not move, as this affects _dir. If placed elsewhere, other code that overrides _dir will be effected.
if (wall_jump_move_loss > 0) {
    wall_jump_move_loss--;
    _dir = 0;
}

// --- Jump Buffer Logic --- 
if (_key_jump && !place_meeting(x, y + 1, collision_tileset)) {
    jump_buffer = jump_buffer_max;
}
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
if (jump_combo_timer > 0) {
    jump_combo_timer--;
} else {
    consecutive_jumps = 0;
}
// --- Jump & Gravity Timers ---
if (jump_buffer > 0) jump_buffer--;
if (_on_ground) {
    coyote_time = coyote_time_max;
} else {
    coyote_time--;
}
// Wall grab timer
if (wall_jump_gravity_bypass > 0) wall_jump_gravity_bypass--;
// Wall jump move loss timer
if (wall_jump_move_loss > 0) wall_jump_move_loss--; 
#endregion


#region JUMP LOGIC
// We check for jump input here, before state transitions, to ensure that
// a jump can be registered even in the brief window after leaving the ground (coyote time).
if (scr_player_jump_input(_key_jump, _on_ground)) {
}
#endregion


#region STATE TRANSITIONS
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
// Apply friction/deceleration if not moving or if control is locked
if (player_state != PlayerState.RUN && player_state != PlayerState.AIR) {
    hsp = (hsp > 0) ? max(hsp - decel, 0) : min(hsp + decel, 0);
}

// Apply horizontal speed and resolve collision with the tilemap
x += hsp;
if (place_meeting(x, y, collision_tileset)) {
    var _pixel_step = sign(hsp);
    if (_pixel_step == 0) {
        _pixel_step = 1;
    }
    while (place_meeting(x, y, collision_tileset)) {
        x -= _pixel_step;
    }
    hsp = 0;
}

// Apply vertical speed and resolve collision with the tilemap
y += vsp;
if (place_meeting(x, y, collision_tileset)) {
    var _pixel_step = sign(vsp);
    if (_pixel_step == 0) {
        _pixel_step = -1;
    }
    while (place_meeting(x, y, collision_tileset)) {
        y -= _pixel_step;
    }
    vsp = 0;
}
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