#region PLAYER INPUT
if (can_control && player_state != PlayerState.DEAD) {
    // Get keyboard/gamepad inputs and sets variables like key_left, key_right, _key_jump, etc.
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

// Apply wall jump input lockout
if (wall_jump_move_loss_timer > 0) {
    // If player is pressing back toward the wall we just jumped from, ignore it
    if (sign(_dir) == last_wall_dir) {
        _dir = 0;
    }
}


// --- Collision Tileset --- 
// Kept in the oGameManager persistent object for single source of all collidables.
collision_tileset = global.collision_environment;

// This group contains only the objects that should NOT allow wall grabs.
var non_grabbable_solids = [oInvisibleBlock];
#endregion


#region PLAYER TIMER MANAGEMENT
if (invulnerable_timer > 0) { invulnerable_timer--; }
if (flash_timer > 0) { flash_timer--; }
if (attack_timer > 0) { attack_timer--; }
    
// Knockback Timers
if (knockback_cooldown_timer > 0) { knockback_cooldown_timer--; }
if (knockback_duration_timer > 0) { knockback_duration_timer--; }

// Ledge grab timer
if (ledge_grab_timer > 0) { ledge_grab_timer--;  }

// Wall jump gravity bypass
if (wall_jump_gravity_bypass_timer > 0) { wall_jump_gravity_bypass_timer--; }
    
// Wall jump move loss timer
if (wall_jump_move_loss_timer > 0) { wall_jump_move_loss_timer--; }
#endregion


#region PLAYER ACTIONS
// --- Process Jump Input ---
var _jump_type = action_request_jump(_key_jump);

// --- Process Attack Input ---
scr_player_input_attack(_key_attack_pressed);
#endregion


#region HORIZONTAL MOVEMENT PHYSICS (ACCEL / DECEL AND KNOCKBACK)
// --- Knockback Physics ---
if (knockback_active) {
    // Apply knockback-specific friction/deceleration
    if (abs(x_speed) > knockback_h_friction) {
        x_speed -= sign(x_speed) * knockback_h_friction;
    } else {
        x_speed = 0;
    }

    // End knockback if duration timer runs out
    if (knockback_duration_timer <= 0) {
        knockback_active = false;
        x_speed = 0;
        y_speed = 0;
    }
}

// --- Normal Movement Physics ---
if (!knockback_active) {
    if (_dir != 0) {
        // Accelerate towards max speed in the input direction
        x_speed += _dir * accel;
        x_speed = clamp(x_speed, -max_x_speed, max_x_speed);
    } else {
        // If no horizontal input, apply deceleration
        if (abs(x_speed) > decel) {
            x_speed -= sign(x_speed) * decel;
        } else {
            x_speed = 0;
        }
    }
}
#endregion


#region VERTICAL MOVEMENT PHYSICS (GRAVITY AND KNOCKBACK)
// Wall slide and wall grab states handle their own vertical movement, overriding default gravity.
// Therefore, only apply general gravity if not in those states.
if (player_state != PlayerState.WALL_SLIDE && player_state != PlayerState.WALL_GRAB) {
    
    // Only apply gravity if coyote hang has expired
    if (coyote_hang_timer <= 0) {
        y_speed += grav;
        y_speed = min(y_speed, grav_max); // Clamp vertical speed to prevent exceeding max falling speed
    }

    // No upper clamp for y_speed when knocked back, allowing full upward impulse.
    // Otherwise, clamp to normal max upward speed for regular jumps.
    if (!knockback_active) {
        y_speed = max(y_speed, -grav_max);
    }
}
#endregion


#region JUMP LOGIC
// --- Execute Jump ---
if (_jump_type != "") {
    action_execute_jump(_jump_type, on_wall);
}

// --- Set variable jump sustain ---
if (_key_jump_held && jump_speed_sustain_timer > 0) {
    y_speed = jump_speed[jump_count -1];   // sustain upward velocity
} else if (!_key_jump_held) {
    jump_speed_sustain_timer = 0;    // cutoff if released
}

// --- Variable jump sustain timer ---
if (jump_speed_sustain_timer > 0) { 
    jump_speed_sustain_timer--; 
}

// --- Coyote Jump grace timer ---
// Count down here, since it's part of jump grace logic, not gravity.
if (coyote_jump_timer > 0) {
    coyote_jump_timer--;
}

// --- Coyote Hang timer ---
// This is where we decrement it now, separated from gravity.
if (coyote_hang_timer > 0) {
    coyote_hang_timer--;
}

// --- Jump Input Buffer ---
if (_key_jump && !on_ground) {
    jump_input_buffer_timer = jump_input_buffer_frames;
}
if (jump_input_buffer_timer > 0) { 
    jump_input_buffer_timer--; 
}

// --- Jump Sound Combo ---
if (jump_combo_timer > 0) {
    jump_combo_timer--;
} else {
    consecutive_jumps = 0;
}
#endregion


#region STATE PHYSICS OVERRIDES
switch (player_state) {
    case PlayerState.WALL_GRAB:
        x_speed = 0;
        y_speed = 0;
        break;
    case PlayerState.WALL_SLIDE:
        // Apply reduced gravity for wall sliding.
        y_speed = clamp(y_speed + grav_wall, 0, grav_wall_max);
    
        // Stop horizontal movement.
        x_speed = 0;
        break;
    case PlayerState.ATTACK: 
        if (on_ground) {
            x_speed = 0; // Temporarily disable horizontal movement when attacking on the ground
        }
        break;
    case PlayerState.DEAD:
    // Stop movement - you're dead
    x_speed = 0;
    y_speed = 0;
    
    // Check lives
    if (oGameManager.player_lives > 0) {
        oGameManager.player_lives--;
        oGameManager.next_action = "respawn";
    } else {
        oGameManager.next_action = "game_over";
    }
    
    oGameManager.current_state = GAME_STATE.FADING_OUT;
    instance_destroy();
        break;
}
#endregion


#region HORIZONTAL MOVEMENT RESOLUTION
    
var _sub_pixel = .5;

// --- Move horizontally until collision ---
if (place_meeting(x + x_speed, y, collision_tileset)) {
    // Handle upward slope movement
    // && !place_meeting(x + x_speed, y - 1, collision_tileset) // but not a vertical wall
    if (!place_meeting(x + x_speed, y - abs(x_speed) - 1, collision_tileset)) {
        while (place_meeting(x + x_speed, y, collision_tileset)) {
            y -= _sub_pixel;
        }
    }

    // Normal movement (no slopes)
    else { 
        var _x_pixel_step = _sub_pixel * sign(x_speed);
        while (!place_meeting(x + _x_pixel_step, y, collision_tileset)) {
            x += _x_pixel_step;
        }
        x_speed = 0;
    }
}

// Handle going down slopes
if (y_speed >= 0 && !place_meeting(x + x_speed, y + 1, collision_tileset) && place_meeting(x + x_speed, y + abs(x_speed) + 1, collision_tileset)) {
    while (!place_meeting(x + x_speed, y + _sub_pixel, collision_tileset)) {
        y += _sub_pixel;
    }
}

// --- Commit to horizontal movement ---
x += x_speed;

// --- Flush out of wall to prevent corner clipping ---
if (on_wall != 0) { // only if we know which side we're on
    while (place_meeting(x, y, collision_tileset)) {
        x -= _sub_pixel * on_wall; // push out opposite the wall direction
    }
}

// --- Clamp horizontal position to room bounds based on mask of the instance ---
var _half_sprite_mask = .5 * (bbox_right - bbox_left);
x = clamp(x, _half_sprite_mask, room_width - _half_sprite_mask);
#endregion


#region VERTICAL MOVEMENT RESOLUTION
// --- Move vertically until collision ---
if (place_meeting(x, y + y_speed, collision_tileset)) {
    var _y_pixel_step = _sub_pixel * sign(y_speed);
    while (!place_meeting(x, y + _y_pixel_step, collision_tileset)) {
        y += _y_pixel_step;
    }
    // Stop jump_speed_sustain_timer if your y_speed is less than 0 when you collide with something above you.
    if (y_speed < 0) {
    	jump_speed_sustain_timer = 0;
    }
    y_speed = 0;
}

// --- Commit Vertical Movement ---
y += y_speed;
#endregion


#region COLLISION CHECKS - Post movement
// --- Ground Check ---
var _is_on_ground = (y_speed >= 0 && place_meeting(x, y + 1, collision_tileset));
set_on_ground(_is_on_ground);

on_wall = place_meeting(x + 1, y, collision_tileset) - place_meeting(x - 1, y, collision_tileset);
var _is_pressing_wall = (sign(_dir) == on_wall) && (_dir != 0);
var _is_touching_grabbable_wall = false;
if (on_wall != 0) {
    // A wall is grabbable if it is NOT in the non-grabbable list.
    if (!place_meeting(x + on_wall, y, non_grabbable_solids)) {
        _is_touching_grabbable_wall = true;
    }
}
#endregion


// DEATH transition TODO: Find a better place for this. We want to include a death animation
if ((player_health <= 0 || y > fall_threshold) && player_state != PlayerState.DEAD) {
    player_state = PlayerState.DEAD;
}

#region STATE MACHINE - Post movement
switch (player_state) {
    case PlayerState.IDLE:
        // Set the sprite and image speed for the idle state.
        sprite_index = sPlayerIdle;
        image_speed = 1;
        
        // IDLE → AIR (e.g., walking off a ledge or actively in knockback)
        if (!on_ground && !knockback_active) {
            player_state = PlayerState.AIR;
            jump_count = 1;
        }
    
        // IDLE -> RUN
        else if (_dir != 0) {
            show_debug_message("IDLE -> RUN");
            player_state = PlayerState.RUN;
        }
        break;
    case PlayerState.RUN:
        show_debug_message("IN RUN STATE");
        // Set the sprite and image speed for the running state.
        sprite_index = sPlayerRun;
        image_speed = 1;
    
        // Running sound logic: play the step sound at the beginning of animation frames 0 and 2.
        if ((floor(image_index) == 0 || floor(image_index) == 2) && (floor(image_index_previous) != floor(image_index))) {
            if (current_step_sound == 0) {
                audio_play_sound(sndPlayerStep01, 1, false);
                current_step_sound = 1; // Switch to the next sound
            } else {
                audio_play_sound(sndPlayerStep02, 1, false);
                current_step_sound = 0; // Switch back
            }
            // Spawn dust cloud on the same frames as the step sounds
            scr_spawn_dust_cloud(x, y, facing_direction);
        }
        
        // RUN → AIR (e.g., walking off a ledge or actively in knockback)
        if (!on_ground && !knockback_active) {
            show_debug_message("RUN -> AIR");
            player_state = PlayerState.AIR;
            jump_count = 1;
        }
        
        // RUN -> IDLE
        else if (_dir == 0) { // If no input, switch to the IDLE state.
            show_debug_message("RUN -> IDLE");
            player_state = PlayerState.IDLE;
        }
        break;
    case PlayerState.AIR:
        show_debug_message("IN AIR STATE");
        // Set air sprite depending on if ascending or descending
        if (y_speed < 0) {
            sprite_index = sPlayerAirAscending;
        } else {
            sprite_index = sPlayerAirDescending;
            image_speed = 1;
        }
        
        // AIR → WALL_GRAB (First priority)
        if (!on_ground && _is_touching_grabbable_wall && _is_pressing_wall && y_speed > 0 && wall_jump_gravity_bypass_timer <= 0) {
            show_debug_message("AIR -> WALL GRAB");
            player_state = PlayerState.WALL_GRAB;
            wall_grab_timer = 0; // Reset the timer for the new grab
            jump_count = 0; // reset jumps on wall grab
            audio_play_sound(sndPlayerStep01, 1, false);
            scr_spawn_dust_cloud(x, y, -on_wall, on_wall);
        }
        
        // AIR → IDLE/RUN (Second priority: ground landing)
        else if (on_ground) {
            // Check if the player was truly in an AIR state in the previous frame
            // to prevent playing the landing sound immediately after initiating a jump.
            if (player_state_previous == PlayerState.AIR) {
                audio_play_sound(sndPlayerJumpLanding, 10, false);
                scr_spawn_dust_cloud(x, y, facing_direction);
            }
            if (_dir != 0) {
                show_debug_message("AIR -> RUN");
                player_state = PlayerState.RUN;
            } else {
                show_debug_message("AIR -> IDLE");
                player_state = PlayerState.IDLE;
            }
        }
        break;
    case PlayerState.WALL_GRAB:
        show_debug_message("IN WALL GRAB STATE");
        // Set sprite for the duration of the grab.
        sprite_index = sPlayerOnWall;
        image_speed = 0;
        image_xscale = -on_wall;
    
        // WALL GRAB -> AIR
        if (!_is_pressing_wall) {
            player_state = PlayerState.AIR;
        } else {
            // Otherwise, continue the grab.
            wall_grab_timer++;
    
            // WALL GRAB -> WALL SLIDE
            if (wall_grab_timer >= wall_grab_timer_max) {
                show_debug_message("IN WALL GRAB STATE -> WALL SLIDE");
                player_state = PlayerState.WALL_SLIDE;
                audio_play_sound(sndPlayerWallSlide, 10, false);
            }
        }
        break;
    case PlayerState.WALL_SLIDE:
       show_debug_message("IN WALL SLIDE STATE");
   
       // Play wall slide sound
       if (!audio_is_playing(sndPlayerWallSlide)) {
           audio_play_sound(sndPlayerWallSlide, 10, false);
       }
   
       // Set sprite
       sprite_index = sPlayerOnWall;
       image_speed = 1;
       image_xscale = -on_wall;
   
       // Dust cloud spawning
       wall_slide_dust_timer++;
       if (wall_slide_dust_timer >= wall_slide_dust_timer_max) {
           wall_slide_dust_timer = 0;
           scr_spawn_dust_cloud(x, y, -on_wall, on_wall);
       }
   
       // WALL SLIDE → IDLE/RUN (only after lock expires)
       if (on_ground && y_speed >= 0) {
           if (_dir != 0) {
               show_debug_message("WALL SLIDE -> RUN");
               player_state = PlayerState.RUN;
           } else {
               show_debug_message("WALL SLIDE -> IDLE");
               player_state = PlayerState.IDLE;
           }
           audio_stop_sound(sndPlayerWallSlide);
       }
   
       // WALL SLIDE → AIR
       else if (!_is_pressing_wall || !_is_touching_grabbable_wall) {
           player_state = PlayerState.AIR;
           audio_stop_sound(sndPlayerWallSlide);
       }
    break;
    case PlayerState.ATTACK: 
        // --- On-Entry Logic (first frame of the ATTACK state) ---
        if (player_state_previous != PlayerState.ATTACK) {
            
            // Set sprites
            if (!on_ground) {
            	sprite_index = sPlayerAirAttack;
            } else {
                sprite_index = sPlayerAttack;
            }
            
            // Play attack sound
            audio_play_sound(sndPlayerAttack, 10, false); 
            
            // Create the attack slash object
            // Position it relative to the player, slightly in front based on facing_direction
            // Pass the player's variable into the function
            var _total_x_offset = scr_get_offset(sPlayerAttack, sPlayerAttackSlash, -32);
            var _slash_x = x + facing_direction * _total_x_offset;
            current_attack_slash = instance_create_layer(_slash_x, y, "ilMiddle", oPlayerAttackSlash);
            
            if (instance_exists(current_attack_slash)) {
                current_attack_slash.owner = id; // Set the owner to this player instance
                current_attack_slash.image_xscale = facing_direction; // Match player's direction
            }
            attack_timer = attack_duration; // Start attack timer
        }
     
        // When attack animation is over
        if (attack_timer <= 0) {
    
            // Transition back to an appropriate state based on whether the player is on the ground
            if (on_ground) {
                // After a ground attack, revert to IDLE since x_speed was forced to 0.
                player_state = PlayerState.IDLE;
            } else { // If not on ground, go to AIR
                player_state = PlayerState.AIR;
            }
        }
        break;
    case PlayerState.DEAD:
    audio_play_sound(sndPlayerDeath, 10, false);
        break;
}
#endregion


#region UPDATE VISUALS
// Update facing direction based on input or momentum
if (player_state != PlayerState.ATTACK && !knockback_active) { // Prevent changing direction during attack or knockback
    if (_dir != 0) {
        facing_direction = _dir;
    } else if (x_speed != 0) {
        facing_direction = sign(x_speed);
    }
}
#endregion


#region BOOKKEEPING
// Keep track of previous variable values
image_index_previous = image_index; // // Update previous image index for animation sound logic
player_state_previous = player_state;
#endregion