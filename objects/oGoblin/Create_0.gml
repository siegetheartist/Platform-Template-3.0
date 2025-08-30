// --- Goblin Specific Initialization ---

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

// --- Initialize specific sprites and calculate offsets using the helper script ---
// Calls the function with the specific sprite assets for the Goblin, including the taunt sprite.
scr_enemy_init_sprites_and_offsets(sGoblinIdle, sGoblinPatrol, sGoblinChase, sGoblinTaunt); // NEW: Added sGoblinTaunt

// --- Override parent values for Goblin's behavior (optional) ---
patrol_hsp_max = 1.5; // Goblin patrols a bit faster than the default enemy
chase_hsp_max = 4;    // Goblin chases faster than the default enemy
alert_range = 180;    // Goblin has a slightly smaller alert range

// --- Set Goblin-specific damage (NEW) ---
enemy_damage = 1; // Goblin deals 1 damage to the player

// You can override any other variable defined in oEnemy's Create event here
// For example: health = 50; attack_damage = 10; etc.
