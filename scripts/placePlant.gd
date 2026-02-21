extends Node2D
@export var plant_scene: PackedScene = preload("res://scenes/tree.tscn")
@onready var planet_sprite = $"../../Planet"
@onready var asteroid_spawner = $"../../Planet/AsteroidSpawner"
var spawned_trees : Array = []

func _unhandled_input(event):
	if Input.is_action_just_pressed("left click"):
		var world_pos := get_global_mouse_position()
		spawn_plant(world_pos)
	if Input.is_action_just_pressed("asteroid spawn"):
		spawn_asteroid()

func spawn_plant(pos: Vector2):
	if plant_scene == null:
		return
	var plant := plant_scene.instantiate()
	var glpos : Vector2 = pos.normalized() * (planet_sprite.radius + randf() * planet_sprite.variation)
	planet_sprite.add_child(plant)
	plant.global_position = glpos
	plant.global_rotation = glpos.angle() + PI/2
	spawned_trees.append(plant)

func spawn_asteroid():
	asteroid_spawner.spawn_random()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
