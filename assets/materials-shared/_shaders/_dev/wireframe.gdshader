shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 albedo : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float transparency : hint_range(0.0, 1.0) = 0.0;     // Background Alpha
uniform float line_transparency : hint_range(0.0, 1.0) = 1.0; // Line Alpha (New)
uniform float wire_width : hint_range(0.0, 5.0) = 1.0;


uniform bool use_barycentric = true;
uniform bool use_perspective = false;
varying vec3 barys;
uniform vec2 grid_density = vec2(10.0, 5.0);

float get_grid_lines(vec2 uv, vec2 density, float width) {
	vec2 scaled_uv = uv * density;
	vec2 dxdy = fwidth(scaled_uv);
	vec2 dist_from_line = abs(fract(scaled_uv - 0.5) - 0.5);
	vec2 lines = smoothstep(dxdy * width - 0.01, dxdy * width + 0.01, dist_from_line);
	return min(lines.x, lines.y);
}

void vertex() {
	int index = VERTEX_ID % 3;
	if (index == 0) barys = vec3(1.0, 0.0, 0.0);
	else if (index == 1) barys = vec3(0.0, 1.0, 0.0);
	else barys = vec3(0.0, 0.0, 1.0);
}

void fragment() {
	float wires = 1.0;

	if (use_barycentric) {
		vec3 threshold_lower;

		if (use_perspective) {
			float width_factor = wire_width * 0.05;
			threshold_lower = vec3(width_factor);
			vec3 barys_s = step(threshold_lower, barys);
			wires = min(barys_s.x, min(barys_s.y, barys_s.z));
		} else {
			vec3 deltas = fwidth(barys);
			threshold_lower = deltas * wire_width - 0.01;
			vec3 threshold_upper = deltas * wire_width + 0.01;
			vec3 barys_s = smoothstep(threshold_lower, threshold_upper, barys);
			wires = min(barys_s.x, min(barys_s.y, barys_s.z));
		}
	} 
	else {
		wires = get_grid_lines(UV, grid_density, wire_width);
	}

	ALBEDO = albedo.rgb;
	
	ALPHA = mix(line_transparency, transparency, wires);
}