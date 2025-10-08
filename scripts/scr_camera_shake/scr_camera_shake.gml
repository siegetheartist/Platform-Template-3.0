/// @function scr_camera_shake(_cam, _duration, _magnitude)
/// @description Shakes a camera for a given duration and magnitude.
/// @param {Camera} _cam        The camera handle (e.g. view_camera[0])
/// @param {Real}   _duration   Duration in steps
/// @param {Real}   _magnitude  Maximum pixel offset

// !WARNING: This script only works if it is updated every Step.
// You must call it continuously from a controller (e.g. oCamera Step event).
// Example: scr_camera_shake(view_camera[0], 0, 0);
// One place (the Step event) runs the update loop,
// another place (like a wall’s Destroy event) triggers the shake.

function scr_camera_shake(_cam, _duration, _magnitude)
{
    // Static variables persist across calls
    static shake_active     = false;
    static shake_timer      = 0;
    static shake_magnitude  = 0;
    static shake_cam        = noone;
    static shake_origin_x   = 0;
    static shake_origin_y   = 0;

    // --- Trigger a new shake ---
    if (_duration > 0 && _magnitude > 0) {
        shake_active    = true;
        shake_timer     = _duration;
        shake_magnitude = _magnitude;
        shake_cam       = _cam;

        // Store the original camera position
        shake_origin_x  = camera_get_view_x(_cam);
        shake_origin_y  = camera_get_view_y(_cam);
    }

    // --- Update if active ---
    if (shake_active) {
        if (shake_timer > 0) {
            shake_timer--;

            var ox = random_range(-shake_magnitude, shake_magnitude);
            var oy = random_range(-shake_magnitude, shake_magnitude);

            camera_set_view_pos(shake_cam, shake_origin_x + ox, shake_origin_y + oy);
        }
        else {
            // Reset to original position
            camera_set_view_pos(shake_cam, shake_origin_x, shake_origin_y);
            shake_active = false;
        }
    }
}
