/// @description Applies damage to a target instance and plays a sound.
/// @param target_instance The instance to apply damage to.
/// @param damage_amount The amount of damage to apply.
/// @param health_variable_name A string for the health variable name (e.g., "player_health", "enemy_health").
/// @param damage_sound The sound to play when damage is taken.

function scr_apply_damage(target_instance, damage_amount, health_variable_name, damage_sound) {
    // Exit if the target instance doesn't exist
    if (!instance_exists(target_instance)) {
        exit;
    }

    // Only apply damage if the target is not currently invulnerable.
    if (variable_instance_exists(target_instance, "invulnerable_timer")) {
        if (target_instance.invulnerable_timer > 0) {
            exit;
        }
    }

    // Check if the health variable exists before trying to modify it
    if (variable_instance_exists(target_instance, health_variable_name)) {
        var _current_health = variable_instance_get(target_instance, health_variable_name);

        // The critical check!
        // If the target is the player, only play the sound if they will survive.
        // For any other object (like an enemy), always play the sound.
        if (target_instance.object_index != oPlayer || (_current_health - damage_amount > 0)) {
             audio_play_sound(damage_sound, 10, false);
        }

        // Then, apply the damage and update the health variable to it's new value
        variable_instance_set(target_instance, health_variable_name, _current_health - damage_amount);
    }
}