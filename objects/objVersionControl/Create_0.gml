
var section = "Build";
var key     = "Number";

// Always open the INI first
ini_open("build_counter.ini");

// Read current build number (default to 1 if missing)
if (ini_key_exists(section, key)) {
    build_num = ini_read_real(section, key, 1);
} else {
    build_num = 1;
}

// Increment and persist
ini_write_real(section, key, build_num + 1);

// Close when done
ini_close();

// Format version string: v1.0001, v1.0002, etc.
// Convert build_num to string and pad with leading zeros
var num_str = string(build_num);
while (string_length(num_str) < 4) {
    num_str = "0" + num_str;
}

// Final version string
version_string = "v1." + num_str;



