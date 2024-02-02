shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

const int TEXTURE_SIZE = 32;

uniform vec4 line_color : source_color = vec4(1);
uniform bool show_outline = false;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE;
    float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    outline = min(outline, 1.0);
    
    vec4 color = texture(TEXTURE, UV);
    if (show_outline) {
        COLOR = mix(color, vec4(1.0), outline - color.a);
    }
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
