shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float grain_amount : hint_range(0.0, 0.3) = 0.09;
uniform float grain_size : hint_range(1.0, 6.0) = 2.0;
uniform float grain_speed : hint_range(0.0, 30.0) = 12.0;
uniform float vignette_intensity : hint_range(0.0, 6.0) = 0.98;
uniform float vignette_softness : hint_range(0.1, 1.0) = 0.65;
uniform float swap_pulse : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x *p.y);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5);
	vec2 dist_from_center = uv - center;
	float zoom = 1.0 - (swap_pulse * 0.015);
	vec2 warped_uv = center + dist_from_center * zoom;
	float aberration = swap_pulse * 0.006;
	float r = texture(screen_texture, warped_uv + vec2(aberration, 0.0)).r;
	float g = texture(screen_texture, warped_uv).g;
	float b = texture(screen_texture, warped_uv - vec2(aberration, 0.0)).b;
	vec3 col = vec3(r, g, b);
	vec2 grain_coord = floor(FRAGCOORD.xy / grain_size);
	float time_step = floor(TIME * grain_speed);
	float n = (hash(grain_coord + time_step) - 0.5);
	col *= 1.0 + (n * grain_amount * 2.0);
	float dist = length(dist_from_center);
	float vignette = smoothstep(vignette_softness, vignette_softness - 0.45, dist);
	col = mix(col * (1.0 - vignette_intensity), col, vignette);
	COLOR = vec4(col, 1.0);
}
