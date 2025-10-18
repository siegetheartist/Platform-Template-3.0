/// @description Stalagmite Logic

// State machine
switch (state) {
    case "idle":
        // --- Trigger Logic ---
        var triggered = false;
        if (trigger_mode == "timer") {
            trigger_timer--;
            if (trigger_timer <= 0) {
                triggered = true;
            }
        } else if (trigger_mode == "proximity") {
            var player = instance_find(oPlayer, 0);
            if (player) {
                if (abs(x - player.x) < proximity_width && player.y > y) {
                    triggered = true;
                }
            }
        }

        if (triggered) {
            state = "shaking";
        }
        break;

    case "shaking":
        // --- Shake and Countdown ---
        scr_obj_shake(self, 0, 30, 2, "random");
        shake_duration--;
        if (shake_duration <= 0) {
            state = "falling";
        }
        break;

     case "falling":
        // --- Fall and Collide ---
        vspeed = lerp(vspeed, fall_speed, 0.05);
        y += vspeed;
        
        var hazard_collisions = global.collision_environment;

        // Check for collision with the ground
        for (var i = 0; i < array_length(hazard_collisions); i++) {
            if (place_meeting(x, y + vspeed, hazard_collisions[i])) {
                // Call the destruction script
                scr_stalagmite_destroy();
                break; 
            }
        }
        break;
}