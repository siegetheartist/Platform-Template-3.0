//  Goblin Specific Initialization 

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

//  Initialize specific sprites and calculate offsets using the helper script 
// Calls the function with the specific sprite assets for the Goblin, including the taunt sprite.
scr_enemy_init_sprites_and_offsets(sGoblinIdle, sGoblinPatrol, sGoblinChase, sGoblinTaunt, sGoblinAttack01);
 
// NEW: Assign the specific hit sprite for the Goblin
self.spr_hit_specific = sGoblinHit; // Assuming you have a sprite 'sGoblinHit'

#region PARENT OVERRIDES for Goblin's behavior
// Define movement speeds for different states
patrol_hsp_max = 1; // Default slower speed for patrolling
chase_hsp_max = 2.75;  // Default faster speed for chasing

// Acceleration and deceleration values for smoother movement
hsp_accel = 0.1; // How quickly the enemy speeds up horizontally
// hsp_decel = 0.4; // How quickly the enemy slows down horizontally

// Detection ranges 
sight_distance = 175; // Distance for front-facing, line-of-sight detection (triggers CHASE)
behind_alert_distance = 125; // Distance for player detection from behind (triggers ALERT)
behind_chase_distance = 105; // Closer distance for player detection from behind (triggers CHASE)
default_close_chase_distance = 80; // General close proximity detection (triggers CHASE regardless of direction/LOS)
deaggro_distance_from_chase = 240; // Distance at which the enemy will stop chasing/alerting and return to patrol

// Amount of knockback
knockback_h_strength = 4.5;  // Horizontal knockback pixel amount (Increased for more effect)
knockback_v_strength = -3.0; // Vertical knockback pixel amount (Increased for more effect)

// Enemy Stas
max_enemy_health = 2; // Health
enemy_health = max_enemy_health; // Initialize current health to its max
enemy_damage = 1; // Damage

// NEW: Attack specific overrides for Goblin's leap attack
attack_range = 48;          // Goblin attacks if player is within 48px
attack_h_speed = 3;         // Horizontal speed of the leap
attack_v_speed = -4;       // Vertical speed of the leap (negative for upward)
attack_duration = 20;       // How long the attack state lasts (frames)
attack_cooldown_duration = 60; // 1 second cooldown after attack
#endregion

#region GOBLIN SPECIFIC SOUNDS
snd_alert = sndGoblinAlert;
snd_chase = sndGoblinChase;
snd_taunt = sndGoblinTaunt;
snd_hit = sndGoblinHit;
snd_death = sndGoblinDeath;
snd_attack = sndGoblinAttack01; // NEW
#endregion

