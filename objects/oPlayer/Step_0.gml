#region INPUT AND VARIABLES
// Execute the script that handles all input.
var _player_input = scr_player_input();

// Declare and get local variables for the rest of the step event.
// These variables are now retrieved from the _player_input struct.
var _key_left = _player_input.key_left;
var _key_right = _player_input.key_right;
var _key_jump = _player_input.key_jump;
var _key_jump_held = _player_input.key_jump_held;
var _key_attack_pressed = _player_input.key_attack_pressed; // Get attack key input
var _dir = _player_input.dir;

// --- Collision Tileset ---
// var collision_tileset = layer_tilemap_get_id("t_Collision");
var collision_cave01 = layer_tilemap_get_id("t_Collision");
var collision_slopes = layer_tilemap_get_id("t_Slopes"); // new layer to handle slopes
var collision_tileset = [collision_cave01, collision_slopes, objBreakableWall]; // new variable to hold all collidables


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
if (invulnerable_timer > 0) { invulnerable_timer--; }
if (flash_timer > 0) { flash_timer--; }
if (attack_timer > 0) { attack_timer--; }
    
// NEW: Knockback Timers
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
    // Clamp vertical speed to prevent it from exceeding max falling speed.
    vsp = min(vsp, grav_max);
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
// Attack Input Check (takes priority over other transitions) - Now calls a dedicated script
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
    // NEW: Spawn dust cloud on landing
    scr_spawn_dust_cloud(x, y, facing_direction);
    
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
#endregion



#region HORIZONTAL MOVEMENT PHYSICS (DEFAULT AND KNOCKBACK)
if (knockback_active) {
    // Apply knockback-specific friction/deceleration
    if (abs(hsp) > knockback_h_friction) {
        hsp -= sign(hsp) * knockback_h_friction;
    } else {
        hsp = 0; // Snap to zero
    }
    // End knockback if duration timer runs out
    if (knockback_duration_timer <= 0) {
        knockback_active = false;
        hsp = 0; // Stop any residual knockback hsp
        vsp = 0; // Stop any residual knockback vsp
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
            hsp = 0; // Snap to zero
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
        scr_player_state_air(_key_jump_held, _on_wall, _is_touching_wall, _is_pressing_wall, _dir);
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
if (player_state != PlayerState.ATTACK && !knockback_active) { // Prevent changing direction during attack or knockback
    if (_dir != 0) {
        facing_direction = _dir;
    } else if (hsp != 0) {
        facing_direction = sign(hsp);
    }
}
#endregion



#region HAZARD & ENEMY DAMAGE
// --- Enemy/Hazard Collision and Damage ---
// Note: Player taking damage is separate from player dealing damage.
// Player dealing damage is handled by oPlayerAttackSlash.
var _collided_enemy = instance_place(x, y, oEnemy);

if ((_collided_enemy != noone) && invulnerable_timer <= 0) { // Condition updated to only check for enemy collision here
    var _damage_taken = 0;
    if (_collided_enemy != noone) {
        _damage_taken = _collided_enemy.enemy_damage;
    } 

    if (_damage_taken > 0) {
        if (player_health - _damage_taken > 0) {
            audio_play_sound(sndPlayerTakesDamage, 10, false);
        }
        player_health -= _damage_taken;
        invulnerable_timer = invulnerable_duration;
        flash_timer = flash_duration;
                
        // Apply knockback to player if hit by an enemy (not hazards)
        if (_collided_enemy != noone) {
            // Use the _collided_enemy's 'attack_knockback_h_strength' and 'attack_knockback_v_strength'
            // This means the enemy's attack itself defines the knockback inflicted.
            scr_status_effect_knockback(id, _collided_enemy.x, _collided_enemy.attack_knockback_h_strength, _collided_enemy.attack_knockback_v_strength);
        }
    }
}
#endregion

#region MISC LOGIC
// Update previous image index for animation sound logic
image_index_previous = image_index;
#endregion

player_state_previous = player_state;