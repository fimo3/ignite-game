extends StaticBody2D
enum TreeType {
	GREEN,
	RED,
	BLUE,
	BROWN,
	YELLOW
}
@export var id : TreeType = TreeType.GREEN
@export var max_depth : int = 4
@export var initial_length : float = 900.0
@export var length_decay : float = 0.7
@export var branch_split_chance : float = 0.9
@export var angle_variation : float = 60
@export var thickness_start : float = 1.0
@export var thickness_decay : float = 0.7
@export var seed : int = 0
@export var branch_textures : Array[Texture2D] = [
	preload("res://textures/stem_fern1.png"),
	preload("res://textures/stem_fern2.png"),
	preload("res://textures/stem_fern3.png")
]
@export var leaf_texture : Texture2D = preload("res://textures/fern_leaf.png")
@export var fruit_scene : PackedScene = preload("res://scenes/fruit.tscn")
@export var fruit_chance : float = 0.6
@onready var branch_container = $BranchContainer
var rng := RandomNumberGenerator.new()
var tree_color : Color

func _ready():
	setup_rng()
	setup_tree_color()
	generate_tree()

func setup_rng():
	if seed == 0:
		rng.randomize()
	else:
		rng.seed = seed

func setup_tree_color():
	match id:
		TreeType.GREEN:
			tree_color = Color(0.0, 0.697, 0.328)
		TreeType.RED:
			tree_color = Color(1.0, 0.486, 0.417)
		TreeType.BLUE:
			tree_color = Color(0.6, 0.0, 1.0)
		TreeType.BROWN:
			tree_color = Color(0.424, 0.243, 0.0)
		TreeType.YELLOW:
			tree_color = Color(0.996, 0.776, 0.0)

func generate_tree():
	for c in branch_container.get_children():
		c.queue_free()
	grow_branch(Vector2.ZERO, Vector2.UP, initial_length, thickness_start, 0)

func grow_branch(start_pos: Vector2, direction: Vector2, length: float, thickness: float, depth: int):
	if depth > max_depth:
		create_tip(start_pos, direction, length, thickness)
		return
	var end_pos = start_pos + direction * length
	create_branch_sprite(start_pos, end_pos, thickness, depth)
	var is_dead_end = rng.randf() < 0.15 and depth > 1
	var child_count = 1
	if rng.randf() < branch_split_chance:
		child_count = 2
	var spawn_pos = end_pos - direction * 100
	if is_dead_end:
		create_joint_sprite(spawn_pos, direction, length, thickness)
		create_tip(end_pos, direction, length, thickness)
		return
	create_joint_sprite(spawn_pos, direction, length, thickness)
	for i in range(child_count):
		var angle_offset = deg_to_rad(rng.randf_range(-angle_variation, angle_variation))
		var new_direction = direction.rotated(angle_offset)
		grow_branch(spawn_pos, new_direction, length * length_decay, thickness * thickness_decay, depth + 1)

func create_branch_sprite(start_pos: Vector2, end_pos: Vector2, thickness: float, depth: int):
	if branch_textures.is_empty():
		return
	var texture = branch_textures[rng.randi() % branch_textures.size()]
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = start_pos.lerp(end_pos, 0.5)
	var dir = end_pos - start_pos
	sprite.rotation = dir.angle()
	var length = dir.length()
	sprite.scale.x = length / texture.get_width()
	sprite.scale.y = thickness
	sprite.modulate = tree_color.darkened(depth * 0.05)
	branch_container.add_child(sprite)

func create_joint_sprite(pos: Vector2, direction: Vector2, length: float, thickness: float):
	if leaf_texture == null:
		return
	var sprite = Sprite2D.new()
	sprite.texture = leaf_texture
	sprite.position = pos
	sprite.rotation = direction.angle()
	sprite.scale.x = length / leaf_texture.get_width()
	sprite.scale.y = thickness
	sprite.modulate = tree_color
	branch_container.add_child(sprite)

func create_tip(pos: Vector2, direction: Vector2, length: float, thickness: float):
	if rng.randf() < fruit_chance:
		create_fruit(pos)
	else:
		create_leaf_tip(pos, direction, length, thickness)

func create_fruit(pos: Vector2):
	if fruit_scene == null:
		return
	var fruit = fruit_scene.instantiate()
	fruit.position = pos
	branch_container.add_child(fruit)

func create_leaf_tip(pos: Vector2, direction: Vector2, length: float, thickness: float):
	if leaf_texture == null:
		return
	var sprite = Sprite2D.new()
	sprite.texture = leaf_texture
	sprite.position = pos
	sprite.rotation = direction.angle()
	sprite.scale.x = length / leaf_texture.get_width()
	sprite.scale.y = thickness
	sprite.modulate = tree_color
	branch_container.add_child(sprite)
