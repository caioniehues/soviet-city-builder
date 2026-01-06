shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 grid_color : source_color = vec4(0.4, 0.4, 0.4, 0.4);
uniform vec4 major_grid_color : source_color = vec4(0.6, 0.6, 0.6, 0.6);
uniform float grid_size : hint_range(0.1, 10.0) = 1.0;
uniform float line_thickness : hint_range(0.01, 0.2) = 0.03;
uniform float major_line_interval : hint_range(1.0, 20.0) = 10.0;
uniform float fade_distance : hint_range(10.0, 500.0) = 80.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Calculate grid coordinates
	vec2 grid_uv = world_position.xz / grid_size;

	// Distance from grid line (minor)
	vec2 grid_fract = abs(fract(grid_uv - 0.5) - 0.5);
	float line_minor = min(grid_fract.x, grid_fract.y);

	// Distance from major grid line
	vec2 major_uv = world_position.xz / (grid_size * major_line_interval);
	vec2 major_fract = abs(fract(major_uv - 0.5) - 0.5);
	float line_major = min(major_fract.x, major_fract.y);

	// Calculate alpha based on distance from camera
	float dist = length(world_position.xz);
	float fade = 1.0 - smoothstep(fade_distance * 0.5, fade_distance, dist);

	// Determine if on minor or major line
	float minor_alpha = 1.0 - smoothstep(0.0, line_thickness, line_minor);
	float major_alpha = 1.0 - smoothstep(0.0, line_thickness * 1.5, line_major);

	// Combine colors
	vec4 final_color = mix(grid_color, major_grid_color, major_alpha);
	float final_alpha = max(minor_alpha * grid_color.a, major_alpha * major_grid_color.a) * fade;

	// Discard fully transparent pixels
	if (final_alpha < 0.01) {
		discard;
	}

	ALBEDO = final_color.rgb;
	ALPHA = final_alpha;
}
