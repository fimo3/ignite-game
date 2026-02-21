extends Node2D

@export var scene: PackedScene
@export var crater: PackedScene
@export var explosiontree: PackedScene
@export var spawn_distance := 200.0
@export var parent_to_spawn_under: NodePath
@onready var cameraShaker := $"../../CameraNode/Camera2D"
@onready var bang := $"../../FX/Flash"
@onready var planet = $"../"

func _ready() -> void:
	randomize()

func spawn_random() -> void:
	var angle := randf() * TAU
	var pos := Vector2(cos(angle), sin(angle)) * spawn_distance
	spawn(pos)

func spawn(pos: Vector2):
	if scene == null:
		return
	var asteroid :Node2D = planet.add_item(planet.counter, pos.angle(), scene)
	asteroid.global_position = pos
	
	cameraShaker.start_shake_ramp(2.5, 0.15, 0.7)
	await get_tree().create_timer(1.8).timeout
	bang.flashbang(0.2, 0.5, 1.5)
	await get_tree().create_timer(1).timeout
	if asteroid != null:
		asteroid.queue_free()
	cameraShaker.start_shake_ramp(0, 0, 0)
	
	for e in planet.get_in_angle_range(pos.angle() - PI/8, pos.angle() + PI/8):
		if e["node"] != null:
			if randf() > 0.8:
				planet.add_item(planet.counter, e["node"].global_position.angle(), explosiontree)
			planet.remove_item(e["id"])
	var crater = planet.add_item(planet.counter, pos.angle(), crater)
	await get_tree().create_timer(5).timeout
	if crater != null:
		crater.queue_free()
