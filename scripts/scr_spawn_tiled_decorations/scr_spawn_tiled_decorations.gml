/// @function            scr_spawn_tiled_decorations(spr_overlay, spr_underlay)
/// @description         Self-initializing script to spawn independently tiled decorations. Call from Step Event.
/// @param {Asset.Sprite}    spr_overlay     The sprite for the foreground layer (-1 for none).
/// @param {Asset.Sprite}    spr_underlay    The sprite for the background layer (-1 for none).

function scr_spawn_tiled_decorations(_spr_overlay, _spr_underlay) {
    
    // This flag ensures the code inside only ever runs ONCE per instance.
    if (!variable_instance_exists(id, "decorations_initialized")) {
        
        decorations_initialized = true;
        
        // --- Calculate the object's total visual area ---
        var _obj_total_width = bbox_right - bbox_left;
        
        
        // --- Handle Overlay Tiling ---
        if (_spr_overlay != -1) {
            var _tile_width = sprite_get_width(_spr_overlay);
            
            if (_tile_width > 0) {
                // Calculate how many tiles are needed to fill the object's width
                var _tile_count = ceil(_obj_total_width / _tile_width);
                
                // Calculate the total width of this specific tiled layer
                var _layer_total_width = _tile_count * _tile_width;
                
                // Find the starting position to center this layer relative to the object's center (x)
                var _start_x = x - (_layer_total_width / 2);
                
                // Loop and place each tile
                for (var i = 0; i < _tile_count; i++) {
                    // Calculate the center position for the current tile
                    var _current_x = _start_x + (_tile_width / 2) + (i * _tile_width);
                    layer_sprite_create("alMiddle", _current_x, y, _spr_overlay);
                }
            }
        }
        
        
        // --- Handle Underlay Tiling ---
        if (_spr_underlay != -1) {
            var _tile_width = sprite_get_width(_spr_underlay);
            
            if (_tile_width > 0) {
                // Same calculations, but for the underlay sprite
                var _tile_count = ceil(_obj_total_width / _tile_width);
                var _layer_total_width = _tile_count * _tile_width;
                var _start_x = x - (_layer_total_width / 2);
                
                for (var i = 0; i < _tile_count; i++) {
                    var _current_x = _start_x + (_tile_width / 2) + (i * _tile_width);
                    layer_sprite_create("alBackground", _current_x, y, _spr_underlay);
                }
            }
        }
    }
}