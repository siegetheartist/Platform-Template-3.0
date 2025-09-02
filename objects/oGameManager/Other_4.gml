// --- Music Control for Room Start ---

// Stop any music that might currently be playing.
audio_stop_all();

// Use a switch statement to play a specific sound based on the room name.
// This is a robust way to handle multiple music tracks for different levels.
switch (room) {
    case rLevel1:
        audio_play_sound(sndLevel1, 10, true);
        break;
    case rLevel2:
        // Assuming you have a sndLevel2 asset
        audio_play_sound(sndLevel2, 10, true);
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
