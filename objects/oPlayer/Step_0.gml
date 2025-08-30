// --- Player Movement and Collision Logic ---

#region VARIABLES
// --- Get tilemap ID for collision ---
var collision_tileset = layer_tilemap_get_id("t_Collision"); // Get the ID of the collision tilemap layer

// Declare all local variables used within this step event
var _key_left = 0; // True if 'A' is pressed
var _key_right = 0; // True if 'D' is pressed
var _key_jump = 0; // True if 'Space' is pressed (single press)
var _key_jump_held = 0; // True if 'Space' is held down
var _key_down = 0; // True if 'S' is pressed
var _dir = 0; // Calculated horizontal input direction (-1 left, 0 none, 1 right)
var _is_moving = false; // True if player has horizontal speed
var _is_ascending = false; // True if player is moving upwards
var _is_descending = false; // True if player is moving downwards
var _on_ground = false; // True if player is touching the ground
var _on_wall = 0; // Indicates wall direction (-1 left, 0 none, 1 right)
var _is_touching_wall = false; // True if player is touching any wall
var _is_pressing_wall = false; // True if player is pressing against a wall in their movement direction
var _can_wall_grab = false; // True if conditions for initiating a wall grab are met
#endregion

#region TIMER MANAGEMENT
// --- Invulnerability and Flash Timers ---
if (invulnerable_timer > 0) {
    invulnerable_timer--; // Decrement invulnerability timer
}
if (flash_timer > 0) {
    flash_timer--; // Decrement flash timer for visual feedback
}
#endregion

#region COLLISION CHECKS (Initial)
// --- Ground Check ---
// Checks if the player is one pixel above the collision tilemap
_on_ground = place_meeting(x, y + 1, collision_tileset);

// --- Movement Check ---
// Determines if the player is currently moving horizontally
_is_moving = hsp != 0;

// --- Vertical State Checks ---
// Determines if the player is ascending or descending
_is_ascending = vsp < 0; // Player is moving upwards
_is_descending = vsp > 0; // Player is moving downwards

// --- Wall Check ---
// Checks for walls to the right and left, determining _on_wall direction
_on_wall = place_meeting(x + 1, y, collision_tileset) - place_meeting(x - 1, y, collision_tileset);
_is_touching_wall = (_on_wall != 0); // True if touching a wall on either side
#endregion

#region INPUT HANDLING
// --- Input ---
// Reads player input only if control is enabled (not in a cinematic)
if (can_control) {
    _key_left = keyboard_check(ord("A")); // Check if 'A' key is held
    _key_right = keyboard_check(ord("D")); // Check if 'D' key is held
    _key_jump = keyboard_check_pressed(vk_space); // Check for a single press of 'Space'
    _key_jump_held = keyboard_check(vk_space); // Check if 'Space' key is held
    _key_down = keyboard_check(ord("S")); // Check if 'S' key is held
}

// --- Direction ---
// Calculates horizontal input direction, ignoring input during wall jump recovery
if (can_control && wall_jump_state != WallJumpState.RECOVER) {
    _dir = _key_right - _key_left; // -1 for left, 1 for right, 0 for no input
}
#endregion

#region WALL INTERACTION LOGIC
// --- Wall Interaction ---
// Determines if the player is pressing against a wall (e.g., holding 'left' into a left wall)
_is_pressing_wall = (sign(_key_right - _key_left) == _on_wall);

// --- Refined Wall Grab Detection ---
var _vaulting = (vsp < -6); // Prevents wall grab if player is actively vaulting upwards
_can_wall_grab = _is_touching_wall && !_on_ground && _is_pressing_wall; // Basic conditions for wall grab
var _valid_wall_grab = _can_wall_grab && !_vaulting; // Final check for a valid wall grab

