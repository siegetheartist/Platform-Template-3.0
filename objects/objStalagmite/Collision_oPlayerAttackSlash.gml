/// @description Take damage from player's attack

// Only take damage if the stalagmite hasn't started falling

// Reduce health by the damage from the slash
hp -= other.damage;

// Check if health has run out
if (hp <= 0) {
    // Call the destruction script
    scr_stalagmite_destroy();
}
