/// @function scr_parallax_scrolling(camera, layer_1, speed_1, layer_2, speed_2, layer_3, speed_3)
/// @param {Id.Camera} camera The camera to use for calculating parallax.
/// @param {string} layer_1 The name of the first background layer.
/// @param {real} speed_1 The scroll speed for the first layer.
/// @param {string} layer_2 The name of the second background layer.
/// @param {real} speed_2 The scroll speed for the second layer.
/// @param {string} layer_3 The name of the third background layer.
/// @param {real} speed_3 The scroll speed for the third layer.
function scr_parallax_scrolling(camera, layer_1, speed_1, layer_2, speed_2, layer_3, speed_3) {
    var _camera_x = camera_get_view_x(camera);
    
    var _bg_1_x_offset = _camera_x * speed_1;
    var _bg_2_x_offset = _camera_x * speed_2;
    var _bg_3_x_offset = _camera_x * speed_3;
    
    layer_x(layer_1, _bg_1_x_offset);
    layer_x(layer_2, _bg_2_x_offset);
    layer_x(layer_3, _bg_3_x_offset);
}