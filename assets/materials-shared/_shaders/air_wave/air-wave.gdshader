shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float max_radius = 5.0;
uniform float ring_thickness = 0.5;
uniform vec4 ring_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform float distortion_amount = 0.1;
uniform float inner_fade = 0.3;
uniform float outer_fade = 0.5;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 uv_centered = UV - center;
    float dist = length(uv_centered);
    
    // Current ring radius based on progress
    float current_radius = progress * 0.5;
    
    // Distance from ring edge
    float ring_edge_dist = abs(dist - current_radius);
    
    // Ring mask with thickness
    float ring_mask = 1.0 - smoothstep(0.0, ring_thickness / max_radius, ring_edge_dist);
    
    // Inner and outer fading
    float inner_alpha = smoothstep(current_radius - inner_fade * ring_thickness / max_radius, 
                                   current_radius, dist);
    float outer_alpha = 1.0 - smoothstep(current_radius, 
                                         current_radius + outer_fade * ring_thickness / max_radius, 
                                         dist);
    
    // Overall fade based on progress
    float fade = 1.0 - progress;
    
    // Distortion effect (wave ripple)
    float angle = atan(uv_centered.y, uv_centered.x);
    float wave = sin(angle * 8.0 + progress * 10.0) * distortion_amount;
    ring_mask *= (1.0 + wave);
    
    // Combine everything
    float alpha = ring_mask * inner_alpha * outer_alpha * fade * ring_color.a;
    
    ALBEDO = ring_color.rgb;
    ALPHA = alpha;
}