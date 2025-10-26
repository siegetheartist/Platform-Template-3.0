//
// Fragment Shader: Replaces sprite pixels with a solid color
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour; // This holds the color/alpha from draw_set_*

void main()
{
    // Get the pixel from the sprite
    vec4 texel = texture2D( gm_BaseTexture, v_vTexcoord );
    
    // If the pixel is not fully transparent
    if (texel.a > 0.01) // Use a small threshold
    {
         // Draw it using the color and alpha set in GML
         // (e.g., c_red at 0.4 alpha)
         gl_FragColor = v_vColour; 
    }
    else
    {
         // Otherwise, discard the pixel
         gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0); // Transparent
    }
}