// --- Wall Jump State Machine ---
switch (wall_jump_state) {
    case WallJumpState.NONE:
        if (_valid_wall_grab) {
            wall_jump_state = WallJumpState.GRAB; // Enter wall grab state
            wall_grab_timer = 0; // Reset wall grab timer
            wall_jump_gravity_bypass = wall_jump_gravity_bypass_max; // Temporarily suppress gravity
        }
        break;

    case WallJumpState.GRAB:
        wall_grab_timer++; // Increment wall grab timer

        if (wall_grab_timer <= wall_grab_timer_max) {
            wall_jump_gravity_bypass = wall_grab_timer_max; // Keep gravity suppressed during initial grab
            vsp = 0; // Stop vertical movement
        }

        // ✅ Allow wall jump during grab
        if (_key_jump) {
            hsp = -_on_wall * wall_jump_distance; // Apply horizontal wall jump force
            vsp = jump_height_wall - 2; // Apply vertical wall jump force
            wall_jump_delay = wall_jump_delay_max; // Start wall jump input lockout timer
            wall_jump_gravity_bypass = 0; // ✅ Reset gravity bypass immediately on jump
            wall_jump_state = WallJumpState.JUMP; // Transition to wall jump state
        }

        if (wall_grab_timer >= wall_grab_timer_max) {
            wall_jump_state = WallJumpState.SLIDE; // Transition to wall slide after grab time
        }

        if (!_valid_wall_grab) {
            wall_jump_state = WallJumpState.NONE; // Exit wall grab if conditions are no longer met
        }
        break;

    case WallJumpState.SLIDE:
        if (!_valid_wall_grab) {
            wall_jump_state = WallJumpState.NONE; // Exit wall slide if conditions are no longer met
        }

        if (_key_jump) {
            hsp = -_on_wall * wall_jump_distance; // Apply horizontal wall jump force
            vsp = jump_height_wall - 2; // Apply vertical wall jump force
            wall_jump_delay = wall_jump_delay_max; // Start wall jump input lockout timer
            wall_jump_gravity_bypass = 0; // ✅ Reset gravity bypass immediately on jump
            wall_jump_state = WallJumpState.JUMP; // Transition to wall jump state
        }
        break;

    case WallJumpState.JUMP:
        wall_jump_state = WallJumpState.RECOVER; // Immediately transition to recovery after jump
        break;

    case WallJumpState.RECOVER:
        if (wall_jump_delay > 0) {
            wall_jump_delay--; // Decrement recovery timer
        } else {
            wall_jump_state = WallJumpState.NONE; // Exit recovery when timer runs out
        }
        break;
}
#endregion

#region HORIZONTAL MOVEMENT & INPUT
// --- Horizontal Movement ---
if (can_control) {
    if (wall_jump_state == WallJumpState.GRAB || wall_jump_state == WallJumpState.SLIDE) {
        _dir = 0; // No horizontal input influence during wall grab/slide
        hsp = 0; // Stop horizontal movement during wall grab/slide
    }

    // Prevents player from 'sticking' to walls if already on ground and trying to move into a wall
    if (_on_ground && _dir != 0 && place_meeting(x + _dir, y, collision_tileset)) {
        hsp = 0; // Stop horizontal movement
        _dir = 0; // Clear directional input
    }

    if (_dir != 0) {
        hsp += _dir * accel; // Accelerate in input direction
    } else {
        hsp = (hsp > 0) ? max(hsp - decel, 0) : min(hsp + decel, 0); // Decelerate to stop
    }

    hsp = clamp(hsp, -max_hsp, max_hsp); // Clamp horizontal speed within limits
} else {
    hsp = 0; // Stop horizontal movement if player control is disabled
}
#endregion

#region JUMP BUFFER & GRAVITY
// --- Jump Buffer ---
if (can_control && _key_jump) {
    jump_buffer = 10; // Set jump buffer timer if jump is pressed
}
jump_buffer--; // Decrement jump buffer timer

// --- Gravity ---
if (wall_jump_gravity_bypass > 0) {
    wall_jump_gravity_bypass--; // Decrement gravity bypass timer
} else {
    var _grav_final = grav; // Default gravity
    var _grav_max_final = grav_max; // Default max gravity
    var _vsp_min_clamp = jump_height; // Default minimum vertical speed (for jump height)

    if (wall_jump_state == WallJumpState.SLIDE) {
        _grav_final = grav_wall; // Use wall slide gravity
        _grav_max_final = grav_max_wall; // Use wall slide max gravity
        _vsp_min_clamp = 0; // Allow vsp to go to 0 during wall slide
    } else if (_key_down) {
        // Potentially apply fast fall gravity if 'down' is held (adjust grav values as needed)
        _grav_final = grav; 
        _grav_max_final = grav_max; 
    }

    vsp += _grav_final; // Apply gravity to vertical speed
    vsp = clamp(vsp, _vsp_min_clamp, _grav_max_final); // Clamp vertical speed
}
#endregion

