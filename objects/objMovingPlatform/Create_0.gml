// Inherit the parent event
event_inherited();

dir = 0; // Current angle of rotation around the origin (in degrees). Starts at 0, and increases each frame by rotation_speed.
var _arc_degrees = 360; // Define the arc we want to travel (degrees). 360 = full circle, 180 = half circle, 90 = quarter circle, etc.
var _seconds_per_arc = 3; // How many seconds should it take to complete this arc?
var _fps = game_get_speed(gamespeed_fps); // Frames per second (default GameMaker speed) usually 60
var _frames_per_arc = _fps * _seconds_per_arc; // Total frames for the arc
rotation_speed = _arc_degrees / _frames_per_arc; // Degrees per frame - how much the angle increases each frame (ex: 360/180 = 2)

radius = 32; // Distance from the origin (xstart, ystart) to the moving object.