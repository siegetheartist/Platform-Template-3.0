/// @description Initialize Stalagmite

// --- Core Properties ---
hp = 1;                         // Health points
fall_speed = 4;                 // The maximum speed the stalagmite will fall at
trigger_mode = "proximity";       // "proximity" or "timer"
trigger_timer = 120;              // Time in frames before falling (if in timer mode)
proximity_width = 48;             // The horizontal distance from the center to trigger the fall

// --- Effects Properties ---
snd_destroy = sndWallDestroyed; // Sound to play on destruction
particle_x_offset = 40;           // Horizontal offset for particles
particle_y_offset = 80;           // Vertical offset for particles

// --- Internal Variables ---
state = "idle";                   // "idle", "shaking", "falling"
y_speedeed = 0;                       // Initial vertical speed
shake_duration = 60;              // How long to shake before falling (in frames)