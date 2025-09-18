//  Orc Specific Initialization 

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

//  Initialize specific sprites and calculate offsets using the helper script 
// Calls the function with the specific sprite assets for the Orc, including the taunt sprite.
scr_enemy_init_sprites_and_offsets(sOrcIdle, sOrcPatrol, sOrcChase, sOrcTaunt);


#region PARENT OVERRIDES for Goblin's behavior
// Define movement speeds for different states
patrol_hsp_max = .5; // Default slower speed for patrolling
chase_hsp_max = 2.5;  // Default faster speed for chasing

// Acceleration and deceleration values for smoother movement
hsp_accel = 0.08; // How quickly the enemy speeds up horizontally
// hsp_decel = 0.4; // How quickly the enemy slows down horizontally

// Detection ranges 
sight_distance = 175; // Distance for front-facing, line-of-sight detection (triggers CHASE)
behind_alert_distance = 125; // Distance for player detection from behind (triggers ALERT)
behind_chase_distance = 105; // Closer distance for player detection from behind (triggers CHASE)
default_close_chase_distance = 80; // General close proximity detection (triggers CHASE regardless of direction/LOS)
deaggro_distance_from_chase = 240; // Distance at which the enemy will stop chasing/alerting and return to patrol

// Amount of knockback
knockback_h_strength = 3;  // Horizontal knockback pixel amount (Increased for more effect)
knockback_v_strength = -2; // Vertical knockback pixel amount (Increased for more effect)

// Enemy Stas
enemy_health = 2; // Health
enemy_damage = 1; // Damage
#endregion
