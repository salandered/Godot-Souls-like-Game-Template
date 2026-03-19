shader_type spatial;
render_mode cull_disabled;

// Textures
uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D noise_texture;

// Settings
uniform float normal_strength : hint_range(0.0, 5.0) = 1.0;
uniform vec4 rim_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float rim_power : hint_range(0.5, 8.0) = 2.0;

// Chaos Settings
uniform vec2 scroll_speed = vec2(0.1, 0.1);
uniform vec2 noise_scroll_speed = vec2(0.1, 0.2);
uniform float displacement_amount : hint_range(0.0, 1.0) = 0.3;
uniform float erosion_level : hint_range(0.0, 1.0) = 0.3;
uniform float edge_glow_intensity : hint_range(1.0, 20.0) = 10.0;

void vertex() {
	vec2 noise_uv = UV + (noise_scroll_speed * TIME);
	float noise_value = textureLod(noise_texture, noise_uv, 0.0).r;

	float displacement = (noise_value - 0.5) * displacement_amount;
	VERTEX += normalize(VERTEX) * displacement;
}

void fragment() {
	vec2 scrolled_uv = UV + (scroll_speed * TIME);
	vec2 noise_uv = UV + (noise_scroll_speed * TIME);

	vec4 albedo_tex = texture(albedo_texture, scrolled_uv);
	vec3 raw_normal = texture(normal_texture, scrolled_uv).rgb;
	float noise_value = texture(noise_texture, noise_uv).r;

	if (noise_value < erosion_level) {
		discard;
	}

	float edge_factor = smoothstep(erosion_level, erosion_level + 0.05, noise_value);
	float edge_glow = 1.0 - edge_factor;

	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), raw_normal, normal_strength);
	ALBEDO = albedo_tex.rgb;
	ROUGHNESS = 0.8;
	SPECULAR = 0.1;

	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);

	// fixed rim_color for now
	vec3 final_emission = (rim_color.rgb * fresnel * 2.0) + (rim_color.rgb * edge_glow * edge_glow_intensity);

	EMISSION = final_emission;
}