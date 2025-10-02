/// @description Spawns underlay and overlay sprites at a given position on predefined layers.
/// @param spr_overlay The sprite to place on the foreground layer (use -1 for none)
/// @param spr_underlay The sprite to place on the background layer (use -1 for none)
/// @param x_pos [optional] The x-coordinate for both sprites (defaults to calling instance's x)
/// @param y_pos [optional] The y-coordinate for both sprites (defaults to calling instance's y)

function scr_spawn_layer_decoration(_spr_overlay, _spr_underlay, _x_pos = x, _y_pos = y) {
    
    if (_spr_overlay != -1) {
        layer_sprite_create("alForeground", _x_pos, _y_pos, _spr_overlay);
    }
    
    if (_spr_underlay != -1) {
        layer_sprite_create("alBackground", _x_pos, _y_pos, _spr_underlay);
    }

}

