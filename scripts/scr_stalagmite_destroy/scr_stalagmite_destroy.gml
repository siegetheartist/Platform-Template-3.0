/// @function scr_stalagmite_destroy()
/// @description Handles the destruction of a stalagmite (particles, sound, etc.)

function scr_stalagmite_destroy() {
    // Play the destruction sound
    audio_play_sound(snd_destroy, 1, false);

    // Create particles with the defined offset and angle
    var _particles = instance_create_layer(x, y + 10, "ilTop", objWallParticles);
    _particles.image_angle = 90;

    // Destroy the stalagmite instance
    instance_destroy();
}