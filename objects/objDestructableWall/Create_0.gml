/// @description Breakable Wall Specific Initialization
// Inherit all variables and settings from the parent objBreakables
event_inherited();
 
// Overrides specific to objDestructableWall
current_health = sprite_get_number(sprite_index);
max_health = sprite_get_number(sprite_index); // Max health should match initial_health
 
// Assign specific sounds for this breakable wall
snd_hit = sndWallHit; // You'll need to create this sound asset, e.g., a 'thwack' or 'crack'
snd_destroy = sndWallDestroyed; // Assuming 'sndBreak' is the destruction sound for breakable walls

// Assign wall hit partical effect
spr_wall_hit_effect = objWallParticles;