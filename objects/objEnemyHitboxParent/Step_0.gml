/// @description Follow owner and self-destruct if owner is gone
if (instance_exists(weapon_owner)) {
    // Follow the owner’s position
    x = weapon_owner.x + weapon_owner.current_dir * total_x_offset;
    y = weapon_owner.y + total_y_offset;
    image_xscale = weapon_owner.current_dir;
    
    // If owner is no longer in ATTACK state, destroy hitbox
    if (weapon_owner.enemy_state != ENEMY_STATE.ATTACK) {
        instance_destroy();
    }
} else {
    // If owner doesn't exist, destroy hitbox
    instance_destroy();
}