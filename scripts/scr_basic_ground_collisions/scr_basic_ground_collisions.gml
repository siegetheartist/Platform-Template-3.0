// SUPER BASIC GROUND COLLISIONS WITH NO MOVING PLATFORMS OF ANY KIND
/// @description Handle vertical ground collisions.
/// @param _sub_pixel The sub pixel amount to switch to for precise collisions.
/// @param collision_tileset The tileset to check collisions against.
function ground_collisions(_sub_pixel, collision_tileset) { 
    // Ground collisions
    if (y_speed >= 0 && place_meeting(x, y + y_speed, collision_tileset)) {
        
        // TODO: Sliding down steep slopes needs review. Conflicts with horizontal movement if player keeps moving into wall
        // Slide down steep slope to the LEFT
        if (!place_meeting(x - abs(y_speed) - 1, y + y_speed, collision_tileset)) {
            while (place_meeting(x, y + y_speed, collision_tileset)) {
                x -= _sub_pixel;
            }
        }
        
        // Slide down steep slope to the RIGHT
        else if (!place_meeting(x + abs(y_speed) + 1, y + y_speed, collision_tileset)) {
            while (place_meeting(x, y + y_speed, collision_tileset)) {
                x += _sub_pixel;
            }
        }
        
        // Otherwise resolve as normal ground collision
        else {
            while (!place_meeting(x, y + _sub_pixel, collision_tileset)) {
                y += _sub_pixel;
            }
            y_speed = 0;
        }
    }
}