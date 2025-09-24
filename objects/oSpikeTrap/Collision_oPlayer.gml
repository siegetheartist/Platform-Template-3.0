/// @description Handle collision with oPlayer
 
// 'other' refers to the oPlayer instance that collided with this hazard.
 
// Only apply damage and knockback if the player is not currently invulnerable.
if (other.invulnerable_timer <= 0) {
    // Play damage sound if player's health will not drop below zero after taking damage.
    // The oGameManager handles player death sound if health reaches zero.
    if (other.player_health - self.hazard_damage > 0) {
        audio_play_sound(sndPlayerTakesDamage, 10, false);
    }
    other.player_health -= self.hazard_damage;
    
    // Set player invulnerability and flash timers
    other.invulnerable_timer = other.invulnerable_duration;
    other.flash_timer = other.flash_duration;
    
    // Apply knockback to the player using the hazard's defined knockback strengths
    // The attacker's x is this hazard's x. For vertical-only knockback, the direction will be automatically handled based on current player position but horizontal component is zero.
    scr_status_effect_knockback(other, x, self.hazard_knockback_h_strength, self.hazard_knockback_v_strength);
    
    // If player health drops to 0 or below, the oGameManager will handle death in its Step event.
}