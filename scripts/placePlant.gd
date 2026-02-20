extends Node2D

@export var plant_scene: PackedScene = preload("res://scenes/tree.tscn")
@onready var planet_sprite = $"../../Planet"

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var world_pos := get_global_mouse_position()
		spawn_plant(world_pos)

func spawn_plant(pos: Vector2):
	if plant_scene == null:
		return
	var plant := plant_scene.instantiate()
	var glpos :Vector2= pos.normalized() * (planet_sprite.radius + randf() * planet_sprite.variation)
	planet_sprite.add_child(plant)
	plant.global_position = glpos
	plant.global_rotation = glpos.angle() + PI/2

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
