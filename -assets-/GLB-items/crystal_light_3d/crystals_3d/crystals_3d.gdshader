shader_type spatial;

uniform sampler2D texture_albedo: hint_default_white;

uniform float metallic;
uniform float roughness: hint_range(0, 1);

uniform sampler2D texture_emission: hint_default_black;
uniform vec4 emission: source_color;
uniform float emission_energy;

uniform sampler2D texture_normal : hint_normal;

uniform float fresnel_power = 3.0;
uniform float fresnel_color_intensity = 1.0;
uniform vec4 fresnel_color: source_color;

uniform float fresnel_pulse_speed = 1.0;
uniform float emission_pulse_speed = 1.0;


void fragment() {
	ALBEDO = texture(texture_albedo, UV).rgb;

	METALLIC = metallic;
	ROUGHNESS = roughness;

	NORMAL_MAP = texture(texture_normal, UV).rgb;

	vec3 emission_tex = texture(texture_emission, UV).rgb;
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);

	float fresnel_time_factor = clamp(sin(TIME * fresnel_pulse_speed), 0.15, 1);
	float emission_time_factor = clamp(sin(TIME * emission_pulse_speed) + 0.33, 0.33, 1);
	EMISSION = ((emission.rgb * emission_tex) * emission_energy * emission_time_factor) + (fresnel * fresnel_color.rgb * fresnel_color_intensity * fresnel_time_factor);
}
