extends Node2D

@export var scene: PackedScene
@export var spawn_distance := 200.0
@export var parent_to_spawn_under: NodePath
@onready var cameraShaker := $"../CameraNode/Camera2D"
@onready var bang := $"../FX/Flash"

func _ready() -> void:
	randomize()
	spawn_random()

func spawn_random() -> void:
	var angle := randf() * TAU
	var pos := Vector2(cos(angle), sin(angle)) * spawn_distance
	spawn(pos)

func spawn(pos: Vector2):
	if scene == null:
		return
	var plant := scene.instantiate()
	add_child(plant)
	plant.global_position = pos
	plant.global_rotation = pos.angle() + PI/2
	cameraShaker.start_shake_ramp(2.0, 0.15, 1.0)
	await get_tree().create_timer(1).timeout
	bang.flashbang()
	await get_tree().create_timer(1).timeout
	plant.queue_free()
	cameraShaker.start_shake_ramp(0, 0, 0)
	
	
	
