/// @description Draws the heads-up display on top of the game view.

//  HUD Drawing Logic 

#region FONT AND COLOR SETUP
// Set the font for drawing text (e.g., for crystal count)
draw_set_font(fnt_player_hud_txt); // Size of font
draw_set_halign(fa_left); // Align text to the left
draw_set_valign(fa_top); // Align text to the top
draw_set_color(c_white); // Set default text color to white
#endregion

// Be able to reference our manager
var _game_manager = oGameManager;

draw_sprite(spr_player_hud, 0, 0, 0);

#region DRAW PLAYER LIVES
//  Draw Player Lives 
// Always draw one 'sLives' sprite as the icon for the lives counter
var _life_x_start = 39; // Repositioned to 40px from the left
var _life_y = 39;       // Repositioned to 30px from the top
    
// draw_sprite(sLives, 0, _life_x_start, _life_y); // sLives icon is now commented out
// Draw the lives count text immediately next to the icon, vertically centered
draw_text(_life_x_start, _life_y, string(_game_manager.player_lives));
#endregion

#region DRAW PLAYER HEALTH
//  Draw Player Health 
// We need to get the current player's health from the oPlayer instance
var _current_player_health = 0;
if (instance_exists(oPlayer)) {
    _current_player_health = oPlayer.player_health;
}
    
// Determine which sprite to draw for each health slot (full or missing)
var _health_x_start = 47; // Repositioned to 47px from the left
var _health_y = 18;       // Repositioned to 19px from the top
var _health_spacing = sprite_get_width(spr_player_health) + 7; // Spacing is based on the main health sprite

for (var i = 0; i < _game_manager.max_player_health; i++) {
    var _sprite_to_draw = (i < _current_player_health) ? spr_player_health : spr_player_health_missing;
    draw_sprite(_sprite_to_draw, 0, _health_x_start + (i * _health_spacing), _health_y);
}
// No text counter for health, as it's visually represented by hearts.
#endregion

#region DRAW CRYSTALS COLLECTED
// --- Crystal Icon ---
//var _crystal_x = 1; // from the left
//var _crystal_y = 45; // from the top
//var _crystal_scale = 0.75; // Scale the sprite
draw_sprite_ext(sCrystal, 0, 0, 38, .75, .75, 0, c_white, 1);

// --- Crystal Text ---
var _crystal_text_x = 8; // 20 pixels from the left
var _crystal_text_y = 45; // 53 pixels from the top
draw_text(_crystal_text_x, _crystal_text_y, string(_game_manager.crystals_collected));


#endregion