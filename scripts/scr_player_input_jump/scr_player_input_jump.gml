/// @description If jump conditions are met, resets jump buffer and coyote time , and returns true (a jump can be executed). True value used in the jump execution call.
/// @arg {real} _key_jump Is the jump key pressed this frame?
/// @arg {bool} on_ground Is the player on the ground?
function scr_player_input_jump(_key_jump, on_ground) {
    // --- Jump request ---
	if ((_key_jump && (on_ground || coyote_jump_timer > 0 || jump_count < jump_max)) || (on_ground && jump_input_buffer_timer > 0)) {
        return true; // intent only
    }
    return false;
}