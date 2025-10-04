// Let the game manager handle transitions to different rooms
with (oGameManager) {
    if (current_state == GAME_STATE.IDLE) { // Prevent triggering fade multiple times
        next_action = "next_level";
        current_state = GAME_STATE.FADING_OUT;
    }
}