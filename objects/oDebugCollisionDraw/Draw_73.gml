if (global.debug_collision) {
    // --- Camera view bounds ---
    var cam = view_camera[0];
    var view_x = camera_get_view_x(cam);
    var view_y = camera_get_view_y(cam);
    var view_w = camera_get_view_width(cam);
    var view_h = camera_get_view_height(cam);

    // --- Tilemap info ---
    var tilemap_id = layer_tilemap_get_id("t_Collision");
    var tile_w = tilemap_get_tile_width(tilemap_id);
    var tile_h = tilemap_get_tile_height(tilemap_id);

    // --- Draw tile outlines in view ---
    var tx_start = max(0, floor(view_x / tile_w));
    var ty_start = max(0, floor(view_y / tile_h));
    var tx_end   = ceil((view_x + view_w) / tile_w);
    var ty_end   = ceil((view_y + view_h) / tile_h);

    draw_set_alpha(1);
    draw_set_color(c_red);

    for (var ty = ty_start; ty < ty_end; ty++) {
        for (var tx = tx_start; tx < tx_end; tx++) {
            var tiledata = tilemap_get(tilemap_id, tx, ty);
            if (tiledata != 0) {
                var x1 = tx * tile_w;
                var y1 = ty * tile_h;
                var x2 = x1 + tile_w;
                var y2 = y1 + tile_h;
                draw_rectangle(x1, y1, x2, y2, true);
            }
        }
    }

    // --- Player collision mask + paired edge highlight ---
    with (oPlayer) {
        var tm = layer_tilemap_get_id("t_Collision");

        var left   = bbox_left;
        var right  = bbox_right;
        var top    = bbox_top;
        var bottom = bbox_bottom;

        // Default outline
        draw_set_color(c_black);
        draw_rectangle(left, top, right, bottom, true);

        // --- Bottom collision ---
        if (place_meeting(x, bottom, tm)) {
            draw_set_color(c_yellow);
            draw_line(left, bottom, right, bottom);

            // Find tile under player
            var tx = floor(x / tile_w);
            var ty = floor(bottom / tile_h);
            var tile_x1 = tx * tile_w;
            var tile_y1 = ty * tile_h;
            var tile_x2 = tile_x1 + tile_w;
            // Highlight tile's top edge
            draw_line(tile_x1, tile_y1, tile_x2, tile_y1);
        }

        // --- Top collision ---
        if (place_meeting(x, top, tm)) {
            draw_set_color(c_yellow);
            draw_line(left, top, right, top);

            var tx = floor(x / tile_w);
            var ty = floor(top / tile_h);
            var tile_x1 = tx * tile_w;
            var tile_y2 = (ty + 1) * tile_h;
            // Highlight tile's bottom edge
            draw_line(tile_x1, tile_y2, tile_x1 + tile_w, tile_y2);
        }

        // --- Left collision ---
        if (place_meeting(left, y, tm)) {
            draw_set_color(c_yellow);
            draw_line(left, top, left, bottom);

            var tx = floor(left / tile_w);
            var ty = floor(y / tile_h);
            var tile_x2 = (tx + 1) * tile_w;
            var tile_y1 = ty * tile_h;
            var tile_y2 = tile_y1 + tile_h;
            // Highlight tile's right edge
            draw_line(tile_x2, tile_y1, tile_x2, tile_y2);
        }

        // --- Right collision ---
        if (place_meeting(right, y, tm)) {
            draw_set_color(c_yellow);
            draw_line(right, top, right, bottom);

            var tx = floor(right / tile_w);
            var ty = floor(y / tile_h);
            var tile_x1 = tx * tile_w;
            var tile_y1 = ty * tile_h;
            var tile_y2 = tile_y1 + tile_h;
            // Highlight tile's left edge
            draw_line(tile_x1, tile_y1, tile_x1, tile_y2);
        }
    }
}
