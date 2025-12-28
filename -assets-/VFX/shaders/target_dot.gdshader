shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float ring_radius = 0.4;
uniform float ring_thickness = 0.05;

void vertex() {
	// Creates a matrix that always faces the camera (Spherical)
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]
	);
	
	// Preserves scaling from Inspector
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
}

void fragment() {
	vec2 uv_center = UV - 0.5;
	float dist = length(uv_center);
	
	float ring = smoothstep(ring_radius, ring_radius - 0.01, dist) - 
				 smoothstep(ring_radius - ring_thickness, ring_radius - ring_thickness - 0.01, dist);
	
	ALBEDO = color.rgb;
	ALPHA = ring * color.a;
}