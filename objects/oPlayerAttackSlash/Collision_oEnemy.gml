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
        
        // Activate flashing effect on hit enemy
        other.flash_timer = other.flash_duration;
        
        // NEW: Apply knockback if cooldown allows
        if (other.knockback_cooldown_timer <= 0) {
            // Player instance (owner of the attack)
            var _player_inst = owner;
            if (instance_exists(_player_inst)) {
                // Determine horizontal knockback direction (in the direction of the player's attack/facing)
                other.hsp = _player_inst.facing_direction * other.knockback_h_strength;
                other.vsp = other.knockback_v_strength; // Apply vertical knockback (negative for up)
                other.knockback_active = true;
                other.knockback_cooldown_timer = other.knockback_cooldown_duration; // Start cooldown
            }
        }
 
        // Play a sound when an enemy is hit (assuming sndEnemyHit exists)
        audio_play_sound(sndEnemyHit, 1, false);
 
        // If enemy health drops to 0 or below, destroy it
        if (other.enemy_health <= 0) {
            instance_destroy(other);
        }
    }
}