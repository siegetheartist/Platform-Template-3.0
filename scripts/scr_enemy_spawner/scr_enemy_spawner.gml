/// @function scr_enemy_spawner(object, [spawn_rate], [max_instances]);
/// @param {asset.gml} object The object to spawn.
/// @param {real} [spawn_rate] The time between spawns, in game frames. Defaults to 480 (8 seconds at 60fps).
/// @param {real} [max_instances] The max number of spawned objects allowed. Defaults to -1 (infinite).

function scr_enemy_spawner(_object, _spawn_rate = 480, _max_instances = -1) {

    // Initialize variables if they don't exist
    if (!variable_instance_exists(id, "spawned_instances")) {
        spawned_instances = ds_list_create();
        spawn_timer = 0;
    }

    // Spawning Logic
    spawn_timer++;
    if (spawn_timer >= _spawn_rate) {
        spawn_timer = 0;

        // Clean up destroyed instances from the list
        for (var i = ds_list_size(spawned_instances) - 1; i >= 0; i--) {
            if (!instance_exists(spawned_instances[| i])) {
                ds_list_delete(spawned_instances, i);
            }
        }

        // Spawn new instance if below the max or if max is infinite (-1)
        if (_max_instances == -1 || ds_list_size(spawned_instances) < _max_instances) {
            var _inst = instance_create_layer(x, y, "ilMiddle", _object);
            ds_list_add(spawned_instances, _inst);
        }
    }
}

