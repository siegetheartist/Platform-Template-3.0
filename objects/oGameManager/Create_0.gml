// This object handles global game state, transitions, and logic that affects the entire game.
#region DEFAULT PLAYER RESPAWN POSITION
// This must be declared in the Create Event of a persistent object.
if (!variable_global_exists("checkpoint_x")) {
    global.checkpoint_x = 0;
}
if (!variable_global_exists("checkpoint_y")) {
    global.checkpoint_y = 0;
}
#endregion


#region STATE MACHINE
enum GAME_STATE {
    IDLE,        // Game is running normally
    FADING_OUT,  // Fading screen to black
    FADE_COMPLETE,// Screen is black, perform action
    FADING_IN,   // Fading screen back to clear
    GAME_OVER   // Game has ended
}

current_state = GAME_STATE.IDLE; // Start in the normal running state.
next_action = ""; // The action to perform once the screen is fully black.
respawn_grace_period = 0; // A timer to briefly prevent death checks after respawn.
#endregion



#region PLAYER STATS AND LIVES
player_lives = 1; // Player's current number of lives, starts at 1
crystals_collected = 0; // Number of crystals collected by the player
max_crystals_for_life = 3; // Number of crystals needed to gain an extra life
max_player_health = 4; // Maximum player health (for display and resetting health on respawn)
#endregion


// Set Game over UI invisible by default
layer_set_visible("Layer_Game_over", false);

// Play the background music on a loop when the room starts.
// The priority (10) determines which sounds are played if the game reaches its channel limit.
audio_play_sound(sndLevel1, 10, true);

// Set orientation of listener to be correctly upright. (default is 0,0,1,  0,1,0)
// audio_listener_orientation(0, 0, 1, 0, -1, 0);

// Each game session generates a different sequence of random numbers.
randomize();