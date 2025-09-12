#region INITIAL FADE IN
// Set the default respawn position to the player's starting position in this room.
// This ensures we always have a valid respawn point if no checkpoint is activated.
if (instance_exists(oPlayer)) {
    global.checkpoint_x = oPlayer.x;
    global.checkpoint_y = oPlayer.y;
}

// Start the initial fade-in.
initiate_fader_in();

// Find the player object and disable its control.
// The fader will re-enable it when the fade-in is complete.
with (oPlayer) {
    can_control = false;
}
#endregion


#region MUSIC CONTROLER
// Stop any music that might currently be playing.
audio_stop_all();

// Use a switch statement to play a specific sound based on the room name.
// This is a robust way to handle multiple music tracks for different levels.
switch (room) {
    case rLevel1:
        audio_play_sound(sndLevel1, 10, true);
        break;
    case rStartMenu:
        // You can have a different music track for your menu screen
        audio_play_sound(sndMenuMusic, 10, true);
        break;
    default:
        // Optional: Play a default track or no music if a room has no specific music.
        audio_play_sound(sndLevel1, 10, true);
        break;
}
#endregion