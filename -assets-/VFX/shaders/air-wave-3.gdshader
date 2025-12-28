shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise_tex;

// Settings
uniform float strength = 0.05;
uniform float speed = 5.0;
uniform float aberration : hint_range(0.0, 1.0) = 0.02;
uniform float shape_roughness = 0.5;

// NEW: Magic Color Settings
uniform vec4 magic_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Default Orange
uniform float color_intensity = 0.8; // How much color to apply

void vertex() {
	// 1. Vertex Displacement (Spiky Shape)
	float noise_val = texture(noise_tex, VERTEX.xz * 0.5 + (TIME * speed * 0.1)).r;
	float displacement = (noise_val - 0.5) * shape_roughness;
	VERTEX += NORMAL * displacement;
}

void fragment() {
	// 1. Noise logic
	vec2 noise_uv = UV + (TIME * speed);
	vec3 noise_val = texture(noise_tex, noise_uv).rgb;
	vec2 displacement = (noise_val.xy - 0.5) * strength;

	// 2. "Warm" Chromatic Aberration
	// Instead of R, G, B splitting evenly, we focus on Red and Green offsets
	// to create a "heat haze" look.
	float r = texture(screen_texture, SCREEN_UV + displacement - vec2(aberration, 0.0)).r;
	float g = texture(screen_texture, SCREEN_UV + displacement).g;
	// We keep Blue closer to center or weaken it to avoid "Sci-Fi Cyan"
	float b = texture(screen_texture, SCREEN_UV + displacement + vec2(aberration * 0.2, 0.0)).b;

	vec3 screen_color = vec3(r, g, b);

	// 3. Apply the Magic Tint
	// We mix the distorted screen with our orange color
	vec3 final_color = mix(screen_color, magic_color.rgb, color_intensity);

	// Optional: Boost brightness to look like glowing energy
	final_color = final_color * 1.5;

	// 4. Fresnel (Edge softness)
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);

	ALBEDO = final_color;
	ALPHA = fresnel * magic_color.a;
}