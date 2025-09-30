/// @description Breakable Object Parent Initialization
current_health = 3; // Initial health of the breakable object
max_health = 3; // Maximum health, used for sprite frame calculation
 
snd_hit = noone; // Placeholder for a sound to play when hit (child can override)
snd_destroy = noone; // Placeholder for a sound to play when destroyed (child can override)

spr_wall_hit_effect = noone; // partical effect when you hit a wall
 
// Set initial sprite properties
image_speed = 0; // Freeze animation initially
image_index = 0; // Start at the default (full health) frame