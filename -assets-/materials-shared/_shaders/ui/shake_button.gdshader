shader_type canvas_item;

// --- Shake Settings ---
uniform float shake_power : hint_range(0.0, 0.1) = 0.03;
uniform float shake_speed : hint_range(0.0, 20.0) = 1.5;
uniform float time_offset = 0.0;

// --- Color Settings ---
uniform vec4 modulation_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// --- Shine Settings ---
uniform bool enable_shine = false;
uniform float shine_speed : hint_range(0.1, 5.0) = 1.0;
uniform float shine_frequency : hint_range(1.0, 10.0) = 5.0;
uniform float shine_width : hint_range(0.01, 0.5) = 0.15;

void fragment() {
	float node_alpha = COLOR.a;
	float current_time = TIME + time_offset;

	// 1. Calculate Shake / Distorted UV
	float offset_x = sin(current_time * shake_speed + UV.y * 20.0) * shake_power;
	vec2 distorted_uv = vec2(UV.x + offset_x, UV.y);
	
	// 2. Sample Texture
	vec4 tex_color = texture(TEXTURE, distorted_uv);
	
	// 3. Apply Modulation
	vec4 final_color = tex_color * modulation_color;

	// 4. Apply Shine (If enabled)
	if (enable_shine) {
		// Calculate the sweep position based on time
		float shine_pos = mod(current_time * shine_speed, shine_frequency);
		
		// Use UV.x + UV.y to create a diagonal line
		float diagonal = UV.x + UV.y;
		
		// Create the band using smoothstep for soft edges
		float shine = smoothstep(shine_pos, shine_pos + shine_width, diagonal) - 
		              smoothstep(shine_pos + shine_width, shine_pos + shine_width * 2.0, diagonal);
		
		// Add white to the color (mix based on shine strength and alpha)
		final_color.rgb = mix(final_color.rgb, vec3(1.0), shine * 0.5 * final_color.a);
	}
	
	// 5. Apply Node Transparency
	final_color.a *= node_alpha;
	
	COLOR = final_color;
}