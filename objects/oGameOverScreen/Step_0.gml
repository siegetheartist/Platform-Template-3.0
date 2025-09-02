/// @description Handle player input on the Game Over screen.
// This code checks for mouse clicks on the buttons.

// Check if the left mouse button has been released this step.
if (mouse_check_button_released(mb_left)) {
    
    // Find the instance of the button that the mouse is currently over.
    // NOTE: The UI layer needs to contain button objects for this to work.
    // We are looking for an object that has the 'button_id' variable.
    var _button_instance = instance_position(mouse_x, mouse_y, all);

    if (instance_exists(_button_instance)) {
        // Check if the instance has the 'button_id' variable to confirm it's a button.
        if (variable_instance_exists(_button_instance, "button_id")) {
            // Check the 'button_id' value to determine which button was clicked.
            switch (_button_instance.button_id) {
                
                // Case 0: The "Try Again" button was clicked.
                case 0:
                    // Reactivate all game instances before changing rooms.
                    instance_activate_all();
                    // Restart the entire game from the beginning.
                    game_restart();
                    break;
                    
                // Case 1: The "Back to Menu" button was clicked.
                case 1:
                    // Reactivate all game instances before changing rooms.
                    instance_activate_all();
                    // Go to the main menu room.
                    // IMPORTANT: Replace "rm_Menu" with the actual name of your menu room.
                    room_goto(rStartMenu);
                    break;
            }
        }
    }
}
