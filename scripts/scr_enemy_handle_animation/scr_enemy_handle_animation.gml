/// @function scr_enemy_handle_animation()
/// @description Handles the sprite assignment, flipping, and animation speed for an enemy instance.
///              Assumes 'enemy_state', 'hsp', 'current_dir', 'spr_idle_specific', 'spr_patrol_move', and 'spr_chase_move' are defined on the calling instance.

function scr_enemy_handle_animation() {
    #region ANIMATION & SPRITE ORIENTATION
    // Set the sprite based on the enemy's current state.
    switch (self.enemy_state) { // Using self. to be explicit about instance variables
        case ENEMY_STATE.PATROL:
        case ENEMY_STATE.ALERT:
            if (self.hsp != 0) {
                self.sprite_index = self.spr_patrol_move; // Use specific patrolling/running sprite when moving
            } else {
                self.sprite_index = self.spr_idle_specific; // Explicitly set to the stored idle sprite when stationary
            }
            break;

        case ENEMY_STATE.CHASE:
            self.sprite_index = self.spr_chase_move; // Use specific chase/attack sprite
            break;
        
        case ENEMY_STATE.TAUNT: // NEW: Display taunt animation
            self.sprite_index = self.spr_taunt_specific; // Use the specific taunt sprite
            break;
    }

    // Flip the sprite horizontally based on the current direction.
    if (self.current_dir == 1) {
        self.image_xscale = 1; // Face right
    } else {
        self.image_xscale = -1; // Face left (flipped)
    }

    // Control animation speed based on horizontal movement.
    // If taunting, animation should usually play, but movement speed is 0.
    if (self.hsp != 0 || self.enemy_state == ENEMY_STATE.TAUNT) { // Play animation if moving OR taunting
        self.image_speed = 1; // Play animation
    } else {
        self.image_speed = 0; // Stop animation when not moving
        self.image_index = 0; // Reset to first frame
    }
    #endregion
}
