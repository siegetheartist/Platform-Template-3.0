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
 
    // --- Camera look-ahead debug lines ---
    if (instance_exists(oCamera)) {
        var _cam_instance = oCamera;
        var _cam_center_x = _cam_instance.cam_x; // Camera's center X world coordinate
 
        // Get the relevant offsets from the camera instance
        var _look_ahead_offset = _cam_instance.look_ahead_offset_amount;
        var _outer_threshold = _cam_instance.outer_threshold_offset;
        var _inner_focus_zone = _cam_instance.inner_focus_zone_offset;
 
        // Calculate Y-coordinates for the lines with padding from top/bottom
        var _line_y_achor_start = view_y + 48;
        var _line_y_anchor_end = view_y + view_h - 48;
        
        var _line_y_thresh_start = view_y + 56;
        var _line_y_thresh_end = view_y + view_h - 56;
        
        draw_set_alpha(1);
        draw_set_color(c_white);
 
        // Draw Inner Anchor Flags
        var _inner_left_x = _cam_center_x - _inner_focus_zone;
        draw_line_width(_inner_left_x, _line_y_achor_start, _inner_left_x, _line_y_anchor_end, 1.5);
        var _inner_right_x = _cam_center_x + _inner_focus_zone;
        draw_line_width(_inner_right_x, _line_y_achor_start, _inner_right_x, _line_y_anchor_end, 1.5);
 
        // Draw Outer Threshold Flags
        var _outer_left_x = _cam_center_x - _outer_threshold;
        draw_line_width(_outer_left_x, _line_y_thresh_start, _outer_left_x, _line_y_thresh_end, .5);
        var _outer_right_x = _cam_center_x + _outer_threshold;
        draw_line_width(_outer_right_x, _line_y_thresh_start, _outer_right_x, _line_y_thresh_end, .5);
    }
    
    // --- Spatial sound range for oSpikeTrap ---
    with (oSpikeTrap) {
        // Preserve draw settings for other debug elements, reset at end of this loop
        var _prev_alpha = draw_get_alpha();
        var _prev_color = draw_get_color();
 
        // Visualize full volume zone
        draw_set_alpha(0.20); // Set to 20% opacity
        draw_set_color(c_lime); 
        draw_circle(x, y, falloff_ref, false);
 
        // Visualize fade-out boundary
        draw_set_alpha(0.60); // Set to 60% opacity
        draw_set_color(c_red); 
        draw_circle(x, y, falloff_max, true);
        
        draw_set_alpha(_prev_alpha);
        draw_set_color(_prev_color);
    }
    
}