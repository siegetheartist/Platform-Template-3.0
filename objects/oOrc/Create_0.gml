/// @description Orc Specific Initialization 

// Inherit all variables and settings from the parent oEnemy
event_inherited(); 

#region PARENT OVERRIDES for Goblin's behavior
// Define movement speeds for different states
patrol_hsp_max = .5; // Default slower speed for patrolling
chase_hsp_max = 1.75;  // Default faster speed for chasing

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

#region ORC ATTACK VARIABLES
// SWING
spr_orc_attack_swing_01 = sprOrcAttackSwing01;
orc_attack_swing_range = 48;
attack_range = orc_attack_swing_range; 
orc_attack_swing_cooldown = 90; 
attack_cooldown_duration = orc_attack_swing_cooldown;

// Track spawned hitbox
hitbox = noone;
#endregion


#region ORC ATTACK BEHAVIORS
function orc_attack_swing() {
    // 1. If not already in swing animation, start it
    if (sprite_index != spr_orc_attack_swing_01) {
        sprite_index = spr_orc_attack_swing_01;
        image_index = 0;
        image_speed = 1; // adjust for timing
        hsp = 0; // stop movement
        return;
    }

    // 2. When we reach the 4th frame, spawn hitbox and play sound
    if (sprite_index == spr_orc_attack_swing_01 && image_index >= .6 && hitbox == noone) {
        var _hitbox = instance_create_layer(x, y, "ilTop", objOrcAttackSwing01Hitbox);
        _hitbox.weapon_owner = id; // assign THIS orc as owner
        hitbox = _hitbox;

        audio_play_sound(sndOrcTaunt, 10, false);
    }

    // 3. When animation finishes, end attack and clean up hitbox
    if (sprite_index == spr_orc_attack_swing_01 && image_index >= image_number - 1) {
        attack_finished = true;

        if (instance_exists(hitbox)) {
            with (hitbox) instance_destroy();
        }
        hitbox = noone;
    }
}
#endregion


// -- ATTACK SELECTION LOGIC --
// This is the "selector" function. It decides WHICH attack to use.
enemy_attack_behavior = function() {
    
    // Initialize Attacks
    // if attack is available (cooldown is 0), initialize it, in order of priority
    
    // If an attack has been initialized, run it's code, as many times as needed, frame by frame, until it is finished.
    orc_attack_swing();
}