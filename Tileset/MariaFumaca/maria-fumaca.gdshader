shader_type canvas_item;

uniform vec4 overlay_color : source_color = vec4(0.0, 0.15, 0.25, 0.15);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (tex_color.a > 0.0) {
        vec3 final_color = mix(tex_color.rgb, overlay_color.rgb, overlay_color.a);
        COLOR = vec4(final_color, tex_color.a);
    } else {
        COLOR = tex_color;
    }
}