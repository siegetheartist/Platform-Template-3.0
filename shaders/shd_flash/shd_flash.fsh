varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 flash_color; // Color to flash (passed from GameMaker)

void main()
{
    vec4 base_col = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = vec4(base_col.rgb + flash_color.rgb, base_col.a);
}