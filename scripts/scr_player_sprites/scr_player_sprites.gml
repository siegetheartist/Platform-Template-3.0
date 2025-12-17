/// @description Handle creating all necessary player assets (i.e. sprites and sounds)
/// @param {struct} _sprites Sprite struct: attack_01, attack_02, attack_03, air_attack_01, crouch, crouch_walk, jump, fall, run, idle_01, idle_02, die, hurt, wall_slide, default_collision_mask, crouch_collision_mask
/// @param {struct} _sounds Sounds struct: attack_01, jump_01, jump_02, jump_03, jump_landing, run_step_01, run_step_02, wall_grab, wall_slide, die, hurt
function define_player_assets(_sprites = {}, _sounds = {}) constructor {
    sprites = {
        attack_01 : _sprites.attack_01 ?? undefined,
        attack_02 : _sprites.attack_02 ?? undefined,
        attack_03 : _sprites.attack_03 ?? undefined,
        air_attack_01 : _sprites.air_attack_01 ?? undefined,
        air_attack_02 : _sprites.air_attack_02 ?? undefined,
        corner_grab : _sprites.corner_grab ?? undefined,
        corner_climb : _sprites.corner_climb ?? undefined,
        corner_jump : _sprites.corner_jump ?? undefined,
        crouch    : _sprites.crouch    ?? undefined,
        crouch_walk     : _sprites.crouch_walk     ?? undefined,
        jump      : _sprites.jump      ?? undefined,
        fall      : _sprites.fall      ?? undefined,
        run       : _sprites.run       ?? undefined,
        roll      : _sprites.roll       ?? undefined,
        idle_01   : _sprites.idle_01   ?? undefined,
        idle_02   : _sprites.idle_02   ?? undefined,
        die       : _sprites.die       ?? undefined,
        hurt      : _sprites.hurt      ?? undefined,
        wall_slide: _sprites.wall_slide?? undefined,
        default_collision_mask : _sprites.default_collision_mask ?? undefined,
        crouch_collision_mask  : _sprites.crouch_collision_mask  ?? undefined
    };

    sounds = {
        attack_01 : _sounds.attack_01 ?? undefined,
        jump_01   : _sounds.jump_01   ?? undefined,
        jump_02   : _sounds.jump_02   ?? undefined,
        jump_03   : _sounds.jump_03   ?? undefined,
        jump_landing : _sounds.jump_landing ?? undefined,
        run_step_01  : _sounds.run_step_01  ?? undefined,
        run_step_02  : _sounds.run_step_02  ?? undefined,
        wall_grab    : _sounds.wall_grab    ?? undefined,
        wall_slide   : _sounds.wall_slide   ?? undefined,
        die          : _sounds.die          ?? undefined,
        hurt         : _sounds.hurt         ?? undefined
    };
}

