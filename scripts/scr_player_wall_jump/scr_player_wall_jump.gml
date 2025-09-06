/// @desc Executes a wall jump.
/// @arg {real} wall_direction The direction of the wall (-1 for left, 1 for right).
function scr_player_wall_jump(_wall_dir) {
    // Execute the centralized jump function with the "wall" type.
    scr_player_jump("wall", _wall_dir);
}