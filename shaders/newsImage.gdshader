shader_type canvas_item;

uniform vec4 dark_color : source_color = vec4(0.5098, 0.4824, 0.4235, 1.0); // #827b6c
uniform vec4 light_color : source_color = vec4(0.8667, 0.8275, 0.7569, 1.0); // #ddd3c1
uniform float brightness_threshold : hint_range(0.0, 1.0) = 0.5;
uniform bool enabled = true;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (!enabled) {
        COLOR = tex;
    } else if (tex.a == 0.0) {
        COLOR = vec4(0.0);
    } else {
        float brightness = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

        if (brightness > brightness_threshold) {
            COLOR = vec4(light_color.rgb, tex.a);
        } else {
            COLOR = vec4(dark_color.rgb, tex.a);
        }
    }
}