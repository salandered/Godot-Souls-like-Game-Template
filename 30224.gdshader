shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float black_hole_radius : hint_range(0.0, 1.0) = 0.15;
uniform float distortion_strength : hint_range(0.0, 10.0) = 5.0;
uniform float outer_fade_dist : hint_range(0.0, 0.5) = 0.5;

varying vec2 world_uv;
varying vec4 screen_position;

void vertex() {
	// Billboarding: Forces the mesh to always face the camera
	// Remove this block if you want to place the black hole flat on the ground
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
	
	// Convert vertex position to screen coordinates
	vec2 screen_uv = screen_position.xy / screen_position.w;
	screen_uv = screen_uv * 0.5 + 0.5;

	// Calculate Distortion (Lensing Effect)
	vec2 distorted_uv = screen_uv;
	float hole_mask = 0.0;
	
	if (dist > black_hole_radius) {
		// Outside the event horizon: Bend light
		vec2 dir = normalize(centered_uv);
		// Stronger distortion closer to the center
		float distortion = (black_hole_radius / dist) * distortion_strength * 0.02;
		distorted_uv -= dir * distortion;
	} else {
		// Inside the event horizon: Pure Black
		hole_mask = 1.0;
	}

	// Sample the background with the distorted UVs
	vec3 bg_color = texture(screen_texture, distorted_uv).rgb;
	
	// Create the black center
	vec3 final_color = mix(bg_color, vec3(0.0), hole_mask);

	// Alpha Fade: Make the edges of the QuadMesh invisible so it looks like a sphere
	// smoothstep(edge, center, current)
	float alpha = 1.0 - smoothstep(outer_fade_dist - 0.1, outer_fade_dist, dist);
	
	ALBEDO = final_color;
	ALPHA = alpha;
}