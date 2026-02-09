shader_type spatial;
render_mode cull_disabled;

uniform vec4 out_color: source_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform float amount: hint_range(0.2, 5.0, 0.1) = 0.8;
uniform float speed: hint_range(0.1, 5.0, 0.1) = 1;
uniform float beer_factor = 0.2;
uniform float metallic = 0.6;
uniform float specular = 0.5;
uniform float roughness = 0.2;

// Added Emission from the comment
uniform vec3 emission: source_color = vec3(0.0, 0.0, 0.0);

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

float generateOffset(float x, float z, float val1, float val2, float time) {
	float radiansX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;
	
	return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time) {
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);
	
	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	VERTEX = applyDistortion(VERTEX, TIME * 0.1);
}

void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	ALBEDO = out_color.rgb;
	
	// Apply the requested emission to brighten the water
	EMISSION = emission;
	
	if (beer_factor != 0.0) {
		float depth_tex = texture(depth_texture, SCREEN_UV).r;
		
		// Use the safe backend-agnostic method
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_tex);
		vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		view.xyz /= view.w;
		
		float linear_scene_depth = -view.z;
		float linear_surface_depth = -VERTEX.z;
		float depth_diff = max(linear_scene_depth - linear_surface_depth, 0.0);

		ALPHA = clamp(1.0 - exp(-depth_diff * beer_factor), 0.0, 1.0);
	} else {
		ALPHA = out_color.a;
	}
}