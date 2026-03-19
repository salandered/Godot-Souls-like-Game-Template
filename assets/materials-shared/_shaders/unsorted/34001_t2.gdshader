shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Physics
uniform float black_hole_radius : hint_range(0.0, 1.0) = 0.15;
uniform float distortion_strength : hint_range(0.0, 10.0) = 5.0;

// Visuals
uniform vec3 ring_color : source_color = vec3(1.0, 0.8, 0.5); // Orange glow
uniform float ring_width : hint_range(0.0, 0.2) = 0.05;
uniform vec3 inner_color : source_color = vec3(0.0, 0.0, 0.05); // Very dark blue/black
uniform float edge_softness : hint_range(0.0, 1.0) = 0.1;

// Quad fade
uniform float outer_fade_dist : hint_range(0.0, 0.5) = 0.5;

varying vec2 world_uv;
varying vec4 screen_position;

void vertex() {
	// Billboarding
	mat4 modified_model_view = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]
	);
	MODELVIEW_MATRIX = modified_model_view;
	screen_position = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	world_uv = UV;
}

void fragment() {
	vec2 uv = world_uv;
	vec2 centered_uv = uv - vec2(0.5);
	float dist = length(centered_uv);
	
	// --- DISTORTION MATH ---
	vec2 screen_uv = screen_position.xy / screen_position.w;
	screen_uv = screen_uv * 0.5 + 0.5;

	// Only distort OUTSIDE the radius
	float distortion_mask = smoothstep(black_hole_radius, black_hole_radius + 0.3, dist);
	vec2 distorted_uv = screen_uv;
	
	if (dist > 0.0) {
		// Calculate push strength (stronger near the center)
		float force = (black_hole_radius / dist) * distortion_strength * 0.02;
		// Apply mask so we don't distort the very center
		distorted_uv -= normalize(centered_uv) * force * distortion_mask;
	}

	vec3 bg_color = texture(screen_texture, distorted_uv).rgb;

	// --- COLOR COMPOSITION ---
	
	// Calculates how close we are to the "Event Horizon"
	float hole_factor = smoothstep(black_hole_radius - edge_softness, black_hole_radius, dist);
	
	// Mix between the inner void color and the background
	vec3 final_color = mix(inner_color, bg_color, hole_factor);
	
	// Creates a thin band of light exactly at the radius
	float ring_dist = abs(dist - black_hole_radius);
	float ring_glow = 1.0 - smoothstep(0.0, ring_width, ring_dist);
	
	// Add the ring on top (using screen blending for a light effect)
	final_color += ring_color * ring_glow * 2.0; // * 2.0 for extra brightness

	// --- ALPHA MASK ---
	float alpha = 1.0 - smoothstep(outer_fade_dist - 0.1, outer_fade_dist, dist);
	
	ALBEDO = final_color;
	ALPHA = alpha;
}