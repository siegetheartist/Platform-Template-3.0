// --- Goblin Specific Movement and Animation ---

// Inherit the parent event (ONLY CALL ONCE PER EVENT TYPE)
event_inherited(); 

// The parent's Step event (oEnemy's Step event) has now executed, handling
// core AI, movement, and collisions. Now, add Goblin-specific logic.

#region ANIMATION & SPRITE ORIENTATION (Goblin Specific)
// Set the sprite based on the enemy's current state.
switch (enemy_state) {
    case ENEMY_STATE.PATROL:
    case ENEMY_STATE.ALERT:
        if (hsp != 0) {
            sprite_index = spr_patrol_move; // Use goblin's running sprite when moving
        } else {
            sprite_index = sGoblinIdle; // Use goblin's idle sprite when stopped
        }
        break;

    case ENEMY_STATE.CHASE:
        sprite_index = spr_chase_move; // Use goblin's chase/attack sprite
        break;
}

// Flip the sprite horizontally based on the current direction.
if (current_dir == 1) {
    image_xscale = 1; // Face right
} else {
    image_xscale = -1; // Face left (flipped)
}

// Control animation speed based on horizontal movement.
if (hsp != 0) {
    image_speed = 1; // Play animation when moving
} else {
    image_speed = 0; // Stop animation when not moving
    image_index = 0; // Reset to first frame
}
#endregion

// You can add any other Goblin-specific logic here, e.g., attack behavior
