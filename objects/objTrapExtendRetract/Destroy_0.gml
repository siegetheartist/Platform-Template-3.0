// Remove emitter from lingering in memory
if (variable_instance_exists(self, "hazard_emitter")) {
    audio_emitter_free(hazard_emitter);
}
