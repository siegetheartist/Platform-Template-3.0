/// @function scr_move_and_collide(collision_map)
/// @param collision_map    An array or object to check for collisions against.
/// @description Moves the instance and handles collision with solids.

function scr_move_and_collide(_collision_map) { // Use an argument

    // --- Move horizontally until collision ---
    if (place_meeting(x + hsp, y, _collision_map)) { // Check against the argument
        var _sub_pixel = .5;
        var _pixel_step = _sub_pixel * sign(hsp);
        while (!place_meeting(x + _pixel_step, y, _collision_map)) {
            x += _pixel_step;
        }
        hsp = 0;
    }

    // --- Commit to horizontal movement ---
    x += hsp;


    // --- Move vertically until collision ---
    if (place_meeting(x, y + vsp, _collision_map)) { // Check against the argument
        var _sub_pixel = .5;
        var _pixel_step = _sub_pixel * sign(vsp);
        while (!place_meeting(x, y + _pixel_step, _collision_map)) {
            y += _pixel_step;
        }
        vsp = 0;
    }

    // --- Commit Vertical Movement ---
    y += vsp;

}