shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// RETRO LOOK
uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 4.0;
uniform float bits_per_channel : hint_range(1.0, 8.0) = 4.0;
uniform float dither_strength : hint_range(0.0, 0.2) = 0.05;

// BLOOM / GLOW
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.8;
uniform float bloom_intensity : hint_range(0.0, 5.0) = 1.0;

// COLOR TINTING (Relaxation)
uniform float color_relaxation : hint_range(0.0, 1.0) = 0.1;
uniform vec3 relaxation_color : source_color = vec3(1.0, 1.0, 1.0);

float noise(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// 1. Pixelation
	// We snap the SCREEN_UV to a grid based on pixel_size
	vec2 grid_uv = round(SCREEN_UV / SCREEN_PIXEL_SIZE / pixel_size) * SCREEN_PIXEL_SIZE * pixel_size;
	vec4 col = texture(screen_texture, grid_uv);

	// 2. Color Bit Depth Reduction
	float max_val = pow(2.0, bits_per_channel) - 1.0;
	col.rgb = floor(col.rgb * max_val) / max_val;

	// 3. Dithering (Noise)
	// We use the snapped UVs for noise so the noise looks "big" like the pixels
	vec3 dither = vec3(
		noise(grid_uv + TIME),
		noise(grid_uv + TIME + vec2(1.0, 0.0)),
		noise(grid_uv + TIME + vec2(0.0, 1.0))
	);
	col.rgb += (dither - 0.5) * dither_strength;

	// 4. Color Relaxation (Tint)
	col.rgb = mix(col.rgb, relaxation_color, color_relaxation);

	// 5. Simple Bloom
	// If the pixel is very bright, make it brighter
	vec3 bloom_mask = step(vec3(bloom_threshold), col.rgb); // 1.0 if bright, 0.0 if not
	col.rgb += (col.rgb - bloom_threshold) * bloom_intensity * bloom_mask;

	COLOR = col;
}