#region GROUND JUMP & VARIABLE JUMP
// --- Ground Jump & Coyote Time ---
if (_on_ground) {
    vsp = 0; // Reset vertical speed on ground
    coyote_time = 10; // Reset coyote time

    if (jump_buffer > 0) {
        vsp = jump_height; // Perform a jump from buffer
        jump_buffer = 0; // Clear jump buffer
    }
} else {
    coyote_time--; // Decrement coyote time when in air

    if (_key_jump && coyote_time > 0) {
        vsp = jump_height; // Perform a jump using coyote time
        coyote_time = 0; // Clear coyote time
    }
}

// --- Variable Jump Height ---
// Shortens jump if jump key is released early while ascending
if (_is_ascending && !_key_jump_held) {
    vsp = max(vsp, jump_height_min); // Limit upward speed to minimum jump height
}
#endregion

#region APPLY MOVEMENT & TILEMAP COLLISION RESOLUTION
// --- Apply Movement ---
// Apply horizontal speed and resolve collision with the tilemap
x += hsp;
if (place_meeting(x, y, collision_tileset)) {
    var _pixel_step = sign(hsp); // Determine direction of collision
    if (_pixel_step == 0) { // Failsafe for hsp=0
        _pixel_step = 1; // Default push direction
    }
    while (place_meeting(x, y, collision_tileset)) { // Move back pixel by pixel until no longer colliding
        x -= _pixel_step;
    }
    hsp = 0; // Stop horizontal movement after collision
}

// Apply vertical speed and resolve collision with the tilemap
y += vsp;
if (place_meeting(x, y, collision_tileset)) {
    var _pixel_step = sign(vsp); // Determine direction of collision
    if (_pixel_step == 0) { // Failsafe for vsp=0
        _pixel_step = -1; // Default push direction (up)
    }
    while (place_meeting(x, y, collision_tileset)) { // Move back pixel by pixel until no longer colliding
        y -= _pixel_step;
    }
    vsp = 0; // Stop vertical movement after collision
}
#endregion

#region ANIMATION & SPRITE ORIENTATION
// --- Animation ---
// Handle player animations based on ground state and wall jump state
if (!_on_ground) {
    switch (wall_jump_state) {
        case WallJumpState.GRAB:
        case WallJumpState.SLIDE:
            sprite_index = sPlayerOnWall; // Set sprite for wall grab/slide
            image_speed = 0; // Stop animation
            image_xscale = -_on_wall; // Flip sprite based on wall direction
            break;

        default:
            sprite_index = sPlayerInAir; // Set sprite for jumping/falling
            image_index = (vsp < 0) ? 0 : 1; // Show first frame for ascent, second for descent
            image_speed = 0; // Stop animation
            break;
    }
} else {
    if (_is_moving) {
        sprite_index = sPlayerRun; // Set sprite for running
        image_speed = 1; // Play running animation
    } else {
        sprite_index = sPlayerIdle; // Set sprite for idle
        image_speed = 0; // Stop animation
        image_index = 0; // Reset to first frame of idle
    }
    
    // --- Sprite Flipping Logic ---
    // Only flip if not wall sliding/grabbing (where image_xscale is already set by _on_wall)
    if (wall_jump_state == WallJumpState.NONE || wall_jump_state == WallJumpState.RECOVER) {
        if (_dir != 0) { // If there's active directional input
            image_xscale = _dir; // Flip sprite based on input direction
        } else if (hsp != 0) { // If still moving from momentum but no input
            image_xscale = sign(hsp); // Flip sprite based on current momentum direction
        }
    }
}
#endregion

