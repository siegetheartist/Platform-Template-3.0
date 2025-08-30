#region NEXT LEVEL LOGIC
// Player triggers a fade-out to transition rooms.
instance_create_layer(0, 0, "l_Faders", oFader);
oFader.fader_mode = "next_level";

//IMPORTANT!!!
// room_goto_next() is set in the oFader object for a smooth transition.





#endregion