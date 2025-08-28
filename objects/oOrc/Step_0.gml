// --- Orc Specific Movement and Animation ---

// Inherit the parent event (ONLY CALL ONCE PER EVENT TYPE)
event_inherited(); 

// The parent's Step event (oEnemy's Step event) has now executed, handling
// core AI, movement, and collisions. Now, add Orc-specific logic.

// --- Handle animation and sprite orientation using the helper script ---
scr_enemy_handle_animation();

// You can add any other Orc-specific logic here, e.g., unique attack patterns, sounds, etc.
