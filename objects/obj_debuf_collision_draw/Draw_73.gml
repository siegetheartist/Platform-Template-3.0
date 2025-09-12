/// Draw red outlines for all collision tiles in t_Collision

// Get the tilemap ID for the collision layer
var tilemap_id = layer_tilemap_get_id("t_Collision");

// Tile and map dimensions
var tile_w = tilemap_get_tile_width(tilemap_id);
var tile_h = tilemap_get_tile_height(tilemap_id);
var map_w  = tilemap_get_width(tilemap_id);
var map_h  = tilemap_get_height(tilemap_id);

// Outline color
draw_set_color(c_red);
draw_set_alpha(1);

// Loop through each tile cell
for (var ty = 0; ty < map_h; ty++) {
    for (var tx = 0; tx < map_w; tx++) {
        
        // Get tile data at this cell
        var tiledata = tilemap_get(tilemap_id, tx, ty);
        
        // If there’s a tile here, draw its bounding box
        if (tiledata != 0) {
            var x1 = tx * tile_w;
            var y1 = ty * tile_h;
            var x2 = x1 + tile_w;
            var y2 = y1 + tile_h;
            
            draw_rectangle(x1, y1, x2, y2, true); // true = outline only
        }
    }
}
