/// @description Handle collision with oEnemy
 
// 'other' refers to the oEnemy instance that collided with this slash
 
// Ensure the enemy is not already hit by this specific attack slash instance
if (ds_list_find_index(hit_enemies, other.id) == -1) {
    // Add the enemy to the hit list to prevent multiple hits from one slash
    ds_list_add(hit_enemies, other.id);
 
    if (variable_instance_exists(other, "enemy_health")) {
        scr_apply_damage(other, damage, "enemy_health", sndEnemyHit);
        
        if (other.enemy_health > 0) {
            // If it is, apply all the non-fatal hit effects.
            scr_obj_flash_initialize(other);
    
            // Apply knockback if cooldown allows
            if (instance_exists(owner)) { // Ensure the player (owner) still exists to get its position
                // Use THIS ATTACK'S (self) knockback strengths, not the enemy's (other) 'receiving' strengths.
                scr_status_effect_knockback(other, owner.x, self.knockback_h_strength, self.knockback_v_strength);
            }
        }

        
        // Determine horizontal position based on player's attack direction
        // Place the impact slightly inwards from the enemy's edge for better visual
        var _player_inst_ref = owner; // Re-referencing owner for clarity

        if (instance_exists(_player_inst_ref)) {
            // Calculate offset and spawn location
            var _offset_from_enemy_center = (other.sprite_width / 2);
            var _impact_x_pos = other.x;
            var _impact_y_pos = other.y - (other.sprite_height / 2);
        
            // Check enemy health BEFORE spawning effect
            if (other.enemy_health > 0) {
                // Spawn the regular hit impact
                var _impact_instance = instance_create_layer(_impact_x_pos, _impact_y_pos, "alForeground", oAttackImpact);
        
                if (instance_exists(_impact_instance)) {
                    _impact_instance.image_xscale = _player_inst_ref.facing_direction;
                }
            }
        }
    }
}