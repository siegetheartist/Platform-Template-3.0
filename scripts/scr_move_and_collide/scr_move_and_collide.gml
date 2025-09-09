/// @function scr_move_and_collide(hsp, vsp, collision_obj)
/// @desc Moves the instance with collision resolution, fractional handling, and corner fix.
/// @param {real} hsp - Horizontal speed
/// @param {real} vsp - Vertical speed
/// @param {asset} collision_obj - Object or tilemap to collide with
/*

function scr_move_and_collide(_hsp, _vsp, _col) {

    // --- FRACTIONAL ACCUMULATORS ---
    if (!variable_instance_exists(id, "_frac_x")) _frac_x = 0;
    if (!variable_instance_exists(id, "_frac_y")) _frac_y = 0;

    _frac_x += _hsp;
    _frac_y += _vsp;

    var move_x = round(_frac_x);
    var move_y = round(_frac_y);

    _frac_x -= move_x;
    _frac_y -= move_y;

    // --- MOVE HORIZONTALLY ---
    if (move_x != 0) {
        var step_x = sign(move_x);
        repeat (abs(move_x)) {
            if (!place_meeting(x + step_x, y, _col)) {
                x += step_x;
            } else {
                break; // stop on collision
            }
        }
    }

    // --- MOVE VERTICALLY ---
    if (move_y != 0) {
        var step_y = sign(move_y);
        repeat (abs(move_y)) {
            if (!place_meeting(x, y + step_y, _col)) {
                y += step_y;
            } else {
                break; // stop on collision
            }
        }
    }

    // --- POST-MOVE CORNER FIX ---
    if (place_meeting(x, y, _col)) {
        var overlap_x = 0;
        var overlap_y = 0;

        // Measure horizontal push-out
        while (!place_meeting(x + overlap_x, y, _col) && abs(overlap_x) < 4) {
            overlap_x += (sign(_hsp) != 0) ? -sign(_hsp) : -1;
        }

        // Measure vertical push-out
        while (!place_meeting(x, y + overlap_y, _col) && abs(overlap_y) < 4) {
            overlap_y += (sign(_vsp) != 0) ? -sign(_vsp) : -1;
        }

        // Apply smallest correction
        if (abs(overlap_x) < abs(overlap_y)) {
            x += overlap_x;
        } else {
            y += overlap_y;
        }
    }
}
*/