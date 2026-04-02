/// @description Calculates the total horizontal offset between two sprites, factoring in a desired gap.
/// @param sprite_a The first sprite (usually the attacker)
/// @param sprite_b The second sprite (usually the attack hitbox)
/// @param desired_gap [optional] The pixel gap between the edges (defaults to -1)

function scr_get_offset(_sprite_a, _sprite_b, _desired_gap = -1) {
    var _half_a = sprite_get_width(_sprite_a) / 2;
    var _half_b = sprite_get_width(_sprite_b) / 2;
    return _half_a + _desired_gap + _half_b;
}
