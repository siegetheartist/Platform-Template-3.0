/// @function            scr_spawn_tiled_decorations(spr_overlay, spr_underlay)
/// @description         Self-initializing script to spawn tiled decorations across an object's width. Call from Step Event.
/// @param {Asset.Sprite}    spr_overlay     The sprite for the foreground layer (-1 for none).
/// @param {Asset.Sprite}    spr_underlay    The sprite for the background layer (-1 for none).

function scr_spawn_tiled_decorations(_spr_overlay, _spr_underlay) {
    
    // This flag ensures the code inside only ever runs ONCE per instance.
    if (!variable_instance_exists(id, "decorations_initialized")) {
        
        decorations_initialized = true; 
        
        var _tile_width = 0;
        if (_spr_underlay != -1) {
            _tile_width = sprite_get_width(_spr_underlay);
        } else if (_spr_overlay != -1) {
            _tile_width = sprite_get_width(_spr_overlay);
        }
        
        if (_tile_width <= 0) {
            return;
        }
        
        // --- HYBRID CALCULATION ---

        // 1. Manually calculate the VISUAL left edge to ignore the collision mask.
        var _sprite_x_origin = sprite_get_xoffset(sprite_index);
        var _start_x = x - (_sprite_x_origin * image_xscale);
        
        // 2. Use the bounding box to get the reliable TOTAL width.
        var _total_width = bbox_right - bbox_left;
        
        var _tile_count = ceil(_total_width / _tile_width);
        
        // Loop and create each decoration sprite
        for (var i = 0; i < _tile_count; i++) {
            var _current_x = _start_x + (_tile_width / 2) + (i * _tile_width);
            
            if (_spr_overlay != -1) {
                layer_sprite_create("alForeground", _current_x, y, _spr_overlay);
            }
            if (_spr_underlay != -1) {
                layer_sprite_create("alBackground", _current_x, y, _spr_underlay);
            }
        }
    }
}