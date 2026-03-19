shader_type spatial;
render_mode unshaded;

uniform vec3 core_color : source_color = vec3(1.0, 0.6, 0.2);
uniform vec3 rim_color : source_color = vec3(1.0, 0.9, 0.6);
uniform float emission_strength : hint_range(0.0, 5.0) = 1.5;

uniform float rim_power : hint_range(0.5, 8.0) = 3.0;

uniform sampler2D noise_texture : filter_linear_mipmap;
uniform float noise_scale : hint_range(0.1, 5.0) = 1.0;
uniform float speed : hint_range(0.0, 0.5) = 0.05;

// Controls how distinct the noise patterns are (Higher = sharper blobs)
uniform float noise_contrast : hint_range(0.1, 10.0) = 2.0; 
// Controls how strongly the noise changes the color (0.0 = invisible, 1.0 = full replacement)
uniform float noise_strength : hint_range(0.0, 1.0) = 0.5;
// --------------------

void fragment() {
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), rim_power);
	
	vec2 uv_scroll_1 = UV + (vec2(0.1, 0.1) * TIME * speed);
	vec2 uv_scroll_2 = UV + (vec2(-0.1, 0.15) * TIME * speed * 0.7);
	
	float noise_1 = texture(noise_texture, uv_scroll_1 * noise_scale).r;
	float noise_2 = texture(noise_texture, uv_scroll_2 * noise_scale).r;
	
	float noise_combined = (noise_1 + noise_2) * 0.5;
	
	// apply contrast to the noise
	noise_combined = pow(noise_combined, noise_contrast);
	
	vec3 base_color = mix(core_color, rim_color, fresnel);
	
	// use Strength slider to mix the rim color in
	base_color = mix(base_color, rim_color, noise_combined * noise_strength);

	ALBEDO = base_color * emission_strength;
}