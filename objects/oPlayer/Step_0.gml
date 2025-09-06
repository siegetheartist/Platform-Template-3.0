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

// Check for wall jump delay. If active, zero out horizontal input.
if (wall_jump_delay > 0) {
    wall_jump_delay--;
    _dir = 0;
}

// --- Jump Buffer Logic --- Test if this works
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
if (coyote_time > 0) coyote_time--;
if (wall_jump_gravity_bypass > 0) wall_jump_gravity_bypass--;
if (wall_jump_delay > 0) wall_jump_delay--;
#endregion


#region STATE TRANSITIONS
// Universal transition from air to ground
if (_on_ground && player_state == PlayerState.AIR) {
    if (_dir != 0) {
        player_state = PlayerState.RUN;
    } else {
        player_state = PlayerState.IDLE;
    }
	
    coyote_time = coyote_time_max; // Reset coyote time when landing. Is this the right place?
}
// Universal transition from ground to air (e.g., walking off a ledge)
if (!_on_ground && (player_state == PlayerState.IDLE || player_state == PlayerState.RUN)) {
    player_state = PlayerState.AIR;
    coyote_time = coyote_time_max; // Reset coyote time when in air - test if this works
}
#endregion

#region STATE MACHINE LOGIC
// Execute the logic for the current state
switch (player_state) {
    case PlayerState.IDLE:
        scr_player_state_idle(_dir, _key_jump);
        break;
    case PlayerState.RUN:
        scr_player_state_run(_dir, _key_jump);
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