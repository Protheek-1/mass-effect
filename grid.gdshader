shader_type canvas_item;

uniform float grid_spacing = 32;
uniform float line_width = 0.01;
uniform vec4 grid_color : source_color = vec4(0.05, 0.30, 0.35, 1.0);
void fragment() {
	vec2 grid = abs(
		mod(UV * vec2(1280.0, 720), grid_spacing)
		- grid_spacing * 0.5
	);
	float d = min(grid.x, grid.y);
float aa = fwidth(d);
float line = 1.0 - smoothstep(line_width - aa, line_width + aa, d);
	COLOR = vec4(grid_color.rgb, line * 0.7);
}