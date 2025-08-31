#region CHECKPOINT LOGIC
// First, loop through all checkpoints and reset their visual state to 'off'.
with (oCheckpoint) {
    image_index = 0; // Sets every checkpoint instance to the 'off' sprite frame.
}

// Now, update the sprite for the specific checkpoint the player just collided with.
other.image_index = 1; 

// Save the player's new checkpoint coordinates.
global.checkpoint_x = x;
global.checkpoint_y = y;

#endregion