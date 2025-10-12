/// @description Handle animation end for hit animation
 
// If the hit animation has just finished and we were actively playing it
if (is_hit_animating && sprite_index == spr_hurt) {
    is_hit_animating = false; // Turn off the flag
    
    // Revert to the sprite and animation settings that were active before the hit
    sprite_index = original_sprite_index;
    image_speed = original_image_speed;
    image_index = original_image_index; // Restore the frame it was on
}
 
// Any other animation end logic for oEnemy can go here.
// For example, if there were other animations that needed specific resets.