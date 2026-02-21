extends Node2D

enum State { PLANTED, LAUNCHING }

@export var launch_speed := 30.0
@export var auto_launch_time := 10.0

var state: State = State.PLANTED
var launch_dir: Vector2 = Vector2.ZERO
var planet_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite
@onready var flame: Node2D = $Flame

func _ready() -> void:
	_find_planet()
	await get_tree().create_timer(auto_launch_time).timeout
	if state == State.PLANTED:
		_launch()

func _input_event(_viewport, event, _shape_idx):
	if state == State.PLANTED and Input.is_action_just_pressed("right click"):
		_launch()

func _on_mouse_entered() -> void:
	if state == State.PLANTED:
		sprite.modulate = Color(1.4, 1.4, 0.5)

func _on_mouse_exited() -> void:
	sprite.modulate = Color(1, 1, 1)

func _launch() -> void:
	if state != State.PLANTED:
		return
	state = State.LAUNCHING

	# Direction straight away from planet center
	if planet_ref:
		launch_dir = (global_position - planet_ref.global_position).normalized()
	else:
		launch_dir = Vector2.UP

	if flame:
		flame.visible = true

	_unregister_from_planet()

	# Reparent to scene root so planet rotation doesn't drag it along
	var scene_root := get_tree().current_scene
	var saved_pos := global_position
	var saved_rot := global_rotation
	get_parent().remove_child(self)
	scene_root.add_child(self)
	global_position = saved_pos
	global_rotation = saved_rot

func _process(delta: float) -> void:
	if state == State.LAUNCHING:
		global_position += launch_dir * launch_speed * delta

func _find_planet() -> void:
	var node := get_parent()
	while node != null:
		if node.has_method("add_item"):
			planet_ref = node
			return
		node = node.get_parent()
	planet_ref = get_tree().get_first_node_in_group("planet")

func _unregister_from_planet() -> void:
	if not is_instance_valid(planet_ref):
		return
	var items = planet_ref.get("items")
	if items == null:
		return
	for entry in items:
		if entry.get("node") == self:
			planet_ref.remove_item(entry["id"])
			return
