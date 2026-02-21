extends Sprite2D

@export var speedRadPerSec := 1.0
@export var radius := 217
@export var variation := 20
@onready var camera := $"../CameraNode/Camera2D"

var items: Array = []
var index_by_id: Dictionary = {}
var counter :int = 1

func _norm_angle(theta: float) -> float:
	var t := fmod(theta, TAU)
	if t < 0.0:
		t += TAU
	return t

func _lower_bound(theta: float) -> int:
	var lo := 0
	var hi := items.size()
	while lo < hi:
		var mid := (lo + hi) >> 1
		if items[mid]["theta"] < theta:
			lo = mid + 1
		else:
			hi = mid
	return lo

func _reindex_from(start_idx: int) -> void:
	for i in range(start_idx, items.size()):
		index_by_id[items[i]["id"]] = i

func _place_node_world_locked(node: Node2D, theta_world: float) -> void:
	var r := radius + randf() * variation
	var target_global := global_position + Vector2.from_angle(theta_world) * r
	node.global_position = target_global
	node.global_rotation = (target_global - global_position).angle() + PI * 0.5

func _insert_entry(id: int, node: Node2D) -> void:
	var t_local := _norm_angle(node.position.angle())
	var idx := _lower_bound(t_local)
	items.insert(idx, { "id": id, "theta": t_local, "node": node })
	_reindex_from(idx)

func add_item(id: int, theta_world: float, scene: PackedScene) -> Node2D:
	counter += 1
	if index_by_id.has(id):
		update_item_angle(id, theta_world)
		return items[index_by_id[id]]["node"]

	var plant: Node2D = scene.instantiate()
	add_child(plant)
	_place_node_world_locked(plant, theta_world)
	_insert_entry(id, plant)
	return plant

func remove_item(id: int) -> void:
	if not index_by_id.has(id):
		return

	var idx: int = index_by_id[id]
	var node: Node2D = items[idx]["node"]
	items.remove_at(idx)
	index_by_id.erase(id)
	_reindex_from(idx)

	if is_instance_valid(node):
		node.queue_free()

func update_item_angle(id: int, theta_world: float) -> void:
	if not index_by_id.has(id):
		return

	var idx: int = index_by_id[id]
	var entry = items[idx]
	var node: Node2D = entry["node"]
	if not is_instance_valid(node):
		remove_item(id)
		return

	items.remove_at(idx)
	index_by_id.erase(id)
	_reindex_from(idx)

	_place_node_world_locked(node, theta_world)
	_insert_entry(id, node)

func get_in_angle_range(a0_world: float, a1_world: float) -> Array:
	if items.is_empty():
		return []

	var t0 := _norm_angle(a0_world - global_rotation)
	var t1 := _norm_angle(a1_world - global_rotation)

	if is_equal_approx(t0, t1):
		return []

	if t0 < t1:
		var i0 := _lower_bound(t0)
		var i1 := _lower_bound(t1)
		return items.slice(i0, i1)

	var i0w := _lower_bound(t0)
	var i1w := _lower_bound(t1)
	var out: Array = []
	out.append_array(items.slice(i0w, items.size()))
	out.append_array(items.slice(0, i1w))
	return out

func _ready() -> void:
	pass # Replace with function body. 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transform = transform.rotated(delta * speedRadPerSec / camera.zoom.x)
	pass
