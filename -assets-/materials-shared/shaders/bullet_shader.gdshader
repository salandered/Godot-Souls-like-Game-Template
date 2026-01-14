shader_type spatial;

// -- SCROLLING EFFECT --
uniform sampler2D noise_sampler;
uniform sampler2D gradient_1D : source_color;
uniform float speed_scale = 1.0;

// -- STATIC TEXTURE --
uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float mix_strength : hint_range(0.0, 1.0) = 0.5; // 1.0 = All Texture, 0.0 = All Energy

// -- NORMAL MAP --
uniform sampler2D normal_map_texture : hint_normal;
uniform float normal_depth : hint_range(0.0, 5.0) = 1.0;

void vertex(){
	float v = sin((TIME * speed_scale * 4.0 + UV.y) * 10.0) - 0.5;
	VERTEX.xz += v * NORMAL.xz * 0.02;
}

void fragment() {
	// 1. Calculate Flow
	vec2 flow_uv = UV * vec2(1.0, 0.2) + vec2(0.0, TIME * speed_scale);
	float n = texture(noise_sampler, flow_uv).x;

	// 2. Get Static Texture
	vec3 static_albedo = texture(albedo_texture, UV).rgb * albedo_color.rgb;

	// 3. Get Energy Color
	vec3 energy_color = texture(gradient_1D, vec2(n, 0.0)).rgb;

	// 4. MIXING (The Fix)
	// We mix the colors based on the slider
	ALBEDO = mix(energy_color, static_albedo, mix_strength);

	// 5. EMISSION (The Fix)
	// If we are showing mostly texture (mix_strength near 1.0), we turn OFF emission
	// so it doesn't wash out the image.
	// We also multiply by 'n' so only the "high points" of the noise glow.
	float emission_power = (1.0 - mix_strength) * 2.0;
	EMISSION = energy_color * emission_power * n;

	// 6. Alpha / Transparency
	float edge = smoothstep(0.0, 0.8, UV.y);
	ALPHA = smoothstep(0.0, 0.15, edge * (n + smoothstep(0.6, 1.0, UV.y)));

	// 7. Normal Map
	vec3 normal_tex = texture(normal_map_texture, flow_uv).rgb;
	NORMAL_MAP = normal_tex;
	NORMAL_MAP_DEPTH = normal_depth;

	ROUGHNESS = 0.2;
	SPECULAR = 0.5;
}