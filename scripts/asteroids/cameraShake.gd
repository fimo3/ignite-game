extends Camera2D

@export var max_offset := 30.0
@export var max_rotation := 0.08

var _trauma := 0.0
var _ramping := false

func start_shake_ramp(duration: float, start_strength := 0.15, end_strength := 1.0) -> void:
	if _ramping:
		return
	_ramping = true
	_shake_ramp(duration, start_strength, end_strength)

func stop_shake() -> void:
	_ramping = false
	_trauma = 0.0
	offset = Vector2.ZERO
	rotation = 0.0

func _process(delta: float) -> void:
	var t := _trauma * _trauma
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * max_offset * t
	rotation = randf_range(-1.0, 1.0) * max_rotation * t

func _shake_ramp(duration: float, start_strength: float, end_strength: float) -> void:
	var time := 0.0
	while _ramping and time < duration:
		var p := time / duration
		_trauma = clamp(lerp(start_strength, end_strength, p), 0.0, 1.0)
		if get_tree != null:
			await get_tree().process_frame
		time += get_process_delta_time()

	if _ramping:
		_trauma = clamp(end_strength, 0.0, 1.0)
	_ramping = false
