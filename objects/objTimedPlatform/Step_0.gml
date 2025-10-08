
// Handle collapsing platform logic.
scr_obj_collapse(20, 180, sndRockCrackandBreak);

// If the platform is in its "BREAKING" state (state 2), call the shake script.
if (state == 2) { 
    // scr_obj_shake(delay, duration, magnitude, is_horizontal);
    scr_obj_shake(self, 0, 40, 3, "horizontal"); 
}