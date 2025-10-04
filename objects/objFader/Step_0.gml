
// Progress fade
if (fade_mode == "fade-in") {
    fade_alpha -= fade_speed;
    if (fade_alpha <= 0) {
        fade_alpha = 0;
        is_complete = true;
    }
}
else if (fade_mode == "fade-out") {
    fade_alpha += fade_speed;
    if (fade_alpha >= fade_target) {
        fade_alpha = fade_target;
        is_complete = true;
    }
}