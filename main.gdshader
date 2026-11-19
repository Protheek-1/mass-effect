shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float scanline_amount: hint_range(0.0, 0.1) = 0.06;
uniform float scanline_spacing: hint_range(2.0, 8.0) = 4.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float swap_pulse : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5);
	float zoom = 1.0 - (swap_pulse * 0.015);
	vec2 warped_uv = center + (uv - center) * zoom;
	float aberration = swap_pulse * 0.006;
	float r = texture(screen_texture, warped_uv + vec2(aberration, 0.0)).r;
	float g = texture(screen_texture, warped_uv).g;
	float b = texture(screen_texture, warped_uv - vec2(aberration, 0.0)).b;
	vec3 col = vec3(r, g, b);
	float pixel_y = SCREEN_UV.y / SCREEN_PIXEL_SIZE.y;
	float scan = cos(pixel_y * 6.2831853 / scanline_spacing);
	float scanline = 1.0 - scanline_amount * (0.5 + 0.5 * scan);
	col *= scanline; 
	float dist = length((uv - center) * vec2(1.0, 0.85));
	float vignette = smoothstep(0.25, 0.85, dist);
	col *= 1.0 - vignette * vignette_intensity;
	COLOR = vec4(col, 1.0);
}
