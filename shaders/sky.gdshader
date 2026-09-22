shader_type canvas_item;

uniform float screen_height = 270.0;

void fragment() {
    int pixel_y = int(UV.y * screen_height);
    
    float diff_x = 0.0;


    diff_x = 0.035 * sin((10.0 * UV.y) + (2.0 * TIME));

    
    // Sample texture with wave offset
    vec4 tex_color = texture(TEXTURE, vec2(UV.x, UV.y+diff_x));
    

    tex_color = mix(tex_color, vec4(0.0, 0.0, 0.0, tex_color.a), 0.5);

    COLOR = tex_color;
}