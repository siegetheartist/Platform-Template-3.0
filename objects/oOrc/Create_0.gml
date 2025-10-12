//  Orc Specific Initialization 

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

#region PARENT OVERRIDES for Goblin's behavior
// Define movement speeds for different states
patrol_hsp_max = .5; // Default slower speed for patrolling
chase_hsp_max = 2.00;  // Default faster speed for chasing

// Acceleration and deceleration values for smoother movement
hsp_accel = 0.07; // How quickly the enemy speeds up horizontally
// hsp_decel = 0.4; // How quickly the enemy slows down horizontally

// Detection ranges 
sight_distance = 175; // Distance for front-facing, line-of-sight detection (triggers CHASE)
behind_alert_distance = 125; // Distance for player detection from behind (triggers ALERT)
behind_chase_distance = 105; // Closer distance for player detection from behind (triggers CHASE)
default_close_chase_distance = 80; // General close proximity detection (triggers CHASE regardless of direction/LOS)
deaggro_distance_from_chase = 240; // Distance at which the enemy will stop chasing/alerting and return to patrol

// Amount of knockback resistance (when this enemy *receives* knockback)
knockback_h_resistance = 0.75;  // Orc takes 25% reduced knockback
knockback_v_resistance = 0.75; // Orc takes 25% reduced knockback

// Enemy Stas
max_enemy_health = 4; // Health
enemy_health = max_enemy_health; // Initialize current health to its max
enemy_damage = 1; // Damage

// Attack properties (children will override) - Default to 0 for no attack
attack_range = 0;          // Orc doesn't have a specific attack range yet
attack_h_speed = 0;        
attack_v_speed = 0;        
attack_duration = 0;      
attack_cooldown_duration = 0; 

// Knockback inflicted by Orc's attack (currently 0 as no attack defined)
knockback_h_strength = 6;  // Horizontal knockback inflicted by orc's attack
knockback_v_strength = 0; // Vertical knockback inflicted by orc's attack
#endregion

#region SPRITES + EFFECTS
spr_idle = sOrcIdle;
spr_alerted = sprOrcAlerted;
spr_patrol = sOrcPatrol;
spr_chase = sOrcChase;
spr_taunt = sOrcTaunt;
spr_attack = noone;
spr_hurt = sOrcHurt;
spr_death = sOrcDeath;
exclamation_sprite = spr_exclamation;
obj_death_effect = oOrcDeathEffect;
#endregion

#region ORC SPECIFIC SOUNDS
snd_alert = sndOrcAlert;
snd_chase = sndOrcChase;
snd_taunt = sndOrcTaunt;
snd_hurt = sndOrcHurt;
snd_death = sndOrcDeath;
snd_attack = noone;
#endregion