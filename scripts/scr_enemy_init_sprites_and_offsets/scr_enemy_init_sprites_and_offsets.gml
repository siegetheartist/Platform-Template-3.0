/// @function scr_enemy_init_sprites_and_offsets(_idle_sprite, _patrol_move_sprite, _chase_move_sprite, _taunt_sprite)
/// @arg {sprite_index} _idle_sprite           The specific idle sprite for this enemy type.
/// @arg {sprite_index} _patrol_move_sprite    The movement sprite for PATROL/ALERT states.
/// @arg {sprite_index} _chase_move_sprite     The movement sprite for CHASE state.
/// @arg {sprite_index} _taunt_sprite          The specific taunt sprite for this enemy type.

function scr_enemy_init_sprites_and_offsets(_idle_sprite, _patrol_move_sprite, _chase_move_sprite, _taunt_sprite) {
    // Set the instance's primary sprite and animation sprites
    self.sprite_index = _idle_sprite;        // Sets initial sprite to the idle sprite
    self.spr_idle_specific = _idle_sprite;   // Store the specific idle sprite for later use
    self.spr_patrol_move = _patrol_move_sprite;
    self.spr_chase_move = _chase_move_sprite;
    self.spr_taunt_specific = _taunt_sprite; // NEW: Store the specific taunt sprite
    self.exclamation_sprite = spr_exclamation; // Always use spr_exclamation

    // --- Calculate offsets based on actual sprite_width/height ---
    // These calculations must happen AFTER sprite_index is set, so sprite_width/height are correct.
    // Using 'self.' to explicitly refer to the calling instance's properties.
    self._edge_check_offset = self.sprite_width / 2 + 2;   // Offset for horizontal edge check
    self._ground_check_offset = self.sprite_height / 2 + 1; // Offset for vertical ground check
}
