//  Orc Specific Initialization 

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

//  Initialize specific sprites and calculate offsets using the helper script 
// Calls the function with the specific sprite assets for the Orc, including the taunt sprite.
scr_enemy_init_sprites_and_offsets(sOrcIdle, sOrcPatrol, sOrcChase, sOrcTaunt);

//  Override parent values for Orc's behavior (optional) 
// Example overrides - adjust these values as you design your Orc's unique stats
patrol_hsp_max = 0.8; // Orc might be slower at patrolling than the default/goblin
chase_hsp_max = 3.5;  // Orc chases faster, but maybe not as quick as goblin



// Define detection ranges for player interaction (children can override these)
//alert_range = 200; // Distance at which the enemy will enter ALERT state
//chase_range = 150; // Distance at which the enemy will enter CHASE state (must be < alert_range)
//deaggro_range = 250; // Distance at which the enemy will stop chasing/alerting and return to patrol




enemy_health = 4; // Default health for this enemy type. Children can override.

//  Set Orc-specific damage (NEW) 
enemy_damage = 2; // Orc deals 2 damage to the player

// You can override any other variable defined in oEnemy's Create event here
// For example: health = 100; attack_damage = 25; etc.
