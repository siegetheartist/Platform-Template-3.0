/// @description Handle collision with oEnemy
 
// 'other' refers to the oEnemy instance that collided with this slash
 
// Ensure the enemy is not already hit by this specific attack slash instance
if (ds_list_find_index(hit_enemies, other.id) == -1) {
    // Add the enemy to the hit list to prevent multiple hits from one slash
    ds_list_add(hit_enemies, other.id);
 
    // Apply damage to the enemy
    // Assuming oEnemy has an 'enemy_health' variable (added in oEnemy/Create_0.gml)
    if (variable_instance_exists(other, "enemy_health")) {
        other.enemy_health -= damage;
        
        // Play damage sound if defined for this enemy type (NEW)
        if (variable_instance_exists(other, "snd_hit") && other.snd_hit != noone) {
            audio_play_sound(other.snd_hit, 1, false);
        }
        audio_play_sound(sndEnemyHit, 1, false);
        
        // Activate flashing effect on hit enemy
        other.flash_timer = other.flash_duration;
        
        // Apply knockback if cooldown allows
        if (other.knockback_cooldown_timer <= 0) {
            // Player instance (owner of the attack)
            var _player_inst = owner;
            if (instance_exists(_player_inst)) {
                // Determine horizontal knockback direction (in the direction of the player's attack/facing)
                other.hsp = _player_inst.facing_direction * other.knockback_h_strength;
                other.vsp = other.knockback_v_strength; // Apply vertical knockback (negative for up)
                other.knockback_active = true;
                other.knockback_duration_timer = other.knockback_duration; // Start knockback duration timer
                other.knockback_cooldown_timer = other.knockback_cooldown_duration; // Start cooldown
            }
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