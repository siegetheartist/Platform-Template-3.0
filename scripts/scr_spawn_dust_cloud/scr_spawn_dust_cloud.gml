/// @description Spawns a dust cloud with random variations.
/// @arg {real} _x The x-coordinate to spawn the dust cloud at.
/// @arg {real} _y The y-coordinate to spawn the dust cloud at.
/// @arg {real} _direction The direction the dust cloud should face.
/// @arg {real} [on_wall=0] The direction of the wall (-1 for left, 1 for right, 0 for none).

function scr_spawn_dust_cloud(_x, _y, _direction, on_wall = 0) {
    // Create a dust cloud instance on the "alForeground" layer.
    var _dust_cloud = instance_create_layer(_x, _y, "alForeground", oDustCloud);

    // Flip the dust cloud based on the player's direction.
    _dust_cloud.image_xscale = _direction;

    // Set the animation to play.
    _dust_cloud.image_speed = 1;

    // Special logic for wall dust clouds
    if (on_wall != 0) {
        // Offset the dust cloud to the corner of the player sprite
        _dust_cloud.x += 0; // was: (12 * on_wall)
        _dust_cloud.y += 6;

        // Rotate the dust cloud
        _dust_cloud.image_angle = 90 * -on_wall;
    } else { 
        // Apply randomness to the spawn position when on ground
        _dust_cloud.x += random_range(-4, 4);
        _dust_cloud.y += random_range(2, 1);
    }
}