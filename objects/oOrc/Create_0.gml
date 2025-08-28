// --- Orc Specific Initialization ---

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

// --- Initialize specific sprites and calculate offsets using the helper script ---
// Calls the function with the specific sprite assets for the Orc.
scr_enemy_init_sprites_and_offsets(sOrcIdle, sOrcPatrol, sOrcChase);

// --- Override parent values for Orc's behavior (optional) ---
patrol_hsp_max = 0.8; // Orc might be slower at patrolling than the default/goblin
chase_hsp_max = 3.5;  // Orc chases faster, but maybe not as quick as goblin
alert_range = 250;    // Orc has a larger alert range (can spot player from further away)
deaggro_range = 300;  // Orc holds aggro longer
// You can override any other variable defined in oEnemy's Create event here
// For example: health = 100; attack_damage = 25; etc.