/// @description Checks for attack input and initiates the attack state. Takes priority over other transitions)
/// @arg {bool} _key_attack_pressed Is the attack key pressed this frame?
function scr_player_input_attack(_key_attack_pressed) {
    if (_key_attack_pressed && player_state != PlayerState.ATTACK && player_state != PlayerState.DEAD) {
        // Player can initiate an attack from IDLE, RUN, or AIR states
        if (player_state == PlayerState.IDLE || player_state == PlayerState.RUN || player_state == PlayerState.AIR) {
            player_state = PlayerState.ATTACK; // Transition to the ATTACK state
            return true; // Indicate that an attack was initiated
        }
    }
    return false; // No attack initiated this frame
}