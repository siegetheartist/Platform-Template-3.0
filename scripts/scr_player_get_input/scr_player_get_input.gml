/// @function scr_player_get_input();
/// @description Gathers all raw keyboard and gamepad inputs and returns them in a struct.
/// @return {struct} A struct containing the state of all defined inputs.

function scr_player_get_input() {
    
    // --- Define the structure for all possible inputs ---
    var _input_data = {
        // Held down (for movement)
        left_held: 0,
        right_held: 0,
        jump_held: 0,
        
        // Pressed once (for actions/menus)
        left_pressed: 0,
        right_pressed: 0,
        jump_pressed: 0,
        attack_pressed: 0,
        back_pressed: 0,
        confirm_pressed: 0, // NEW: Dedicated input for menu confirmation
        
        // Final direction axis
        dir: 0
    };

    // --- Keyboard Input ---
    var _key_left_kb = keyboard_check(ord("A")) || keyboard_check(vk_left);
    var _key_right_kb = keyboard_check(ord("D")) || keyboard_check(vk_right);
    var _key_jump_kb_held = keyboard_check(vk_space);
    
    var _key_left_kb_pressed = keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left);
    var _key_right_kb_pressed = keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right);
    var _key_jump_kb_pressed = keyboard_check_pressed(vk_space);
    var _key_attack_kb_pressed = keyboard_check_pressed(ord("J"));
    var _key_back_kb_pressed = keyboard_check_pressed(vk_escape);
    var _key_confirm_kb_pressed = keyboard_check_pressed(ord("J")) || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_enter);

    // --- Gamepad Input ---
    var _gp_left_held = 0, _gp_right_held = 0, _gp_jump_held = 0;
    var _gp_left_pressed = 0, _gp_right_pressed = 0, _gp_jump_pressed = 0, _gp_attack_pressed = 0, _gp_back_pressed = 0, _gp_confirm_pressed = 0; // NEW

    // Loop through all connected gamepads.
    var _gp_count = gamepad_get_device_count();
    for (var i = 0; i < _gp_count; i++) {
        if (gamepad_is_connected(i)) {
            var _h_axis = gamepad_axis_value(i, gp_axislh);
            var _deadzone = 0.2;
            
            // Held Inputs
            _gp_left_held += gamepad_button_check(i, gp_padl) || (_h_axis < -_deadzone);
            _gp_right_held += gamepad_button_check(i, gp_padr) || (_h_axis > _deadzone);
            _gp_jump_held += gamepad_button_check(i, gp_face1);
            
            // Pressed Inputs
            _gp_left_pressed += gamepad_button_check_pressed(i, gp_padl);
            _gp_right_pressed += gamepad_button_check_pressed(i, gp_padr);
            _gp_jump_pressed += gamepad_button_check_pressed(i, gp_face1);
            _gp_attack_pressed += gamepad_button_check_pressed(i, gp_face3);
            _gp_back_pressed += gamepad_button_check_pressed(i, gp_face4);
            _gp_confirm_pressed += gamepad_button_check_pressed(i, gp_face1);
        }
    }

    // --- Combine and Finalize Inputs ---
    _input_data.left_held = clamp(_key_left_kb + _gp_left_held, 0, 1);
    _input_data.right_held = clamp(_key_right_kb + _gp_right_held, 0, 1);
    _input_data.jump_held = clamp(_key_jump_kb_held + _gp_jump_held, 0, 1);
    
    _input_data.left_pressed = clamp(_key_left_kb_pressed + _gp_left_pressed, 0, 1);
    _input_data.right_pressed = clamp(_key_right_kb_pressed + _gp_right_pressed, 0, 1);
    _input_data.jump_pressed = clamp(_key_jump_kb_pressed + _gp_jump_pressed, 0, 1);
    _input_data.attack_pressed = clamp(_key_attack_kb_pressed + _gp_attack_pressed, 0, 1);
    _input_data.back_pressed = clamp(_key_back_kb_pressed + _gp_back_pressed, 0, 1);
    _input_data.confirm_pressed = clamp(_key_confirm_kb_pressed + _gp_confirm_pressed, 0, 1);
    
    _input_data.dir = _input_data.right_held - _input_data.left_held;

    return _input_data;
}