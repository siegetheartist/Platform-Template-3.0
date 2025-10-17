/// @description Handle collision with oPlayer

if (other.invulnerable_timer <= 0 && enemy_state != ENEMY_STATE.DEATH) {
    scr_apply_damage(other, self.enemy_damage, "player_health", sndPlayerTakesDamage);
    scr_apply_invulnerability(other);
    scr_obj_flash_initialize(other);
    scr_status_effect_knockback(other, x, self.knockback_h_strength, self.knockback_v_strength);
}

// add horizontal knockback to the enemy, when the enemy collides with the player and are alive
// remove horizontal impulse when you land on the ground to prevent further movement