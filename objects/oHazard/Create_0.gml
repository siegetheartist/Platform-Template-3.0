/// @description Hazard Object Initialization
hazard_damage = 1; // Damage dealt to player on collision
hazard_knockback_h_strength = 0; // No horizontal knockback for spikes, only vertical
hazard_knockback_v_strength = -4; // Upward knockback for spikes (negative for up)


// --- Vertical Movement (NEW) ---
enum HazardVerticalMoveState {
    PAUSE,
    WINDUP,
    MOVING_UP,
    HOLD_UP,
    MOVING_DOWN
}
 
vmove_state = HazardVerticalMoveState.PAUSE; // Initial state
vmove_timer = 0; // Generic timer for state durations
 
// Configuration for vertical movement (set defaults, can be overridden per instance in room editor)
vmove_up_distance = 24; // Pixels to move up from y_start
vmove_windup_frames = 20; // Frames for initial warning oscillation
vmove_windup_oscillation_amount = 2; // Pixels (amplitude) for visual oscillation during windup
vmove_move_up_lerp_factor = 0.1; // Lerp factor (0-1) for speed to move up
vmove_hold_up_frames = 25; // Fixed frames to hold at top
vmove_move_down_lerp_factor = 0.05; // Lerp factor (0-1) for speed to move down

// Randomized pause duration options (will be used if vmove_randomize_pause_duration is true)
// Min value used as default when randomized option is turned off
vmove_pause_frames_min = 60; // Minimum frames to pause before windup (randomized option) 
vmove_pause_frames_max = 90; // Maximum frames to pause before windup (randomized option)
vmove_randomize_pause_duration = false; // NEW: Toggle for random pause duration (default: off)
 
 
// Internal tracking variables
y_start = y; // Store actual initial Y position of the instance
y_target_up = y_start - vmove_up_distance; // Calculate target up position (up is negative Y)
 
// Initialize timer for the first PAUSE phase, respecting the new randomization toggle
if (vmove_randomize_pause_duration) {
    vmove_timer = irandom_range(vmove_pause_frames_min, vmove_pause_frames_max);
} else {
    vmove_timer = vmove_pause_frames_min; // Use the min value as the fixed duration
}
