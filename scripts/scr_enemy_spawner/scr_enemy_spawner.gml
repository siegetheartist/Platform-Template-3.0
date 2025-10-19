/// @description Spawns an enemy. Change enemy object in Variable Definitions
/// @param {asset.gml} object The object to spawn.
/// @param {real} [spawn_rate] The time between spawns, in game frames. Defaults to 480 (8 seconds at 60fps).
/// @param {real} [max_instances] The max number of spawned objects allowed. Defaults to -1 (infinite).
/// 
function scr_enemy_spawner (_object, _spawn_rate = 480, _max_instances = -1) {
    
    // Initialize instance variables if they don't exist
    if (!variable_instance_exists(id, "spawned_instances")) {
        spawned_instances = [];
        spawn_timer = 0;
        spawn_object = _object;
        max_enemies = _max_instances;
        spawn_rate = _spawn_rate;
    }

    // 1. ALWAYS clean up the list of destroyed instances first. This is crucial!
    // This ensures we have an accurate count of active enemies.
    for (var i = array_length(spawned_instances) - 1; i >= 0; i--) {
        if (!instance_exists(spawned_instances[i])) {
            array_delete(spawned_instances, i, 1);
        }
    }
    
    // 2. ONLY if there is room for more enemies, do we run the timer.
    if (array_length(spawned_instances) < max_enemies) {
        
        spawn_timer++; // The timer now only counts up when it's supposed to.
    
        // 3. If the timer is ready, spawn a new enemy and reset.
        if (spawn_timer >= spawn_rate) {
            spawn_timer = 0; // Reset the timer for the *next* spawn
    
            var _inst = instance_create_layer(x, y, "ilMiddle", spawn_object);
            array_push(spawned_instances, _inst);
        }
    }
    
}
