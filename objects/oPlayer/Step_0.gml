// Declare all local variables
var _key_left = 0;
var _key_right = 0;
var _key_jump = 0;
var _key_jump_held = 0;
var _key_down = 0;
var _dir = 0;
var _is_moving = false;
var _is_ascending = false;
var _is_descending = false;
var _on_ground = false;
var _on_wall = 0;
var _is_touching_wall = false;
var _is_pressing_wall = false;
var _can_wall_grab = false;

// --- Ground Check ---
_on_ground = place_meeting(x, y + 1, oBlock);

// --- Movement Check ---
_is_moving = hsp != 0;

// --- Vertical State Checks ---
_is_ascending = vsp < 0;
_is_descending = vsp > 0;

// --- Wall Check ---
_on_wall = place_meeting(x + 1, y, oBlock) - place_meeting(x - 1, y, oBlock);
_is_touching_wall = (_on_wall != 0);

// --- Input ---
if (can_control) {
    _key_left = keyboard_check(ord("A"));
    _key_right = keyboard_check(ord("D"));
    _key_jump = keyboard_check_pressed(vk_space);
    _key_jump_held = keyboard_check(vk_space);
    _key_down = keyboard_check(ord("S"));
}

// --- Direction ---
if (can_control && wall_jump_state != WallJumpState.RECOVER) {
    _dir = _key_right - _key_left;
}

// --- Wall Interaction ---
_is_pressing_wall = (sign(_key_right - _key_left) == _on_wall);

// --- Refined Wall Grab Detection ---
var _vaulting = (vsp < -6); // Still suppress grab if player is clearly vaulting

_can_wall_grab = _is_touching_wall && !_on_ground && _is_pressing_wall;
var _valid_wall_grab = _can_wall_grab && !_vaulting;

// --- Wall Jump State Machine ---
switch (wall_jump_state) {
    case WallJumpState.NONE:
        if (_valid_wall_grab) {
            wall_jump_state = WallJumpState.GRAB;
            wall_grab_timer = 0;
            wall_jump_gravity_bypass = wall_jump_gravity_bypass_max;
        }
        break;

    case WallJumpState.GRAB:
        wall_grab_timer++;

        if (wall_grab_timer <= wall_grab_timer_max) {
            wall_jump_gravity_bypass = wall_grab_timer_max;
            vsp = 0;
        }

        if (wall_grab_timer >= wall_grab_timer_max) {
            wall_jump_state = WallJumpState.SLIDE;
        }

        if (!_valid_wall_grab) {
            wall_jump_state = WallJumpState.NONE;
        }
        break;

    case WallJumpState.SLIDE:
        if (!_valid_wall_grab) {
            wall_jump_state = WallJumpState.NONE;
        }

        if (_key_jump) {
            hsp = -_on_wall * wall_jump_distance;
            vsp = jump_height_wall - 2;
            wall_jump_delay = wall_jump_delay_max;
            wall_jump_gravity_bypass = wall_jump_gravity_bypass_max + 4;
            wall_jump_state = WallJumpState.JUMP;
        }
        break;

    case WallJumpState.JUMP:
        wall_jump_state = WallJumpState.RECOVER;
        break;

    case WallJumpState.RECOVER:
        if (wall_jump_delay > 0) {
            wall_jump_delay--;
        } else {
            wall_jump_state = WallJumpState.NONE;
        }
        break;
}

// --- Horizontal Movement ---
if (can_control) {
    if (wall_jump_state == WallJumpState.GRAB || wall_jump_state == WallJumpState.SLIDE) {
        _dir = 0;
        hsp = 0;
    }

    if (_on_ground && _dir != 0 && place_meeting(x + _dir, y, oBlock)) {
        hsp = 0;
        _dir = 0;
    }

    if (_dir != 0) {
        hsp += _dir * accel;
    } else {
        hsp = (hsp > 0) ? max(hsp - decel, 0) : min(hsp + decel, 0);
    }

    hsp = clamp(hsp, -max_hsp, max_hsp);
} else {
    hsp = 0;
}

// --- Jump Buffer ---
if (can_control && _key_jump) {
    jump_buffer = 10;
}
jump_buffer--;

// --- Gravity ---
if (wall_jump_gravity_bypass > 0) {
    wall_jump_gravity_bypass--;
} else {
    var _grav_final = grav;
    var _grav_max_final = grav_max;
    var _vsp_min_clamp = jump_height;

    if (wall_jump_state == WallJumpState.SLIDE) {
        _grav_final = grav_wall;
        _grav_max_final = grav_max_wall;
        _vsp_min_clamp = 0;
    } else if (_key_down) {
        _grav_final = grav;
        _grav_max_final = grav_max;
    }

    vsp += _grav_final;
    vsp = clamp(vsp, _vsp_min_clamp, _grav_max_final);
}

// --- Ground Jump & Coyote Time ---
if (_on_ground) {
    vsp = 0;
    coyote_time = 10;

    if (jump_buffer > 0) {
        vsp = jump_height;
        jump_buffer = 0;
    }
} else {
    coyote_time--;

    if (_key_jump && coyote_time > 0) {
        vsp = jump_height;
        coyote_time = 0;
    }
}

// --- Variable Jump Height ---
if (_is_ascending && !_key_jump_held) {
    vsp = max(vsp, jump_height_min);
}

// --- Apply Movement ---
x += hsp;
if (place_meeting(x, y, oBlock)) {
    var _pixel_step = sign(hsp);
    while (place_meeting(x, y, oBlock)) {
        x -= _pixel_step;
    }
    hsp = 0;
}

y += vsp;
if (place_meeting(x, y, oBlock)) {
    var _pixel_step = sign(vsp);
    while (place_meeting(x, y, oBlock)) {
        y -= _pixel_step;
    }
    vsp = 0;
}

// --- Animation ---
if (!_on_ground) {
    switch (wall_jump_state) {
        case WallJumpState.GRAB:
        case WallJumpState.SLIDE:
            sprite_index = sPlayerOnWall;
            image_speed = 0;
            image_xscale = -_on_wall;
            break;

        default:
            sprite_index = sPlayerInAir;
            image_index = (vsp < 0) ? 0 : 1;
            image_speed = 0;
            break;
    }
} else {
    if (_is_moving) {
        sprite_index = sPlayerRun;
        image_speed = 1;
    } else {
        sprite_index = sPlayer;
        image_speed = 1;
    }
}

// --- Enemy Collision ---
if (place_meeting(x, y, oBad)) {
    instance_create_layer(0, 0, "l_Faders", oFader);
    oFader.fader_mode = "respawn";
}

// --- Debug Respawn ---
if (keyboard_check(vk_enter)) {
    instance_create_layer(0, 0, "l_Faders", oFader);
    oFader.fader_mode = "respawn";
}
