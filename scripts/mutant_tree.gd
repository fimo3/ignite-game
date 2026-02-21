extends StaticBody2D

@export var fruitpos: Array[Vector2] = []
@export var max_depth: int = 4
@export var initial_length: float = 900.0
@export var length_decay: float = 0.7
@export var branch_split_chance: float = 0.9
@export var angle_variation: float = 60.0
@export var thickness_start: float = 1.0
@export var thickness_decay: float = 0.7
@export var seed: int = 0
@export var branch_textures: Array[Texture2D] = [
	preload("res://textures/stem_fern1.png"),
	preload("res://textures/stem_fern2.png"),
	preload("res://textures/stem_fern3.png")
]
@export var leaf_texture: Texture2D = preload("res://textures/fern_leaf.png")
@export var fruit_scene: PackedScene = preload("res://scenes/mutant_fruit.tscn")
@export var fruit_chance: float = 0.3

var mutant_color_a: Color = Color(0.0, 0.697, 0.328)
var mutant_color_b: Color = Color(1.0, 0.486, 0.417)
var tree_color: Color
var rng := RandomNumberGenerator.new()

# Called by the spawner AFTER add_child (so _ready has already run and
# BranchContainer exists). Blends parent colors, mutates params, regenerates.
func init_mutant(color_a: Color, color_b: Color, rng_seed: int = 0) -> void:
	mutant_color_a = color_a
	mutant_color_b = color_b

	var blend := randf_range(0.25, 0.75)
	var blended := mutant_color_a.lerp(mutant_color_b, blend)
	tree_color = Color.from_hsv(
		fmod(blended.h + randf_range(-0.08, 0.08), 1.0),
		clamp(blended.s + randf_range(-0.1, 0.1), 0.2, 1.0),
		clamp(blended.v + randf_range(-0.1, 0.1), 0.4, 1.0)
	)

	max_depth = clampi(max_depth + randi_range(-1, 1), 2, 6)
	branch_split_chance = clampf(branch_split_chance + randf_range(-0.15, 0.15), 0.4, 1.0)
	angle_variation = clampf(angle_variation + randf_range(-15.0, 15.0), 20.0, 90.0)
	fruit_chance = clampf(fruit_chance + randf_range(-0.1, 0.2), 0.0, 0.8)

	if rng_seed != 0:
		seed = rng_seed
		rng.seed = seed

	# Regenerate with the blended mutant colors
	generate_tree()

func _ready() -> void:
	if seed == 0:
		rng.randomize()
		seed = rng.randi()
	rng.seed = seed
	# Default purple until init_mutant is called by the spawner
	tree_color = Color(0.8, 0.2, 0.8)
	generate_tree()

func generate_tree() -> void:
	var bc := $BranchContainer
	for c in bc.get_children():
		c.queue_free()
	grow_branch(Vector2.ZERO, Vector2.UP, initial_length, thickness_start, 0)

func grow_branch(start_pos: Vector2, direction: Vector2, length: float, thickness: float, depth: int) -> void:
	if depth > max_depth:
		create_tip(start_pos, direction, length, thickness)
		return
	var end_pos := start_pos + direction * length
	create_branch_sprite(start_pos, end_pos, thickness, depth)
	var is_dead_end := rng.randf() < 0.15 and depth > 1
	var child_count := 1
	if rng.randf() < branch_split_chance:
		child_count = 2
	var spawn_pos := end_pos - direction * 100.0
	if is_dead_end:
		create_joint_sprite(spawn_pos, direction, length, thickness)
		create_tip(end_pos, direction, length, thickness)
		return
	create_joint_sprite(spawn_pos, direction, length, thickness)
	for i in range(child_count):
		var angle_offset := deg_to_rad(rng.randf_range(-angle_variation, angle_variation))
		var new_direction := direction.rotated(angle_offset)
		grow_branch(spawn_pos, new_direction, length * length_decay, thickness * thickness_decay, depth + 1)

func create_branch_sprite(start_pos: Vector2, end_pos: Vector2, thickness: float, depth: int) -> void:
	if branch_textures.is_empty():
		return
	var texture := branch_textures[rng.randi() % branch_textures.size()]
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = start_pos.lerp(end_pos, 0.5)
	var dir := end_pos - start_pos
	sprite.rotation = dir.angle()
	sprite.scale.x = dir.length() / texture.get_width()
	sprite.scale.y = thickness
	sprite.z_as_relative = false
	sprite.z_index = 0
	sprite.modulate = tree_color.darkened(depth * 0.05)
	$BranchContainer.add_child(sprite)

func create_joint_sprite(pos: Vector2, direction: Vector2, length: float, thickness: float) -> void:
	if leaf_texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = leaf_texture
	sprite.position = pos
	sprite.rotation = direction.angle()
	sprite.scale.x = length / leaf_texture.get_width()
	sprite.scale.y = thickness
	sprite.modulate = tree_color
	$BranchContainer.add_child(sprite)

func create_tip(pos: Vector2, direction: Vector2, length: float, thickness: float) -> void:
	if rng.randf() < fruit_chance:
		create_fruit(pos)
	else:
		create_leaf_tip(pos, direction, length, thickness)

func create_fruit(pos: Vector2) -> void:
	var fruit := fruit_scene.instantiate()
	fruit.position = pos
	$BranchContainer.add_child(fruit)
	if fruit.has_method("set_color"):
		fruit.set_color(tree_color)
	fruitpos.append(fruit.global_position)

func create_leaf_tip(pos: Vector2, direction: Vector2, length: float, thickness: float) -> void:
	if leaf_texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = leaf_texture
	sprite.position = pos
	sprite.rotation = direction.angle()
	sprite.scale.x = length / leaf_texture.get_width()
	sprite.scale.y = thickness
	sprite.modulate = tree_color
	sprite.z_as_relative = false
	sprite.z_index = 10
	$BranchContainer.add_child(sprite)
