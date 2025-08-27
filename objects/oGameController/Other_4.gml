// This event runs every time a new room is entered.

// This is where we handle the fade effect for every room transition.
// Check if a player instance exists. If so, apply the fade-in logic.
if (instance_exists(oPlayer)) {
    // Find the player object and disable its control. The oFader will re-enable it.
    with (oPlayer) {
        can_control = false;
    }

    // Create a fader object to handle the fade-in effect.
    var _fader = instance_create_layer(0, 0, "l_Faders", oFader);
    _fader.fader_mode = "fade_in";
}