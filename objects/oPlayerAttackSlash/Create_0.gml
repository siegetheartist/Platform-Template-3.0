/// @description Player attack slash object
 

// Damage this attack deals
damage = 1; // Default damage for the slash
 
// Knockback inflicted by this attack
knockback_h_strength = 3;  // Horizontal knockback pixel amount inflicted by this attack
knockback_v_strength = -2; // Vertical knockback pixel amount inflicted by this attack

// Keep track of enemies already hit to prevent multiple hits from one slash instance
hit_enemies = ds_list_create();

// Owner of this attack (the player instance that created it)
owner = noone; // Updated in the scr_player_state_attack script to the oPlayer object