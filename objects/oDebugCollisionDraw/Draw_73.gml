/// @description Main debug drawing logic

// --- Exit early if all debugs are off ---
if (!global.debug_draw_collision && !global.debug_draw_camera && !global.debug_draw_audio) {
    exit;
}

// --- Shared Camera/View Variables ---
// Get view info only if collision or camera debug is active
var cam, view_x, view_y, view_w, view_h;
if (global.debug_draw_collision || global.debug_draw_camera) {
    cam = view_camera[0];
    view_x = camera_get_view_x(cam);
    view_y = camera_get_view_y(cam);
    view_w = camera_get_view_width(cam);
    view_h = camera_get_view_height(cam);
}

// --- [NUMPAD 2] Collision Drawing ---
if (global.debug_draw_collision) {
    // --- Tilemap info ---
    var tilemap_id = layer_tilemap_get_id("tsCollision");
    var tile_w = tilemap_get_tile_width(tilemap_id);
    var tile_h = tilemap_get_tile_height(tilemap_id);
    var ts = tilemap_get_tileset(tilemap_id); // Get the tileset asset

    // --- Draw tile outlines in view ---
    var tx_start = max(0, floor(view_x / tile_w));
    var ty_start = max(0, floor(view_y / tile_h));
    var tx_end   = ceil((view_x + view_w) / tile_w);
    var ty_end   = ceil((view_y + view_h) / tile_h);

    // NEW: Use a shader to draw the sprite's shape in a solid color
    // NOTE: This requires a shader asset named 'shd_DebugSolidFill'
    if (shader_is_compiled(shd_DebugSolidFill)) {
        shader_set(shd_DebugSolidFill);
        
        // Set the color and alpha. The shader will use this.
        draw_set_color(c_red);
        draw_set_alpha(0.4); 

        for (var ty = ty_start; ty < ty_end; ty++) {
            for (var tx = tx_start; tx < tx_end; tx++) {
                var tiledata = tilemap_get(tilemap_id, tx, ty);
                if (tiledata != 0) {
                    var x1 = tx * tile_w;
                    var y1 = ty * tile_h;
                    
                    // Draw the tile. The shader intercepts this call
                    // and draws it as a solid red shape.
                    draw_tile(ts, tiledata, 0, x1, y1);
                }
            }
        }
        
        shader_reset();
        draw_set_alpha(1.0); // Reset alpha
    } 
    else {
        // FALLBACK: If shader is missing or failed, draw the old red boxes
        draw_set_alpha(0.4); 
        draw_set_color(c_red);

        for (var ty = ty_start; ty < ty_end; ty++) {
            for (var tx = tx_start; tx < tx_end; tx++) {
                var tiledata = tilemap_get(tilemap_id, tx, ty);
                if (tiledata != 0) {
                    var x1 = tx * tile_w;
                    var y1 = ty * tile_h;
                    draw_rectangle(x1, y1, x1 + tile_w, y1 + tile_h, false); 
                }
            }
        }
        draw_set_alpha(1.0); // Reset alpha
    }

    // --- Player collision mask + paired edge highlight ---
    if (instance_exists(oPlayer)) {
        
        // Store original draw settings ONCE before drawing any text
        var _original_font = draw_get_font();
        var _original_halign = draw_get_halign();
        var _original_valign = draw_get_valign();
        var _original_color = draw_get_color();
        
        with (oPlayer) {
            var left   = bbox_left;
            var right  = bbox_right;
            var top    = bbox_top;
            var bottom = bbox_bottom;
    
            // --- Draw the correct collision shape ---
    
            // NEW: Check if we are using the special 'pill' mask
            if (mask_index == sprPlayerCollisionMask) {
                
                // Use the shader to draw the mask's sprite shape
                if (shader_is_compiled(shd_DebugSolidFill)) {
                    shader_set(shd_DebugSolidFill);
                    
                    // NOTE: We don't need draw_set_color/alpha here,
                    // as we pass the color/alpha directly into draw_sprite_ext.
            
                    // Draw the mask's sprite at the player's position.
                    // The shader will turn it into a solid red fill.
                    // FIXED: Pass c_red and 0.4 directly to the function.
                    draw_sprite_ext(mask_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_white, 1.0);
                    
                    shader_reset();
                    draw_set_alpha(1.0); // Reset alpha
                }
                else {
                    // Fallback: Just draw the bounding box if shader fails
                    // We use a different color (fuchsia) to indicate the shader failed
                    draw_set_alpha(0.4);
                    draw_set_color(c_fuchsia);
                    draw_rectangle(left, top, right - 1, bottom - 1, false); 
                    draw_set_alpha(1);
                }
            }
            // Otherwise, draw the default rectangular bounding box
            else {
                draw_set_alpha(0.8);
                draw_set_color(c_red);
                
                // Draw the simple rectangle
                draw_rectangle(left, top, right - 1, bottom - 1, false); 
                
                draw_set_alpha(1); // Reset alpha
            }
            
            
            
            
            
            
            // --- Draw Text Above Player ---
        if (font_exists(fnt_debug_txt)) {
            // Set draw settings for text above player
            draw_set_font(fnt_debug_txt);
            draw_set_halign(fa_left);   
            draw_set_valign(fa_bottom); 
            draw_set_color(c_white);    
            
            with (oPlayer) { // Get player vars relative to player
                // Starting position (adjusted from your code)
                var _text_x = x - 32; 
                var _text_y = bbox_top - 20; 
                var _line_height = string_height(" ") + 2; // Adjusted gap
                
                // Draw Coyote Hang TImer
                draw_text(_text_x, _text_y, "Coyote Hang Timer: " + string(coyote_hang_timer)); 
                _text_y -= _line_height; 
                
                // Draw Coyote Jump Grace Timer
                draw_text(_text_x, _text_y, "Coyote Jump Grace: " + string(coyote_jump_timer)); 
                _text_y -= _line_height; 
                
                // Draw Jump Buffer Timer
                draw_text(_text_x, _text_y, "Jump Buffer: " + string(jump_input_buffer_timer)); 
                 _text_y -= _line_height; 
                
                // Draw Jump Counter
                draw_text(_text_x, _text_y, "Jump Count: " + string(jump_count) + "/" + string(jump_max)); 
                _text_y -= _line_height; 
                
                // Draw Current State
                var _state_string_name = "Unknown"; 
                switch (player_state) {
                    case PlayerState.IDLE:       _state_string_name = "Idle"; break;
                    case PlayerState.RUN:        _state_string_name = "Run"; break;
                    case PlayerState.AIR:        _state_string_name = "Air"; break;
                    case PlayerState.LEDGE_GRAB: _state_string_name = "Ledge Grab"; break;
                    case PlayerState.WALL_GRAB:  _state_string_name = "Wall Grab"; break;
                    case PlayerState.WALL_SLIDE: _state_string_name = "Wall Slide"; break;
                    case PlayerState.ATTACK:     _state_string_name = "Attack"; break;
                    case PlayerState.DEAD:       _state_string_name = "Dead"; break;
                }
                draw_text(_text_x, _text_y, "State: " + _state_string_name);
                // We don't need _text_y -= _line_height; here anymore
            } // End with(oPlayer) for text above player
        } else {
             show_debug_message("Warning: Debug font 'fnt_debug_txt' not found for player text.");
        }

        // --- Draw Text in Top-Right Corner ---
        if (font_exists(fnt_debug_txt)) {
             // Set draw settings for top-right text
            draw_set_font(fnt_debug_txt);
            draw_set_halign(fa_right); // Right align text
            draw_set_valign(fa_top);   // Align from the top down
            draw_set_color(c_white);   
            
            // Starting position (Top-Right corner of the VIEW + padding)
            var _corner_text_x = view_x + view_w - 10; // 10px padding from right
            var _corner_text_y = view_y + 10;          // 10px padding from top
            var _corner_line_height = string_height(" ") + 2; // Height + 2px gap

            // Draw Y Position (formatted to 0 decimal places)
            draw_text(_corner_text_x, _corner_text_y, "Y Pos: " + string_format(y, 1, 0));
            _corner_text_y += _corner_line_height; // Move down for the next line

            // Draw X Position (formatted to 0 decimal places)
            draw_text(_corner_text_x, _corner_text_y, "X Pos: " + string_format(x, 1, 0));
            _corner_text_y += _corner_line_height; // Move down for the next line
            
            // Draw Y Speed (using y_speed) - formatted to 2 decimal places
            draw_text(_corner_text_x, _corner_text_y, "Y Speed: " + string_format(y_speed, 1, 2));
             _corner_text_y += _corner_line_height; // Move down for the next line
            
            // Draw X Speed (using x_speed) - formatted to 2 decimal places
            draw_text(_corner_text_x, _corner_text_y, "X Speed: " + string_format(x_speed, 1, 2));
            _corner_text_y += _corner_line_height; // Move down for the next line
            
            // Draw On ground
            var _is_on_ground = on_ground;
            if (_is_on_ground) {
            	_is_on_ground = "True";
            } else {
            	_is_on_ground = "False";
            }
            draw_text(_corner_text_x, _corner_text_y, "On Ground: " + string(_is_on_ground));
            _corner_text_y += _corner_line_height; // Move down for the next line
            
            draw_text(_corner_text_x, _corner_text_y, "Wall Grab Timer: " + string(wall_grab_timer));
            _corner_text_y += _corner_line_height; // Move down for the next line
            
            //draw_text(_corner_text_x, _corner_text_y, "Coyote Jump grace: " + string(coyote_jump_timer));
            
        } else {
             show_debug_message("Warning: Debug font 'fnt_debug_txt' not found for corner text.");
        }
        
        // Restore original draw settings AFTER all text is drawn
        draw_set_font(_original_font);
        draw_set_halign(_original_halign);
        draw_set_valign(_original_valign);
        draw_set_color(_original_color);
            
            
            
            
            
            
    
            // --- Bottom collision ---
            // Use 'bottom' (which is bbox_bottom) to check 1px *below* the mask's last pixel
            if (collision_rectangle(left, bottom, right - 1, bottom, tilemap_id, false, false)) {
                // Yellow lines removed as requested
            }
    
            // --- Top collision ---
            // Use 'top - 1' (which is bbox_top - 1) to check 1px *above* the mask
            if (collision_rectangle(left, top - 1, right - 1, top - 1, tilemap_id, false, false)) {
                // Yellow lines removed as requested
            }
    
            // --- Left collision ---
            // Use 'left - 1' (which is bbox_left - 1) to check 1px *left* of the mask
            if (collision_rectangle(left - 1, top, left - 1, bottom - 1, tilemap_id, false, false)) {
                // Yellow lines removed as requested
            }
    
            // --- Right collision ---
            // Use 'right' (which is bbox_right) to check 1px *right* of the mask's last pixel
            if (collision_rectangle(right, top, right, bottom - 1, tilemap_id, false, false)) {
                // Yellow lines removed as requested
            }
        }
    }
}


