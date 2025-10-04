/// @function scr_fader(fade_mode, duration, amount, color)
/// @param fade_mode   "fade-in" or "fade-out"
/// @param duration    time in steps (e.g. 60 = 1 second at 60fps)
/// @param amount      target alpha (0–1), default 1
/// @param color       fade color, default c_black

function scr_fader(_fade_mode, _duration, _amount = 1, _color = c_black) {
    
    // Create the fader on a regular instance layer. "Instances" is the default layer name.
    // If you have a specific layer for UI objects, you can use that name instead.
    var inst = instance_create_layer(0, 0, "alForeground", objFader);

    inst.fade_mode   = _fade_mode;
    inst.fade_target = _amount;
    inst.fade_speed  = _amount / _duration;
    inst.fade_color  = _color;
    inst.is_complete = false;

    // Set starting alpha depending on mode
    if (_fade_mode == "fade-in") {
        inst.fade_alpha = _amount; // start fully opaque, fade to 0
    } else if (_fade_mode == "fade-out") {
        inst.fade_alpha = 0;       // start transparent, fade to target
    }

    return inst;
}




