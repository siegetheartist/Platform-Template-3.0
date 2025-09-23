/// @description Breakable Wall Specific Initialization
// Inherit all variables and settings from the parent objBreakables
event_inherited();
 
// Overrides specific to objBreakableWall
health = 3; // Example: Set health to 3
max_health = 3; // Max health should match initial health
 
// Assign the specific sprite for this breakable wall
sprite_index = sprBreakableWall; // Use the correct sprite name: sprBreakableWall
 
// Assign specific sounds for this breakable wall
snd_hit = sndBreakableWallHit; // You'll need to create this sound asset, e.g., a 'thwack' or 'crack'
snd_destroy = sndBreak; // Assuming 'sndBreak' is the destruction sound for breakable walls