// --- [NUMPAD 1] Camera Debug Lines ---
if (global.debug_draw_camera) {
    if (instance_exists(oCamera)) {
        var _cam = oCamera; // Get the instance once
        
        // --- Camera look-ahead debug lines ---
        var _cam_center_x = _cam.cam_x;
        var _look_ahead_offset = _cam.look_ahead_offset_amount;
        var _outer_threshold = _cam.outer_threshold_offset;
        var _inner_focus_zone = _cam.inner_focus_zone_offset;
        var _line_y_achor_start = view_y + 48;
        var _line_y_anchor_end = view_y + view_h - 48;
        var _line_y_thresh_start = view_y + 56;
        var _line_y_thresh_end = view_y + view_h - 56;
        
        draw_set_alpha(1);
        draw_set_color(c_white);

        var _inner_left_x = _cam_center_x - _inner_focus_zone;
        draw_line_width(_inner_left_x, _line_y_achor_start, _inner_left_x, _line_y_anchor_end, 1.5);
        var _inner_right_x = _cam_center_x + _inner_focus_zone;
        draw_line_width(_inner_right_x, _line_y_achor_start, _inner_right_x, _line_y_anchor_end, 1.5);
        var _outer_left_x = _cam_center_x - _outer_threshold;
        draw_line_width(_outer_left_x, _line_y_thresh_start, _outer_left_x, _line_y_thresh_end, .5);
        var _outer_right_x = _cam_center_x + _outer_threshold;
        draw_line_width(_outer_right_x, _line_y_thresh_start, _outer_right_x, _line_y_thresh_end, .5);
    
        // --- Camera vertical deadzone debug ---
        _cam_center_x = _cam.cam_x;
        var _cam_center_y = _cam.cam_y;
        var _margin_y = _cam.cam_y_deadzone;
        var _offset_y = _cam.vertical_offset;
        var _debug_anchor_y = _cam_center_y + _offset_y;
        var _deadzone_top    = _debug_anchor_y - _margin_y;
        var _deadzone_bottom = _debug_anchor_y + _margin_y;
        var _left  = _cam_center_x - (_cam.cam_width / 2);
        var _right = _cam_center_x + (_cam.cam_width / 2);
    
        draw_set_alpha(1);
        draw_set_color(c_white); 
        draw_line_width(_left, _deadzone_top, _right, _deadzone_top, 1.5);
        draw_line_width(_left, _deadzone_bottom, _right, _deadzone_bottom, 1.5);
    
        // --- Optional: draw player origin for clarity ---
        if (instance_exists(_cam.target)) {
            var _px = _cam.target.x;
            var _py = _cam.target.y;
            draw_set_color(c_red);
            draw_line(_px - 6, _py, _px + 6, _py);
            draw_line(_px, _py - 6, _px, _py + 6);
        }
    }
}
        
// --- [NUMPAD 3] Spatial Sound Ranges ---
if (global.debug_draw_audio) {
    if (instance_exists(objTrapSpike)) {
        with (objTrapSpike) {
            draw_spatial_sound_debug();
        }
    }
    
    if (instance_exists(objTrapSpear)) {
        with (objTrapSpear) {
            draw_spatial_sound_debug();
        }
    }
    
    if (instance_exists(objTimedPlatform)) {
        with (objTimedPlatform) {
            draw_spatial_sound_debug();
        }
    }
}

