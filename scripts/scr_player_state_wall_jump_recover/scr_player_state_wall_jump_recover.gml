/// @description Handles the player's input lockout after a wall jump.

function scr_player_state_wall_jump_recover() {
	// Decrement the wall jump delay timer.
	wall_jump_move_loss--;

	// Once the timer is finished, return to the AIR state to regain control.
	if (wall_jump_move_loss <= 0) {
		player_state = PlayerState.AIR;
	}
}