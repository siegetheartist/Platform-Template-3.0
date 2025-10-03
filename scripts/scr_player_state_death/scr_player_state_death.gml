/// @function scr_player_state_death(player)
/// @param player  The player instance to process

function scr_player_state_death(_player) {
    // The player has now died.
        
    // Stop playing movement - you're dead
    _player.hsp = 0;
    _player.vsp = 0;
    audio_play_sound(sndPlayerDeath, 10, false);
    
    // Check lives
    if (oGameManager.player_lives > 0) {
        oGameManager.player_lives--;
        oGameManager.next_action = "respawn";
    } else {
        oGameManager.next_action = "game_over";
    }
    
    oGameManager.current_state = GAME_STATE.FADING_OUT;
    instance_destroy(_player);
}
