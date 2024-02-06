shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float progress : hint_range(0, 1) = 0.0;
uniform vec2 region_rect_pos;

void fragment() {
    ivec2 texture_size = textureSize(TEXTURE, 0);
    vec2 snapped_uv = vec2(float(int(UV.x * float(texture_size.x))) / float(texture_size.x), float(int(UV.y * float(texture_size.y))) / float(texture_size.y));
    vec2 tile_center = vec2((region_rect_pos.x + 16.0) * TEXTURE_PIXEL_SIZE.x, (region_rect_pos.y + 16.0) * TEXTURE_PIXEL_SIZE.y);
    vec2 offset = snapped_uv - tile_center;
    offset.y *= 0.5;
	float distance_from_center = length(offset);
    float discard_distance = TEXTURE_PIXEL_SIZE.x * 48.0 * progress;
    int discard_modifier = int(distance_from_center > discard_distance);
    vec4 sampled = texture(TEXTURE, UV);
    sampled.a *= float(discard_modifier);
    COLOR = sampled;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
