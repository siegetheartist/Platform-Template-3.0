#region INPUT AND VARIABLES
// Declare all local variables used within this step event.
var _key_left = 0;
var _key_right = 0;
var _key_jump = 0;
var _key_jump_held = 0;
var _dir = 0;
var _on_ground = false;
var _on_wall = 0;
var _is_touching_wall = false;
var _is_pressing_wall = false;
var _is_ascending = false;
var collision_tileset = layer_tilemap_get_id("t_Collision");

// Read player input only if control is enabled
if (can_control && player_state != PlayerState.DEAD) {
    _key_left = keyboard_check(ord("A"));
    _key_right = keyboard_check(ord("D"));
    _key_jump = keyboard_check_pressed(vk_space);
    _key_jump_held = keyboard_check(vk_space);
}

// Check for wall jump delay. If active, zero out horizontal input.
if (wall_jump_delay > 0) {
    wall_jump_delay--;
    _dir = 0;
} else {
    // Calculate horizontal input direction as normal.
    _dir = _key_right - _key_left;
}
#endregion

#region TIMER MANAGEMENT
// --- Invulnerability and Flash Timers ---
if (invulnerable_timer > 0) {
    invulnerable_timer--;
}
if (flash_timer > 0) {
    flash_timer--;
}
// --- Jump Combo Timer ---
if (jump_combo_timer > 0) {
    jump_combo_timer--;
} else {
    consecutive_jumps = 0;
}
#endregion

#region COLLISION CHECKS
// --- Ground Check ---
_on_ground = place_meeting(x, y + 1, collision_tileset);

// --- Vertical State Checks ---
_is_ascending = vsp < 0;

// --- Wall Check ---
_on_wall = place_meeting(x + 1, y, collision_tileset) - place_meeting(x - 1, y, collision_tileset);
_is_touching_wall = (_on_wall != 0);
_is_pressing_wall = (sign(_dir) == _on_wall) && (_dir != 0);
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