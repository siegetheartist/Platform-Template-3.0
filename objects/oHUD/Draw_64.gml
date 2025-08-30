// --- HUD Drawing Logic ---

#region FONT AND COLOR SETUP
// Set the font for drawing text (e.g., for crystal count)
draw_set_font(fnt_hud_default); // Assuming you have a font asset named 'fnt_hud_default'
draw_set_halign(fa_left); // Align text to the left
draw_set_valign(fa_top); // Align text to the top
draw_set_color(c_white); // Set default text color to white
#endregion

// Check if the player controller instance exists before trying to draw its data
if (instance_exists(oPlayerController)) {
    // Get a reference to the player controller instance for easier access
    var _player_controller = oPlayerController;

    // --- Layout Variables ---
    var _padding = 15; // Padding from the viewport edges
    var _row_gap = 15; // Gap between each row of HUD elements

    #region DRAW PLAYER LIVES
    // --- Draw Player Lives ---
    // Always draw one 'sLives' sprite as the icon for the lives counter
    var _life_x_start = _padding; // Starting X position for lives display, with padding
    var _life_y = _padding;       // Y position for lives display, with padding
    
    draw_sprite(sLives, 0, _life_x_start, _life_y); // Draw the lives icon once
    // Draw the lives count text immediately next to the icon, vertically centered
    draw_text(_life_x_start + sprite_get_width(sLives), _life_y + (sprite_get_height(sLives) / 2) - (string_height(string(_player_controller.player_lives)) / 2), string(_player_controller.player_lives));
    #endregion

    #region DRAW PLAYER HEALTH
    // --- Draw Player Health ---
    // We need to get the current player's health from the oPlayer instance
    var _current_player_health = 0;
    if (instance_exists(oPlayer)) {
        _current_player_health = oPlayer.player_health;
    }
    
    // Draw 'sHealth' sprites for max health, showing full or empty frames
    var _health_x_start = _padding; // Starting X position for health display, with padding
    var _health_y = _life_y + sprite_get_height(sLives) + _row_gap; // Y position below lives, with row gap
    var _health_spacing = sprite_get_width(sHealth) + 4; // Spacing between health sprites

    for (var i = 0; i < _player_controller.max_player_health; i++) {
        var _frame = (i < _current_player_health) ? 0 : 1; // Frame 0 for full, Frame 1 for empty
        draw_sprite(sHealth, _frame, _health_x_start + (i * _health_spacing), _health_y);
    }
    // No text counter for health, as it's visually represented by hearts.
    #endregion

    #region DRAW CRYSTALS COLLECTED
    // --- Draw Crystals Collected ---
    // Draw the 'sCrystal' sprite and the count next to it
    var _crystal_x = _padding; // X position for crystal sprite, with padding
    var _crystal_y = _health_y + sprite_get_height(sHealth) + _row_gap; // Y position below health, with row gap

    draw_sprite(sCrystal, 0, _crystal_x, _crystal_y);
    // Draw the crystal count text immediately next to the sprite, vertically centered
    draw_text(_crystal_x + sprite_get_width(sCrystal), _crystal_y + (sprite_get_height(sCrystal) / 2) - (string_height(string(_player_controller.crystals_collected)) / 2), string(_player_controller.crystals_collected));
    #endregion
}
