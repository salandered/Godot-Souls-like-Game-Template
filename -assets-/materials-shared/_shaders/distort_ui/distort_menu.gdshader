shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise_texture : repeat_enable;

// --- DISTORTION SETTINGS ---
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.005;
uniform float speed : hint_range(0.0, 1.0) = 0.1;

// --- COLOR CORRECTION SETTINGS ---
uniform float red_amount : hint_range(0.0, 2.0) = 1.0;
uniform float green_amount : hint_range(0.0, 2.0) = 1.0;
uniform float blue_amount : hint_range(0.0, 2.0) = 1.0;

uniform float saturation : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 1.0) = 1.0;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

uniform vec4 pop_tint : source_color = vec4(0.0, 0.0, 0.0, 0.0);

// --- VIGNETTE SETTINGS (New) ---
// Set intensity to 0.0 to disable it completely
uniform float vignette_intensity : hint_range(0.0, 5.0) = 0.0;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	// distortion Logic
	vec2 noise_uv = UV + vec2(0.0, -TIME * speed);
	float noise = texture(noise_texture, noise_uv).r;
	vec2 distorted_uv = SCREEN_UV + (vec2(noise) - 0.5) * distortion_strength;
	vec4 screen_color = texture(screen_texture, distorted_uv);

	// RGB adjustments
	screen_color.r *= red_amount;
	screen_color.g *= green_amount;
	screen_color.b *= blue_amount;

	// saturation
	float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
	screen_color.rgb = mix(vec3(gray), screen_color.rgb, saturation);

	// Contrast & Brightness
	screen_color.rgb = (screen_color.rgb - 0.5) * contrast + 0.5;
	screen_color.rgb *= brightness;

	// Tint
	screen_color.rgb = mix(screen_color.rgb, pop_tint.rgb, pop_tint.a);

	// Vignette 
	// use UV (0 to 1) so the vignette stays centered on the screen/quad
	float dist = distance(UV, vec2(0.5));
	// 1.0 becomes transparent center, 0.0 becomes dark corners
	float vignette = 1.0 - smoothstep(0.5, 1.5 - vignette_softness, dist * vignette_intensity);
	screen_color.rgb *= vignette;

	COLOR = screen_color;
}