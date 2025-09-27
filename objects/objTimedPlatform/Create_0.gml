/// @description Initialize the timed platform

// -- State Machine --
// We define an enum for the platform's states to make the code readable.
enum PLATFORM_STATE {
    IDLE,       // Waiting for the player
    BREAKING,   // Player has stepped on it, timer is counting down
    BROKEN      // Platform has broken and is waiting to respawn
}

// Start in the IDLE state.
state = PLATFORM_STATE.IDLE;

// -- Timers --
// The countdown until the platform breaks (60 frames = 1 second at 60fps).
break_timer_max = 60;
break_timer = break_timer_max;

// The countdown until the platform respawns (180 frames = 3 seconds at 60fps).
respawn_timer_max = 180;
respawn_timer = respawn_timer_max;

// -- Sprite Setup --
// Stop the sprite from animating on its own.
image_speed = 0;
// Set the sprite to its default appearance (the first frame).
image_index = 0;

// Store the original collision mask so we can restore it when the platform respawns.
original_mask = mask_index;


#region AUDIO SOUND
// Define falloff properties
falloff_ref = 50;  // Sound is at full volume inside this pixel radius
falloff_max = 150; // Sound is silent beyond this pixel radius
falloff_factor = 1; // 1 = linear falloff

// Create an audio emitter for this specific trap
platform_emitter = audio_emitter_create();

// Set emmiter position
audio_emitter_position(platform_emitter, x, y, 0);

// Assign these properties to our new emitter
audio_emitter_falloff(platform_emitter, falloff_ref, falloff_max, falloff_factor);

// Select falloff model
audio_falloff_set_model(audio_falloff_exponent_distance_scaled);
#endregion


#region SHAKE OBJECT
// -- Shake Variables --
is_shaking = false; // Flag to indicate if the object is currently shaking
shake_timer = 0; // Current countdown for the shake duration
shake_duration_max = 0; // The initial duration, used for decaying magnitude
shake_magnitude = 0; // The maximum offset in pixels for the shake
shake_horizontal = true; // True for horizontal shake, false for vertical
// original_x and original_y are set by scr_shake_initialize when it's called.
// Initialize them to the object's starting position for good measure.
original_x = x;
original_y = y;
#endregion

