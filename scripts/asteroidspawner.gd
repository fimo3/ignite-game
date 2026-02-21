extends Node2D

@export var scene: PackedScene
@export var crater: PackedScene
@export var explosiontree: PackedScene
@export var mutant_tree_scene: PackedScene = preload("res://scenes/mutant_tree.tscn")
@export var spawn_distance := 200.0
@onready var cameraShaker := $"../../CameraNode/Camera2D"
@onready var bang := $"../../FX/Flash"
@onready var planet = $"../"

# Tree type -> color map (mirrors tree.gd TreeType colors)
const TREE_COLORS = {
	0: Color(0.0, 0.697, 0.328),   # GREEN
	1: Color(1.0, 0.486, 0.417),   # RED
	2: Color(0.6, 0.0, 1.0),       # BLUE
	3: Color(0.424, 0.243, 0.0),   # BROWN
	4: Color(0.996, 0.776, 0.0)    # YELLOW
}

func _ready() -> void:
	randomize()
	# Spawn one asteroid at startup like the original
	#spawn_random()
	
	

	

func spawn_random() -> void:
	var angle := randf() * TAU
	var pos := Vector2(cos(angle), sin(angle)) * spawn_distance
	spawn(pos)

func spawn_MASSIVE():
	var angle := randf() * TAU
	var pos := Vector2(cos(angle), sin(angle)) * spawn_distance
	
	if scene == null:
		return

	# Give this asteroid its own unique ID so concurrent spawns don't collide
	planet.counter += 1
	var asteroid_id: int = planet.counter

	# Instantiate and place the asteroid directly — don't use add_item so
	# we fully control the lifetime without double-free
	var asteroid: Node2D = scene.instantiate()
	planet.add_child(asteroid)
	asteroid.global_position = pos

	cameraShaker.start_shake_ramp(2.5, 0.15, 0.7)
	await get_tree().create_timer(1.8).timeout

	# Safety: node may have been freed if the scene reloaded
	if not is_instance_valid(asteroid):
		return

	bang.flashbang(0.2, 0.5, 1.5)
	#await get_tree().create_timer(0.3).timeout

	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://scenes/end.tscn")
	

func spawn(pos: Vector2) -> void:
	if scene == null:
		return

	# Give this asteroid its own unique ID so concurrent spawns don't collide
	planet.counter += 1
	var asteroid_id: int = planet.counter

	# Instantiate and place the asteroid directly — don't use add_item so
	# we fully control the lifetime without double-free
	var asteroid: Node2D = scene.instantiate()
	planet.add_child(asteroid)
	asteroid.global_position = pos

	cameraShaker.start_shake_ramp(2.5, 0.15, 0.7)
	await get_tree().create_timer(1.8).timeout

	# Safety: node may have been freed if the scene reloaded
	if not is_instance_valid(asteroid):
		return

	bang.flashbang(0.2, 0.5, 1.5)
	#await get_tree().create_timer(0.3).timeout

	if not is_instance_valid(asteroid):
		return

	# --- Gather trees in impact zone BEFORE destroying anything ---
	var impact_half_arc := PI / 8.0
	var entries_in_range: Array = planet.get_in_angle_range(
		pos.angle() - impact_half_arc,
		pos.angle() + impact_half_arc
	)

	# Snapshot IDs and colors now — the array will change as we remove items
	var ids_to_remove: Array[int] = []
	var parent_colors: Array[Color] = []
	var debris_angles: Array[float] = []

	for e in entries_in_range:
		var node = e["node"]
		ids_to_remove.append(e["id"])
		if is_instance_valid(node) and node.has_method("generate_tree"):
			var col := Color(0.0, 0.697, 0.328)
			if node.get("tree_color") != null and node.tree_color != Color():
				col = node.tree_color
			elif node.get("id") != null:
				col = TREE_COLORS.get(int(node.id), col)
			parent_colors.append(col)
			debris_angles.append(node.global_position.angle())

	# --- Remove the asteroid itself (just free it, it's not in planet.items) ---
	asteroid.queue_free()
	await get_tree().create_timer(1).timeout
	cameraShaker.start_shake_ramp(0, 0, 0)
	# --- Destroy all trees in range ---
	for id in ids_to_remove:
		planet.remove_item(id)

	# --- Debris explosion trees ---
	if explosiontree != null:
		for angle in debris_angles:
			if randf() > 0.8:
				planet.counter += 1
				planet.add_item(planet.counter, angle, explosiontree)

	# --- Place crater, remove it after a delay ---
	if crater != null:
		planet.counter += 1
		var crater_id : int = planet.counter
		planet.add_item(crater_id, pos.angle(), crater)
		await get_tree().create_timer(5.0).timeout
		planet.remove_item(crater_id)

	# --- Spawn mutant if 2+ trees were hit ---
	if parent_colors.size() >= 2:
		_spawn_mutant(pos, parent_colors[0], parent_colors[1])
	elif parent_colors.size() == 1 and randf() > 0.5:
		_spawn_mutant(pos, parent_colors[0], Color(randf(), randf(), randf()))

func _spawn_mutant(impact_pos: Vector2, color_a: Color, color_b: Color) -> void:
	if mutant_tree_scene == null:
		return

	# Instantiate and add to scene tree FIRST so _ready can access $BranchContainer
	var mutant: Node2D = mutant_tree_scene.instantiate()
	planet.add_child(mutant)

	# Position in planet-local space before calling init so _ready uses correct values
	var r : float= planet.radius + randf() * planet.variation
	var target_global : Vector2= planet.global_position + Vector2.from_angle(impact_pos.angle()) * r
	mutant.global_position = target_global
	mutant.global_rotation = (target_global - planet.global_position).angle() + PI * 0.5

	# Now init (triggers generate_tree which needs BranchContainer to exist)
	if mutant.has_method("init_mutant"):
		mutant.init_mutant(color_a, color_b)

	# Register in planet tracking
	planet.counter += 1
	planet._insert_entry(planet.counter, mutant)
