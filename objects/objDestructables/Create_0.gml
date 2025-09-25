/// @description Breakable Object Parent Initialization
health = 3; // Initial health of the breakable object
max_health = 3; // Maximum health, used for sprite frame calculation
 
snd_hit = noone; // Placeholder for a sound to play when hit (child can override)
snd_destroy = noone; // Placeholder for a sound to play when destroyed (child can override)
 
// Set initial sprite properties
sprite_index = noone; // Parent should not define a specific sprite; child will override
image_speed = 0; // Freeze animation initially
image_index = 0; // Start at the default (full health) framee