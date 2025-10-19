// Kept in the oGameManager persistent object for single source of all collidables
// collision_tileset_env = global.collision_environment;

// Make a copy and add player for movement resolution
//collision_tileset_env_and_player = array_create(array_length(collision_tileset_env));
//array_copy(collision_tileset_env_and_player, 0, collision_tileset_env, 0, array_length(collision_tileset_env));
//array_push(collision_tileset_env_and_player, oPlayer);