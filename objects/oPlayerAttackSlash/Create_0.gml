/// @description Player attack slash object
 
// Owner of this attack (the player instance that created it)
owner = noone;
 
// Damage this attack deals
damage = 1; // Default damage for the slash
 
// Duration of the slash animation/collision (in frames)
duration = 9; // Adjust based on sPlayerAttackSlash animation length
timer = duration; // Countdown timer
 
// Set sprite and animation speed
sprite_index = sPlayerAttackSlash;
image_speed = 1;
image_index = 0; // Start from first frame
 
// Keep track of enemies already hit to prevent multiple hits from one slash instance
hit_enemies = ds_list_create();