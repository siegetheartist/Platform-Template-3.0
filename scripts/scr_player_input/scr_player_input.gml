/// @description Manages all player input and returns a struct containing their states.
/// @return {struct} A struct containing all input states.
function scr_player_input() {
    #region INPUT VARIABLES
    // Create a struct to return all input states.
    var _input_data = {};

    // Read input only if the player can control their character.
    if (can_control && player_state != PlayerState.DEAD) {
        _input_data.key_left = keyboard_check(ord("A"));
        _input_data.key_right = keyboard_check(ord("D"));
        _input_data.key_jump = keyboard_check_pressed(vk_space);
        _input_data.key_jump_held = keyboard_check(vk_space);
    } else {
        _input_data.key_left = 0;
        _input_data.key_right = 0;
        _input_data.key_jump = 0;
        _input_data.key_jump_held = 0;
    }
    _input_data.dir = _input_data.key_right - _input_data.key_left;

    return _input_data;
    #endregion
}