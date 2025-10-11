/// @description Hit the player

// Apply damage and effects to the player
scr_apply_damage(other, 1, "player_health", sndEnemyHit);
scr_obj_flash_initialize(other);
scr_apply_invulnerability(other);
scr_status_effect_knockback(other, x, 2, 2);

// Call the destruction script
scr_stalagmite_destroy();