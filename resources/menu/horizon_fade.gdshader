shader_type canvas_item;
// Fades the far rows of the title-scene ground into the horizon layer behind them.
// Ordered dithering keeps every pixel fully opaque or fully clear: no soft alpha.

uniform float fade_top = 196.0;
uniform float fade_bottom = 236.0;

const mat4 BAYER = mat4(
	vec4(0.0, 12.0, 3.0, 15.0),
	vec4(8.0, 4.0, 11.0, 7.0),
	vec4(2.0, 14.0, 1.0, 13.0),
	vec4(10.0, 6.0, 9.0, 5.0));

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float amount = clamp((world_position.y - fade_top) / max(fade_bottom - fade_top, 0.001), 0.0, 1.0);
	// Thresholds are indexed by whole world pixels, so the pattern stays locked to the art grid.
	ivec2 pixel = ivec2(floor(world_position));
	float threshold = (BAYER[pixel.x & 3][pixel.y & 3] + 0.5) / 16.0;
	if (amount < threshold) {
		COLOR.a = 0.0;
	}
}
