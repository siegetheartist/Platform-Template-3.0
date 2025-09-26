/// @description Handle collision with oEnemy
 
// 'other' refers to the oEnemy instance that collided with this slash
 
// Ensure the enemy is not already hit by this specific attack slash instance
if (ds_list_find_index(hit_enemies, other.id) == -1) {
    // Add the enemy to the hit list to prevent multiple hits from one slash
    ds_list_add(hit_enemies, other.id);
 
    if (variable_instance_exists(other, "enemy_health")) {
        scr_apply_damage(other, damage, "enemy_health", sndEnemyHit);
        scr_apply_flash(other);
                
        // NEW: Initiate hit animation if a specific hit sprite is assigned
        if (other.spr_hit_specific != -1) {
            // Store current animation state to revert to it later
            other.original_sprite_index = other.sprite_index;
            other.original_image_speed = other.image_speed;
            other.original_image_index = other.image_index;
            
            // Set the hit animation sprite and start it
            other.sprite_index = other.spr_hit_specific;
            other.image_index = 0; // Start hit animation from the beginning
            other.image_speed = 1; // Play hit animation at normal speed
            other.is_hit_animating = true; // Flag to indicate hit animation is active
            // Set enemy's image_xscale to match the player's attack direction
            if (instance_exists(owner)) {
                other.image_xscale = owner.facing_direction;
            }
        }
        
        // Apply knockback if cooldown allows
        if (instance_exists(owner)) { // Ensure the player (owner) still exists to get its position
            // Use THIS ATTACK'S (self) knockback strengths, not the enemy's (other) 'receiving' strengths.
            scr_status_effect_knockback(other, owner.x, self.knockback_h_strength, self.knockback_v_strength);
        }

        
        // Determine horizontal position based on player's attack direction
        // Place the impact slightly inwards from the enemy's edge for better visual
        var _player_inst_ref = owner; // Re-referencing owner for clarity
        if (instance_exists(_player_inst_ref)) {
            
            // Calculate offset and spawn location
            var _offset_from_enemy_center = (other.sprite_width / 2) - 0; // Change ending integer to adjust pixels inwards from enemy's edge
            var _impact_x_pos = other.x; // Horizontal Center of enemy - Previous calculation used to be: other.x + _player_inst_ref.facing_direction * _offset_from_enemy_center
            var _impact_y_pos = other.y - (other.sprite_height / 2); // Vertical middle of enemy
            
            // Spawn the impact visual effect
            var _impact_instance = instance_create_layer(_impact_x_pos, _impact_y_pos, "Assets", oAttackImpact);
            
            // Set image_xscale of the impact effect to match player's attack direction
            if (instance_exists(_impact_instance)) {
                _impact_instance.image_xscale = _player_inst_ref.facing_direction;
            }
        } else {
            // Fallback if player instance somehow doesn't exist
            instance_create_layer(other.x, other.y, "Assets", oAttackImpact);
        }
 
        // If enemy health drops to 0 or below, destroy it
        if (other.enemy_health <= 0) {
            // Play death sound if defined for this enemy type (NEW)
            if (variable_instance_exists(other, "snd_death") && other.snd_death != noone) {
                audio_play_sound(other.snd_death, 1, false);
            }
            instance_destroy(other);
        }
    }
}