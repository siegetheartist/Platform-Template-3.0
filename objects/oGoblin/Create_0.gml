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
sight_distance = 150; // Distance for front-facing, line-of-sight detection (triggers CHASE)
behind_alert_distance = 120; // Distance for player detection from behind (triggers ALERT)
behind_chase_distance = 80; // Closer distance for player detection from behind (triggers CHASE)
default_close_chase_distance = 80; // General close proximity detection (triggers CHASE regardless of direction/LOS)
deaggro_distance_from_chase = 160; // Distance at which the enemy will stop chasing/alerting and return to patrol

// Amount of knockback resistance (when this enemy *receives* knockback)
knockback_h_resistance = 1.0;  // Goblin takes full knockback
knockback_v_resistance = 1.0; // Goblin takes full knockback

// Enemy Stas
max_enemy_health = 2; // Health
enemy_health = max_enemy_health; // Initialize current health to its max
enemy_damage = 1; // Damage

// Knockback inflicted by Goblin's attack
knockback_h_strength = 3;  // Horizontal knockback inflicted by goblin's attack
knockback_v_strength = -0; // Vertical knockback inflicted by goblin's attack
#endregion

#region SPRITES + EFFECTS
spr_idle = sGoblinIdle;
spr_alerted = sprGoblinAlerted;
spr_inspect = sprGoblinInspect;
spr_patrol = sGoblinPatrol;
spr_chase = sGoblinChase;
spr_taunt = sGoblinTaunt;
spr_attack = sprGoblinAttackLeap1; // <-- consider turning into a struct as there may be multiple per attack behavior
spr_hurt = sGoblinHurt;
spr_death = -1;
exclamation_sprite = spr_exclamation;
obj_death_effect = oGoblinDeathEffect;
#endregion

#region GOBLIN SPECIFIC SOUNDS
snd_alert = sndGoblinAlert;
snd_chase = sndGoblinChase;
snd_taunt = sndGoblinTaunt;
snd_hurt = sndGoblinHurt;
snd_death = sndGoblinDeath;
snd_attack = sndGoblinAttack01;
#endregion

#region GOBLIN ATTACK VARIABLES
// LEAP
spr_leap_attack_1 = sprGoblinAttackLeap1;
spr_leap_attack_2 = sprGoblinAttackLeap2;
goblin_leap_attack_range = 96;
attack_range = goblin_leap_attack_range; // Currently only 1 attack, but in future other attacks will have to override this
goblin_leap_h_speed = 3;         // Horizontal speed of the leap
goblin_leap_v_speed = -6;       // Vertical speed of the leap (negative for upward)
goblin_leap_cooldown = 60; 
#endregion


#region GOBLIN ATTACK BEHAVIORS (Functions)
function goblin_leap_attack() {
    // 1. If not in the "ready" pose, switch to it.
    if (sprite_index != spr_leap_attack_1) {
        sprite_index = spr_leap_attack_1;
        image_index = 0;
        image_speed = 1;
        return;
    }

    // 2. Once the "ready" animation is finished, perform the leap.
    if (sprite_index == spr_leap_attack_1 && image_index >= image_number - 1) {
        sprite_index = spr_leap_attack_2;
        image_index = 0;
        image_speed = 1;
        
        // Apply the leap speed
        hsp = current_dir * goblin_leap_h_speed;
        vsp = goblin_leap_v_speed;
        
        // Play a sound for feedback
        audio_play_sound(sndGoblinAttack01, 10, false);
    }

    // 3. After leaping, check if we have landed on the ground.
    if (sprite_index == spr_leap_attack_2 && _on_ground) {
        // The attack is now officially over.
        attack_finished = true;
    }
}
#endregion


// -- ATTACK SELECTION LOGIC --
// This is the "selector" function. It decides WHICH attack to use and WHEN.
enemy_attack_behavior = function() {
    if (attack_cooldown_timer <= 0) {

        // Reset the cooldown for this specific attack
        attack_cooldown_timer = goblin_leap_cooldown;

        // Execute the leap attack function now!
        goblin_leap_attack();
    }
    // If on cooldown, the goblin will just wait (doing nothing)
    // because the parent oEnemy has set hsp_max to 0.
}