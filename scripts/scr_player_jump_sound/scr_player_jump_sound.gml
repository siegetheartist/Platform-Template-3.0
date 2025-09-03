function scr_player_jump_sound() {
    /// @description Plays the correct jump sound based on the player's consecutive jumps and manages the jump combo.

    // Increment the jump combo count.
    consecutive_jumps++;

    // Reset the jump combo timer.
    jump_combo_timer = jump_combo_timeout;

    // Determine which sound to play based on the jump combo count.
    var _jump_sound_to_play = sndPlayerJump; // Default to the first sound.
    switch (consecutive_jumps) {
        case 1:
            _jump_sound_to_play = sndPlayerJump;
            break;
        case 2:
            _jump_sound_to_play = sndPlayerJump02;
            break;
        case 3:
            _jump_sound_to_play = sndPlayerJump03;
            break;
        default:
            // After the third jump, loop back to the first sound.
            _jump_sound_to_play = sndPlayerJump;
            consecutive_jumps = 1;
            break;
    }

    // Play the selected jump sound.
    audio_play_sound(_jump_sound_to_play, 10, false);
}