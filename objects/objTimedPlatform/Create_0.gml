#region AUDIO SOUND
// Define falloff properties
falloff_ref = 50;  // Sound is at full volume inside this pixel radius
falloff_max = 150; // Sound is silent beyond this pixel radius
falloff_factor = 1; // 1 = linear falloff

// Create an audio emitter for this specific trap
platform_emitter = audio_emitter_create();

// Configure emitter
audio_emitter_position(platform_emitter, x, y, 0); // Set emmiter position
audio_emitter_falloff(platform_emitter, falloff_ref, falloff_max, falloff_factor); // Assign these properties to our new emitter
audio_falloff_set_model(audio_falloff_exponent_distance_scaled); // Select falloff model
#endregion

