//  Goblin Specific Initialization 

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

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

// Amount of knockback resistance (when this enemy *receives* knockback)
knockback_h_resistance = 1.0;  // Goblin takes full knockback
knockback_v_resistance = 1.0; // Goblin takes full knockback

// Enemy Stas
max_enemy_health = 2; // Health
enemy_health = max_enemy_health; // Initialize current health to its max
enemy_damage = 1; // Damage

// NEW: Attack properties (children will override) - Default to 0 for no attack
attack_range = 96;          // Goblin attacks if player is within 48px
attack_h_speed = 3;         // Horizontal speed of the leap
attack_v_speed = -6;       // Vertical speed of the leap (negative for upward)
attack_duration = 20;       // How long the attack state lasts (frames)
attack_cooldown_duration = 60; // 1 second cooldown after attack

// NEW: Knockback inflicted by Goblin's attack
knockback_h_strength = 3;  // Horizontal knockback inflicted by goblin's attack
knockback_v_strength = -0; // Vertical knockback inflicted by goblin's attack
#endregion

#region SPRITES + EFFECTS
spr_idle = sGoblinIdle;
spr_alerted = sprGoblinAlerted;
spr_patrol = sGoblinPatrol;
spr_chase = sGoblinChase;
spr_taunt = sGoblinTaunt;
spr_attack = sGoblinAttack01;
spr_hurt = sGoblinHurt;
spr_death = sGoblinDeath;
exclamation_sprite = spr_exclamation;
obj_death_effect = oGoblinDeathEffect;
#endregion

#region GOBLIN SPECIFIC SOUNDS
snd_alert = sndGoblinAlert;
snd_chase = sndGoblinChase;
snd_taunt = sndGoblinTaunt;
snd_hit = sndGoblinHit;
snd_death = sndGoblinDeath;
snd_attack = sndGoblinAttack01; // NEW
#endregion

