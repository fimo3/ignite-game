extends Node2D
@export var plant_scene: PackedScene = preload("res://scenes/tree.tscn")
@export var mushroom_scene: PackedScene = preload("res://scenes/mushroom.tscn")
@onready var planet_sprite = $"../../Planet"
@onready var asteroid_spawner = $"../../Planet/AsteroidSpawner"
var spawned_trees: Array = []

func _unhandled_input(event):
	if Input.is_action_just_pressed("left click"):
		var world_pos := get_global_mouse_position()
		if len(planet_sprite.get_in_angle_range(world_pos.angle() - PI/32,world_pos.angle() + PI/32)) > 0:
			#print chikiq here for sounds.
			return
		# Check if we have a mushroom in inventory to place
		if Inventory.get_count("mushroom") > 0:
			spawn_mushroom(world_pos)
		else:
			spawn_plant(world_pos)
	if Input.is_action_just_pressed("asteroid spawn"):
		spawn_asteroid()
	if Input.is_action_just_pressed("shovel"):
		var world_pos := get_global_mouse_position()
		for e in planet_sprite.get_in_angle_range(world_pos.angle() - PI/32,world_pos.angle() + PI/32):
			planet_sprite.remove_item(e["id"])

func spawn_plant(pos: Vector2):
	if plant_scene == null:
		return
	planet_sprite.counter += 1
	var plant = planet_sprite.add_item(planet_sprite.counter, pos.angle(), plant_scene)
	if plant == null:
		return
	spawned_trees.append(plant)

func spawn_mushroom(pos: Vector2):
	if mushroom_scene == null:
		return
	# Consume from inventory
	Inventory.remove_item("mushroom", 1)
	planet_sprite.counter += 1
	var mush = planet_sprite.add_item(planet_sprite.counter, pos.angle(), mushroom_scene)
	if mush == null:
		return
	# Give the mushroom a reference to the planet
	if mush.has_method("_find_planet"):
		mush._find_planet()
	spawned_trees.append(mush)

func spawn_asteroid():
	asteroid_spawner.spawn_random()

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
