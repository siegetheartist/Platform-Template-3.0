/// @description Handle collision with oPlayer

if (other.invulnerable_timer <= 0 && other.player_state != PlayerState.DEAD) {
    scr_apply_damage(other, self.hazard_damage, "player_health", sndPlayerTakesDamage);
    scr_status_effect_knockback(other, x, self.hazard_knockback_h_strength, self.hazard_knockback_v_strength);
}