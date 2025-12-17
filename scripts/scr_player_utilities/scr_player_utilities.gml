/// @desc Set new state, save previous state.
/// @param {real} _new_state Use ENUM state. (e.i: Player.State.STATE)
function set_transition_state(_new_state) {
    if (player_state != _new_state) {
        player_state_previous = player_state;
        player_state = _new_state;
    }
}

/// @desc Set animation sprite, index, and speed
/// @param {asset} _sprite_index Sprite asset.
/// @param {real} _image_index Frame to start on.
/// @param {real} _image_speed Speed of animation.
function set_animation(_sprite_index, _image_index = 0, _image_speed = 1) {
    sprite_index = _sprite_index;
    image_index = _image_index; 
    image_speed = _image_speed;
}


/// @desc Set on-entry animation sprite, index, and speed. Compares player_state_previous and player_state to ONLY RUNS ONCE.
/// @param {asset} _sprite_index Sprite asset.
/// @param {real} _image_index Frame to start on.
/// @param {real} _image_speed Speed of animation.
function set_on_entry_animation(_sprite_index, _image_index = 0, _image_speed = 1) {
    // Reset animation to ensure it starts fresh
    if (player_state_previous != player_state) {
        set_animation(_sprite_index, _image_index, _image_speed);
        player_state_previous = player_state;
        show_debug_message("Entered " + string(player_state));
    }
}

