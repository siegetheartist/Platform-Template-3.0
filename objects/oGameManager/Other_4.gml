#region SHARED ENVIRONMENT COLLISION LIST
// Tilemaps
global.collision_tsCollision = layer_tilemap_get_id("tsCollision");
global.collision_tlSlopes   = layer_tilemap_get_id("tlSlopes");

// Shared environment collidables
global.collision_environment = [
    global.collision_tsCollision,
    global.collision_tlSlopes,
    oInvisibleBlock,
    objDestructableWall,
    objTimedPlatform,
    objSlope, objSlope01, objSlope02, objSlope03, objSlope04, objSlope05
];
#endregion


// Set the default respawn position to the player's starting position in this room.
// This ensures we always have a valid respawn point if no checkpoint is activated.
if (instance_exists(oPlayer)) {
    global.checkpoint_x = oPlayer.x;
    global.checkpoint_y = oPlayer.y;
}

// Automatically initiate a fade-in when any room starts
current_state = GAME_STATE.FADING_IN;



#region MUSIC CONTROLER
// Stop any music that might currently be playing.
audio_stop_all();

// Use a switch statement to play a specific sound based on the room name.
// This is a robust way to handle multiple music tracks for different levels.
switch (room) {
    case rLevel1:
        audio_play_sound(sndLevel1, 10, true);
        break;
    case rStartScreen:
        // You can have a different music track for your menu screen
        audio_play_sound(sndStartScreen, 10, true);
        break;
    default:
        // Optional: Play a default track or no music if a room has no specific music.
        audio_play_sound(sndLevel1, 10, true);
        break;
}
#endregion

// --- SPAWN CAMERA IF NONE EXISTS ---
if (!instance_exists(oCamera)) {
    instance_create_layer(0, 0, "ilControllers", oCamera);
}
