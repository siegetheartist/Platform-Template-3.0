/// @description Go to the previous room after a fade

with (oGameManager) {
    // Only trigger a room transition if the game is in a normal state
    if (current_state == GAME_STATE.IDLE) {
        // Set the next action to go to the previous level
        next_action = "previous_level";
        
        // Start the fade-out process
        current_state = GAME_STATE.FADING_OUT;
    }
}