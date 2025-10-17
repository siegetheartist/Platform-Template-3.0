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
behind_alert_distance = 100; // Distance for player detection from behind (triggers ALERT)
behind_chase_distance = 70; // Closer distance for player detection from behind (triggers CHASE)
default_close_chase_distance = 70; // General close proximity detection (triggers CHASE regardless of direction/LOS)
deaggro_distance_from_chase = 180; // Distance at which the enemy will stop chasing/alerting and return to patrol

// Amount of knockback resistance (when this enemy *receives* knockback)
knockback_h_resistance = 0.75;  // Orc takes 25% reduced knockback
knockback_v_resistance = 0.75; // Orc takes 25% reduced knockback

// Enemy Stats
max_enemy_health = 6; // Health
enemy_health = max_enemy_health; // Initialize current health to its max
enemy_damage = 1; // Damage

// Attack properties - Default to 0 for no attack
attack_range = 0;
attack_cooldown_duration = 0;

// Knockback inflicted by Orc's attack (currently 0 as no attack defined)
knockback_h_strength = 4;  // Horizontal knockback inflicted by orc's attack
knockback_v_strength = 0; // Vertical knockback inflicted by orc's attack
#endregion

#region SPRITES + EFFECTS
spr_idle = sOrcIdle;
spr_alerted = sprOrcAlerted;
spr_inspect = sprOrcInspect;
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

#region GOBLIN ATTACK VARIABLES
// LEAP
spr_swipe_attack_01 = sprOrcAttackSwing01;
leap_attack_range = 96;
attack_range = leap_attack_range; // Currently only 1 attack, but in future other attacks will have to override this
leap_h_speed = 3;         // Horizontal speed of the leap
leap_v_speed = -6;       // Vertical speed of the leap (negative for upward)
leap_cooldown = 90; 
attack_cooldown_duration = leap_cooldown;
#endregion

// ORC ATTACK BEHAVIORS
function swing_attack() {
    if (sprite_index != sprOrcAttackSwing01) {
        sprite_index = sprOrcAttackSwing01;
        image_index = 0;
        image_speed = 1;
        hsp = 0; // Orc plants feet
    }

    // Example: spawn hitbox at frame 3
    if (image_index == 3 && !hitbox_spawned) {
        instance_create_layer(x + current_dir * 8, y, "Instances", objOrcAttackSwing01Hitbox);
        hitbox_spawned = true;
    }
}

function choose_orc_attack() {
    // Orc might only have one attack for now
    enemy_attack_behavior = swing_attack;
}
