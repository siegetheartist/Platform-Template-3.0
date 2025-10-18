/// @description Apply damage and destroy self
if (other.invulnerable_timer <= 0 && other.player_state != PlayerState.DEAD) {
    scr_apply_damage(other, weapon_owner.enemy_damage, "player_health", sndPlayerTakesDamage);
    scr_apply_invulnerability(other);
    scr_obj_flash_initialize(other);
    scr_status_effect_knockback(other, x, weapon_owner.knockback_h_strength, weapon_owner.knockback_v_strength);
    scr_camera_shake(view_camera[0], 5, 1);
}

// Destroy this hitbox after hitting the player
instance_destroy();