#region HAZARD & ENEMY DAMAGE (UPDATED)
// --- Enemy/Hazard Collision and Damage ---
// Checks for collision with enemy objects or hazards
var _collided_enemy = instance_place(x, y, oEnemy); // Get the ID of the enemy collided with
var _collided_hazard = place_meeting(x, y, oHazard); // Check for hazard collision

if ((_collided_enemy != noone || _collided_hazard) && invulnerable_timer <= 0) {
    var _damage_taken = 0;
    if (_collided_enemy != noone) {
        _damage_taken = _collided_enemy.enemy_damage; // Get damage from the enemy
    } else if (_collided_hazard) {
        _damage_taken = 1; // Default damage for hazards (can be made a variable later)
    }

    if (_damage_taken > 0) {
        player_health -= _damage_taken; // Decrement player health
        invulnerable_timer = invulnerable_duration; // Start invulnerability timer
        flash_timer = flash_duration; // Start visual flash timer

        // Trigger enemy taunt (if an enemy caused damage)
        if (_collided_enemy != noone) {
            // Check if the enemy is not already taunting to prevent re-triggering
            if (_collided_enemy.enemy_state != ENEMY_STATE.TAUNT) {
                _collided_enemy.enemy_state = ENEMY_STATE.TAUNT; // Set enemy to taunt state
                _collided_enemy.taunt_timer = _collided_enemy.taunt_duration; // Start enemy taunt timer
            }
        }
    }

    // --- Player Death and Respawn Logic (FIXED) ---
    if (player_health <= 0) {
        // First, check if the player has any lives left
        if (oPlayerController.player_lives > 0) {
            // Player has lives remaining: Decrement life and respawn
            oPlayerController.player_lives--; // Decrement a life
            oPlayerController.crystals_collected = 0; // Lose all crystals on respawn
            player_health = oPlayerController.max_player_health; // Reset player health to full
            
            // Trigger respawn sequence via fader.
            // The fader object will handle moving the player to global.checkpoint_x/y
            instance_create_layer(0, 0, "l_Faders", oFader); 
            oFader.fader_mode = "respawn"; 
        } else {
            // Player has no lives remaining: GAME OVER
            // Reset oPlayerController stats for a fresh game start
            oPlayerController.player_lives = 1; // Reset to default starting lives
            oPlayerController.crystals_collected = 0; // Reset crystals
            player_health = oPlayerController.max_player_health; // Reset player health to full
            
            room_restart(); // Restart the entire room (Game Over)
            // You might want to transition to a dedicated "Game Over" room here later
        }
    }
}

// --- Debug Respawn ---
// Allows for quick respawn with 'Enter' key press
if (keyboard_check(vk_enter)) {
    // If player has lives, respawn with full health
    if (oPlayerController.player_lives > 0) { // Check lives from oPlayerController
        player_health = oPlayerController.max_player_health; // Reset health to full
        oPlayerController.crystals_collected = 0; // Lose all crystals from oPlayerController
        
        // Trigger respawn sequence via fader for debug
        instance_create_layer(0, 0, "l_Faders", oFader); 
        oFader.fader_mode = "respawn"; 
    } else {
        // If no lives, this debug key can act as an instant game over for testing
        // Reset oPlayerController stats for a fresh game start
        oPlayerController.player_lives = 1; // Reset to default starting lives
        oPlayerController.crystals_collected = 0; // Reset crystals
        player_health = oPlayerController.max_player_health; // Reset player health to full
        
        room_restart(); // Restart the entire room (Game Over)
    }
}
#endregion

#region CRYSTAL COLLECTION (UPDATED)
// --- Check for Crystal Collection ---
var _collected_crystal = instance_place(x, y, oCrystal); // Assuming you have an oCrystal object
if (_collected_crystal != noone) {
    oPlayerController.crystals_collected++; // Increment crystal count via oPlayerController
    instance_destroy(_collected_crystal); // Destroy the collected crystal

    // Check if enough crystals for an extra life
    if (oPlayerController.crystals_collected >= oPlayerController.max_crystals_for_life) {
        oPlayerController.player_lives++; // Gain a life via oPlayerController
        oPlayerController.crystals_collected = 0; // Reset crystal count via oPlayerController
        // Play a sound or show a visual effect for gaining a life here
    }
}
#endregion
