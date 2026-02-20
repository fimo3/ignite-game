shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float alpha : hint_range(0.0, 1.0) = 0.0;


void fragment() {
	vec3 color = vec3(
		1,
		0.5 + 0.5 * progress,
		progress
	);
	COLOR = vec4(color, alpha);
}
