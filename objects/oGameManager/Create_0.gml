// Create the fader object on the new "l_Faders" layer, as per naming convention.
// This will ensure it is drawn on top of all other objects.
instance_create_layer(0, 0, "l_Faders", oFader);

// Find the player object and disable its control. The oFader will re-enable it later.
with (oPlayer) {
    can_control = false;
}

// Ensure the fader's mode is always "fade_in" when the room starts.
// This fixes the issue of the player being locked out of movement in subsequent rooms.
with (oFader) {
    fader_mode = "fade_in";
}