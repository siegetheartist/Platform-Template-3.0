/// @description Player attack slash object
 
// Owner of this attack (the player instance that created it)
owner = noone;
 
// Damage this attack deals
damage = 1; // Default damage for the slash
 
// Duration of the slash animation/collision (in frames)
duration = 9; // Adjust based on sPlayerAttackSlash animation length
timer = duration; // Countdown timer

// NEW: Knockback inflicted by this attack
knockback_h_strength = 3;  // Horizontal knockback pixel amount inflicted by this attack
knockback_v_strength = -2; // Vertical knockback pixel amount inflicted by this attack
 
 
// Keep track of enemies already hit to prevent multiple hits from one slash instance
hit_enemies = ds_list_create();