extends Node2D

@export var velocity := 200.0
@export var stop_distance := 200.0
@export var plants :Array[PackedScene] = []

func _physics_process(delta: float) -> void:
	var target := Vector2.ZERO
	var to_target := target - global_position
	var dist := to_target.length()

	if dist <= stop_distance:
		global_position = target
		set_physics_process(false)
		return

	var step := velocity * delta
	global_position += to_target / dist * min(step, dist)
