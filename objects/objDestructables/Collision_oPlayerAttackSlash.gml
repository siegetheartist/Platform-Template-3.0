/// @description Handle collision with oPlayerAttackSlash
 
// 'other' refers to the oPlayerAttackSlash instance that collided with this breakable object.
 
// Ensure this breakable is not already hit by this specific attack slash instance
if (ds_list_find_index(other.hit_enemies, id) == -1) {
    // Add this object to the hit list to prevent multiple hits from one slash
    ds_list_add(other.hit_enemies, id);
 
    // Reduce health by the slash's damage
    current_health -= other.damage;
    
    // Play hit sound if assigned
    if (snd_hit != noone) {
        audio_play_sound(snd_hit, 1, false);
    }
    
    if (spr_wall_hit_effect != noone) {
    	instance_create_layer(x, y, "Assets", spr_wall_hit_effect);
    } 
    
    // Update sprite frame based on remaining health
    // Frame 0: Full health (e.g., 3 health remaining)
    // Frame 1: 1 damage taken (e.g., 2 health remaining)
    // Frame 2: 2 damage taken (e.g., 1 health remaining)
    image_index = max(0, max_health - current_health); 
    
    // If health drops to 0 or below, destroy the object
    if (current_health <= 0) {
        // Play a destruction sound if assigned
        if (snd_destroy != noone) {
            audio_play_sound(snd_destroy, 1, false);
        }
        instance_destroy();
    }
}