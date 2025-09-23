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
// The action to perform once the screen is fully black.
next_action = "";

#endregion


#region PLAYER STATS AND LIVES
player_lives = 1; // Player's current number of lives, starts at 1
crystals_collected = 0; // Number of crystals collected by the player
max_crystals_for_life = 3; // Number of crystals needed to gain an extra life
max_player_health = 4; // Maximum player health (for display and resetting health on respawn)
#endregion

//  Respawn Invulnerability Timer 
respawn_grace_period = 0; // A timer to briefly prevent death checks after respawn.

//  Game Over Screen Variables 
// Track which button is currently selected (0 for Try Again, 1 for Back to Menu).
selected_button = 0;


#region GAME UI
// Set Game over UI invisible by default
layer_set_visible("Layer_Game_over", false);
#endregion


#region PARALLAX BACKGROUND VARIABLES
// Parallax scroll speeds. These are multipliers of the camera's horizontal speed.
// 0.2 means the layer moves at 20% the speed of the camera.
bg_1_scroll_speed = 0.08; // Furthest layer (least movement)
bg_2_scroll_speed = 0.06; // Middle layer
bg_3_scroll_speed = 0.02; // Closest layer (most movement)
#endregion


#region BACKGROUND MUSIC
// Play the background music on a loop when the room starts.
// The priority (10) determines which sounds are played if the game reaches its channel limit.
audio_play_sound(sndLevel1, 10, true);
#endregion


#region HELPER SCRIPTS
// These are functions to be used within this object's events.
function initiate_fader_in() {
    // Create a fader object set to fade in.
    if (!instance_exists(oFader)) {
        var _fader_instance = instance_create_layer(0, 0, "l_Faders", oFader);
        _fader_instance.fader_mode = "fade_in";
        _fader_instance.alpha = 1; // Start fully black for a fade-in
    }
    current_state = GAME_STATE.FADING_IN;
}

function initiate_fader_out() {
    // Create a fader object set to fade out.
    if (!instance_exists(oFader)) {
        var _fader_instance = instance_create_layer(0, 0, "l_Faders", oFader);
        _fader_instance.fader_mode = "fade_out";
        _fader_instance.alpha = 0; // Start transparent for a fade-out
    }
    current_state = GAME_STATE.FADING_OUT;
}

// Public-facing function for other objects to call on death.
function initiateRespawn() {
    next_action = "respawn";
    initiate_fader_out();
}

// Public-facing function for other objects to call on level completion.
function initiateNextLevel() {
    next_action = "next_level";
    initiate_fader_out();
}
#endregion

// Each game session generates a different sequence of random numbers.
randomize();