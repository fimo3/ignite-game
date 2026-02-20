extends ColorRect

@onready var mat := material as ShaderMaterial

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mat.set_shader_parameter("progress", 0.0)
	mat.set_shader_parameter("alpha", 0.0)

func flashbang(wipe_in := 0.5, hold := 0.5, fade_out := 1.5) -> void:
	visible = true
	mat.set_shader_parameter("progress", 0.0)
	mat.set_shader_parameter("alpha", 0.0)

	var tw := create_tween()
	tw.tween_property(mat, "shader_parameter/progress", 1.0, wipe_in)
	tw.tween_property(mat, "shader_parameter/alpha", 1.0, wipe_in)
	tw.tween_interval(hold)
	tw.tween_property(mat, "shader_parameter/alpha", 0.0, fade_out)

	await tw.finished
	visible = false
