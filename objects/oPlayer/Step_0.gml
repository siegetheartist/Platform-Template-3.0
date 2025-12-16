moving_platform_collision_correction();


#region PLAYER INPUT
if (can_control && player_state != PlayerState.DEAD) {
    // Get keyboard/gamepad inputs and sets variables like key_left, key_right, _key_jump, etc.
    input = scr_player_get_input(); 
} else {
    // If we can't control the player, create a "zeroed-out" input struct
    // to prevent the rest of the code from crashing.
    input = {
        left_held: 0, right_held: 0, down_held: 0, jump_held: 0,
        left_pressed: 0, right_pressed: 0, down_pressed: 0, jump_pressed: 0, attack_pressed: 0,
        dir: 0
    };
}

// -- Local Variables for This Event --
// We create local variables from the 'input' struct for easier use below.
var _key_left = input.left_held;
var _key_right = input.right_held;
var _key_down = input.down_held;
var _key_jump = input.jump_pressed;
var _key_jump_held = input.jump_held;
var _key_attack_pressed = input.attack_pressed;
var _dir = input.dir;

// Apply wall jump input lockout
if (wall_jump_input_loss_timer > 0) {
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
    //show_debug_message("Flash timer: " + string(flash_timer));
if (attack_timer > 0) { attack_timer--; }
    
// Knockback Timers
if (knockback_cooldown_timer > 0) { knockback_cooldown_timer--; }
if (knockback_duration_timer > 0) { knockback_duration_timer--; }

// Ledge grab timer
if (ledge_grab_timer > 0) { ledge_grab_timer--;  }
if (ledge_regrab_lockout_timer > 0) { ledge_regrab_lockout_timer--; }

// Wall jump (input loss) timer
if (wall_jump_input_loss_timer > 0) { wall_jump_input_loss_timer--; }
#endregion


// DEATH transition 
if ((player_health <= 0 || y > fall_threshold) && player_state != PlayerState.DEAD) {
    player_state = PlayerState.DEAD;
}

// HURT
if (player_health_previous != player_health) {
    //damage_flash_alpha = 1;
    player_state = PlayerState.HURT;
    scr_obj_flash_initialize(id, 30, c_red);
}
//if (damage_flash_alpha > 0) {
//	damage_flash_alpha -= .05;
//}


#region STATE PHYSICS
switch (player_state) {
    case PlayerState.DEAD:
        x_speed = 0;
        y_speed = 0;
        break;
    case PlayerState.CROUCH:
        x_speed = 0;
        break
    case PlayerState.CROUCH_WALK:
        horizontal_physics(_dir, .3); // Slow down x_speed to a "CROUCH_WALK"
        vertical_physics();
        break;
    case PlayerState.LEDGE_GRAB:
        // Run through ledge grab into wall grab since they share x_speed and y_speed 
    case PlayerState.WALL_GRAB:
        x_speed = 0;
        y_speed = 0;
        break;
    case PlayerState.WALL_SLIDE:
        // Apply reduced gravity for wall sliding.
        y_speed = clamp(y_speed + grav_wall, 0, grav_wall_max);
        x_speed = 0;
        break;
    case PlayerState.ATTACK: 
        if (on_ground) {
            x_speed = 0;
        } else {
            horizontal_physics(_dir);
        }
        vertical_physics();
        break;
    default:
        horizontal_physics(_dir);
        vertical_physics();
        break;
}
#endregion End state physics


#region PLAYER ACTIONS (jump, attack, etc)
// --- Process Attack Input ---
scr_player_input_attack(_key_attack_pressed);

jump(_key_jump, _key_down, _key_jump_held);

// Enable jumping down through semi-solid platforms
if (_key_down && _key_jump) {
    
    // Ensure we are on a semi-solid object
    if ( instance_exists(my_floor_plat)
        && ( my_floor_plat.object_index == objSemiSolidWall || object_is_ancestor(my_floor_plat.object_index, objSemiSolidWall) ) ) {
        
        var _y_check = max(1, my_floor_plat.y_speed + 1);
        if ( !place_meeting(x, y + _y_check, objWall) ) {
            // Move below the platform
            y += 1;
            
            // Inherit any downward speed from my floor platform so it doesn't catch me
            y_speed = _y_check - 1;
            
            // Forget this platform for a brief time so we don't get caught again
            forget_semi_solid = my_floor_plat;
            
            // No more floor platform
            set_on_ground(false);
        }
    }
}

#endregion End player actions


#region HORIZONTAL & VERTICAL MOVEMENT
horizontal_movement();
vertical_movement();
#endregion


#region COLLISION CHECKS - Post movement

// Detect wall side (-1 = left, 1 = right)
on_wall = place_meeting(x + 1, y, collision_tileset) - place_meeting(x - 1, y, collision_tileset);
var _is_pressing_wall = (sign(_dir) == on_wall) && (_dir != 0);
var _touching_grabbable_wall = false;

// Flags
var _id_wall = noone;
var _bottom_corner_touching = false;
var _can_wall_grab = false;
var _can_ledge_grab = false;

if (on_wall != 0) {
    
    // Ledge grab: wall exists, empty space above, player top near wall top
    _id_wall = instance_place(x + on_wall, y, objWall);
    if (_id_wall != noone) {
        var _wall_is_ledge = !position_meeting(on_wall == 1 ? _id_wall.bbox_left : _id_wall.bbox_right, _id_wall.bbox_top - 1, objWall);
    	var _player_top_aligned_with_ledge = abs(bbox_top - _id_wall.bbox_top) <= 2;
        _can_ledge_grab = _wall_is_ledge && _player_top_aligned_with_ledge;
    }
    
    // Wall grab: both corners touching, wall is grabbable
    var _top_corner_touching = position_meeting((on_wall == 1) ? (bbox_right + 1) : (bbox_left - 1), bbox_top, collision_tileset);
    _bottom_corner_touching = position_meeting((on_wall == 1) ? (bbox_right + 1) : (bbox_left - 1), bbox_bottom - 6, collision_tileset); // -6 = grace zone
    var _entire_mask_against_wall = _top_corner_touching && _bottom_corner_touching;
    if (!place_meeting(x + on_wall, y, non_grabbable_solids)) {
        _touching_grabbable_wall = true;
    }
    _can_wall_grab = _touching_grabbable_wall && _entire_mask_against_wall;
}
can_wall_jump = !on_ground && _touching_grabbable_wall && _bottom_corner_touching;
#endregion


#region STATE MACHINE - Post movement
switch (player_state) {
    case PlayerState.IDLE:
        if (player_state_previous != PlayerState.IDLE) {
        	image_index = 0;
            image_speed = 1;
            show_debug_message("idle entry");
        }
        
        sprite_index = player_01.sprites.idle_01;
        
        // IDLE → AIR (e.g., walking off a ledge or actively in knockback)
        if (!on_ground && !knockback_active) {
            player_state = PlayerState.AIR;
        }
    
        // IDLE -> RUN
        else if (_dir != 0) {
            player_state = PlayerState.RUN;
        }
        
        // IDLE -> CROUCH
        else if (_key_down && instance_exists(my_floor_plat)) {
        	player_state = PlayerState.CROUCH;
        }
        break;
    
    case PlayerState.RUN:
        // On entry. Runs only once.
        if (player_state_previous != PlayerState.RUN) {
        	image_index = 0;
            image_speed = 1;
        }
        
        sprite_index = player_01.sprites.run;
    
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
            player_state = PlayerState.AIR;
        }
        
        // RUN → IDLE
        else if (_dir == 0) { // If no input, switch to the IDLE state.
            player_state = PlayerState.IDLE;
        }
        
        // RUN → CROUCH
        else if (_key_down) { // used to also have: && instance_exists(my_floor_plat)
        	player_state = PlayerState.CROUCH;
        }
        break;
    
    case PlayerState.CROUCH:
        sprite_index = player_01.sprites.crouch;
        image_speed = 1;
        mask_index = player_01.sprites.crouch_collision_mask;
        
        // CROUCH → AIR (e.g., walking off a ledge or actively in knockback)
        if (!on_ground) {
        	player_state = PlayerState.AIR;
        }
        
        // CROUCH → IDLE/RUN
        else if (!_key_down) {

            // Check for clearance above player before allowing a state change back to idle or run
            var _height_diff = compare_mask_heights(player_01.sprites.idle_01, player_01.sprites.crouch);
            
            if (x_speed == 0 && !place_meeting(x, y - _height_diff, objWall)) {
            	player_state = PlayerState.IDLE;
                mask_index = player_01.sprites.default_collision_mask;
            } 
        
            else if (x_speed != 0 && !place_meeting(x, y - _height_diff, objWall)) {
            	player_state = PlayerState.RUN;
                mask_index = player_01.sprites.default_collision_mask;
            }
            
        }
        
        // CROUCH →  CROUCH_WALK
        else if (_dir != 0) {
        	player_state = PlayerState.CROUCH_WALK;
        }
        
        break;
    
    case PlayerState.CROUCH_WALK:
        sprite_index = player_01.sprites.crouch_walk;
        mask_index = player_01.sprites.crouch_collision_mask;
        
        // Animate only while moving
        if (_dir == 0) {
        	image_speed = 0;
        } else {
        	image_speed = 1;
        }
        
        // CROUCH_WALK → AIR (e.g., walking off a ledge or actively in knockback)
        if (!on_ground) {
        	player_state = PlayerState.AIR;
        }
        
        // CROUCH_WALK → IDLE/RUN
        if (!_key_down) {
            
            var _height_diff = compare_mask_heights(player_01.sprites.idle_01, player_01.sprites.crouch);
            
            if (x_speed == 0 && !place_meeting(x, y - _height_diff, objWall)) {
            	player_state = PlayerState.IDLE;
                mask_index = player_01.sprites.default_collision_mask;
            } 
            
            else if (x_speed != 0 && !place_meeting(x, y - _height_diff, objWall)) {
            	player_state = PlayerState.RUN;
                mask_index = player_01.sprites.default_collision_mask;
            }
        }
        break;
    
    case PlayerState.AIR:
        // On entry logic. Only runs once
        if (player_state_previous != PlayerState.AIR) {
        	sprite_index = player_01.sprites.jump;
            image_speed = 1;
            image_index = 0;
            show_debug_message("On entry: " + string(image_index) );
        }
        
        // Rising
        if (y_speed < 0) {
            // Switch to Jump Sprite (Only if we aren't already wearing it)
            if (sprite_index != player_01.sprites.jump) {
                sprite_index = player_01.sprites.jump;
                image_index = 0;
                image_speed = 1;
                show_debug_message("Rising. Image index: " + string(image_index) );
                sprite_index = player_01.sprites.jump;
            }
            // Stop animation at the end
            if (image_index >= image_number - 1) {
            	image_speed = 0;
                image_index = image_number -1;
                show_debug_message("Done animating: " + string(image_index) );
            }
        } 
        
        // Falling
        else {
            // Switch to Fall Sprite (Only if we aren't already wearing it)
            if (sprite_index != player_01.sprites.fall) {
            	sprite_index = player_01.sprites.fall;
                image_speed = 1;
                image_index = 0;
            }
        }
        
        // Remove a jump if you got to air state by falling off a ledge and not by jumping
        if (coyote_jump_timer == 0 && !on_ground && jump_count == 0) {
            jump_count++;
        }
        
        // AIR → LEDGE GRAB
        if (!on_ground && _is_pressing_wall && _can_ledge_grab && y_speed >= 0 && ledge_regrab_lockout_timer <= 0) {
        	player_state = PlayerState.LEDGE_GRAB;
            ledge_grab_timer = ledge_grab_frames;
            jump_count = 0; // Reset jumps
            jump_speed_sustain_timer = 0;
            y = _id_wall.bbox_top + (y - bbox_top); // Snap the player's Y position to the ledge surface
        }
        
        // AIR → WALL_GRAB 
        else if (!on_ground && _is_pressing_wall && _can_wall_grab && y_speed >= 0 && ledge_regrab_lockout_timer <= 0) {
            player_state = PlayerState.WALL_GRAB;
            wall_grab_timer = 0; // Reset the timer for the new grab
            jump_count = 0; // reset jumps on wall grab
            jump_speed_sustain_timer = 0;
            audio_play_sound(sndPlayerStep01, 1, false);
            scr_spawn_dust_cloud(x, y, -on_wall, on_wall);
        }
        
        // AIR → IDLE/RUN - ground landing
        else if (on_ground) {
            // Check if the player was truly in an AIR state in the previous frame
            // to prevent playing the landing sound immediately after initiating a jump.
            if (player_state_previous == PlayerState.AIR) {
                audio_play_sound(sndPlayerJumpLanding, 10, false);
                scr_spawn_dust_cloud(x, y, facing_direction);
            }
            if (_dir != 0) {
                player_state = PlayerState.RUN;
            } else {
                player_state = PlayerState.IDLE;
            }
        }
        break;
    
    case PlayerState.LEDGE_GRAB:
        sprite_index = player_01.sprites.corner_grab;
        image_speed = 1;
        image_xscale = on_wall;
    
        // LEDGE GRAB → AIR
        if (ledge_grab_timer <= 0 || !_is_pressing_wall) {
            player_state = PlayerState.AIR;
            ledge_regrab_lockout_timer = ledge_regrab_lockout_frames; // Start ledge-grab lockout
        }
        break;
    
    case PlayerState.WALL_GRAB:
        sprite_index = player_01.sprites.wall_slide;
        image_speed = 0;
        image_xscale = -on_wall;
    
        // WALL GRAB → AIR
        if (!_is_pressing_wall) {
            player_state = PlayerState.AIR;
        } else {
            // Otherwise, continue the grab.
            wall_grab_timer++;
    
            // WALL GRAB → WALL SLIDE
            if (wall_grab_timer >= wall_grab_frames) {
                player_state = PlayerState.WALL_SLIDE;
                audio_play_sound(sndPlayerWallSlide, 10, false);
            }
        }
        break;
    
    case PlayerState.WALL_SLIDE:
        sprite_index = player_01.sprites.wall_slide;
        image_speed = 1;
        image_xscale = -on_wall;
        if (!audio_is_playing(sndPlayerWallSlide)) {
            audio_play_sound(sndPlayerWallSlide, 10, false);
        }
        
        // Dust cloud spawning
        wall_slide_dust_timer++;
        if (wall_slide_dust_timer >= wall_slide_dust_timer_max) {
            wall_slide_dust_timer = 0;
            scr_spawn_dust_cloud(x, y, -on_wall, on_wall);
        }
   
       // WALL SLIDE → IDLE/RUN (only after lock expires)
       if (on_ground && y_speed >= 0) {
           if (_dir != 0) {
               player_state = PlayerState.RUN;
           } else {
               player_state = PlayerState.IDLE;
           }
           audio_stop_sound(sndPlayerWallSlide);
       }
   
       // WALL SLIDE → AIR
       else if (!_is_pressing_wall || !_touching_grabbable_wall || !_bottom_corner_touching) {
           player_state = PlayerState.AIR;
           audio_stop_sound(sndPlayerWallSlide);
       }
    break;

    case PlayerState.ATTACK: 
        // --- On-Entry Logic (first frame of the ATTACK state) ---
        if (player_state_previous != PlayerState.ATTACK) {
            image_index = 0;
            image_speed = 1;
            
            // Set sprites
            if (!on_ground) {
                if (y_speed > 0) { sprite_index = player_01.sprites.air_attack_02; } 
                else if (y_speed < 0) { sprite_index = player_01.sprites.air_attack_01; }
            } else {
                sprite_index = player_01.sprites.attack_01;
            }
            
            audio_play_sound(sndPlayerAttack, 10, false); 
            
            // Create the attack slash object
            //var _total_x_offset = scr_get_offset(sPlayerAttack, sPlayerAttackSlash, -32);
            //var _slash_x = x + facing_direction * _total_x_offset;
            //current_attack_slash = instance_create_layer(_slash_x, y, "ilMiddle", oPlayerAttackSlash);
            
            //if (instance_exists(current_attack_slash)) {
            //    current_attack_slash.owner = id; // Set the owner to this player instance
            //    current_attack_slash.image_xscale = facing_direction; // Match player's direction
            //}
            //attack_timer = attack_frames; // Start attack timer
        }
     
        // When attack animation is over
        if (image_index >= image_number - 1) {
            // Transition back to an appropriate state based on whether the player is on the ground
            if (on_ground && x_speed != 0) { player_state = PlayerState.RUN; } 
            else if (on_ground && x_speed == 0) { player_state = PlayerState.IDLE; }
            else { player_state = PlayerState.AIR; }
        }
        break;
    
    case PlayerState.HURT:
        // Entry logic. Prevent running again once set.
        if (player_state_previous != PlayerState.HURT) {
        	sprite_index = player_01.sprites.hurt;
            image_index = 0;
            image_speed = 1;
            invulnerable_timer = invulnerable_frames;
        }
        
        // Transition out of HURT state if HURT animation is over.
        if (image_index == image_number - 1) {
            // HURT → AIR
            if (!on_ground) {
            	player_state = PlayerState.AIR;
            }
        	// HURT → RUN
            else if (on_ground && x_speed != 0) {
            	player_state = PlayerState.RUN;
            }
            // HURT → IDLE
            else if (on_ground && x_speed == 0) {
            	player_state = PlayerState.IDLE;
            } 
        }

        break;
    
    case PlayerState.DEAD:
        // On entry logic. Runs once 
        if (player_state_previous != PlayerState.DEAD) {
        	audio_play_sound(sndPlayerDeath, 10, false);
            image_index = 0;
            sprite_index = player_01.sprites.die;
            
            // Check lives
            if (oGameManager.player_lives > 0) {
                oGameManager.player_lives--;
                oGameManager.next_action = "respawn";
            } else {
                oGameManager.next_action = "game_over";
            }
            
            oGameManager.current_state = GAME_STATE.FADING_OUT;
        }
        
        // Play death animation until finished
        if (image_index == image_number - 1) {
            image_speed = 0;
        }
        break;
}
#endregion


// Check if you get crushed
if (place_meeting(x, y, objWall)) {
	image_blend = c_red;
} else {
    image_blend = c_white;
}


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
player_health_previous = player_health;
#endregion