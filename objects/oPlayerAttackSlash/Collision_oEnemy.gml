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
        
        // Play a sound when an enemy is hit (assuming sndEnemyHit exists)
        audio_play_sound(sndEnemyHit, 1, false);
 
        // If enemy health drops to 0 or below, destroy it
        if (other.enemy_health <= 0) {
            instance_destroy(other);
        }
    }
}