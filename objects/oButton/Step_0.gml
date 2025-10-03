/// oButton - Step Event

var _selected = -1; // Local temp for this step

// Check which controller exists and grab its selected_button
if (instance_exists(objStartScreen)) {
    _selected = objStartScreen.selected_button;
}
else if (instance_exists(oGameManager)) {
    _selected = oGameManager.selected_button;
}

// Compare against this button's ID
if (button_id == _selected) {
    image_index = 1; // Show the active sprite
} else {
    image_index = 0; // Show the deactivated sprite
}
