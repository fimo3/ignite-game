extends StaticBody2D

enum State { PLANTED, LAUNCHING, ORBITING }

@export var launch_speed := 300.0
@export var gravity := 0.2
@export var gravity_scale := 120.0 

var state: State = State.PLANTED
var velocity: Vector2 = Vector2.ZERO
var planet_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite
@onready var flame: Node2D = $Flame if has_node("Flame") else null

func _ready() -> void:
	pass

func _input_event(_viewport, event, _shape_idx):
	if state == State.PLANTED and Input.is_action_just_pressed("right click"):
		_launch()

func _on_mouse_entered() -> void:
	if state == State.PLANTED:
		modulate = Color(1.2, 1.2, 0.5, 1.0)

func _on_mouse_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func _launch() -> void:
	_find_planet()
	state = State.LAUNCHING

	var col := get_node_or_null("Collision")
	if col:
		col.disabled = true

	var dir: Vector2
	if planet_ref:
		dir = (global_position - planet_ref.global_position).normalized()
	else:
		dir = -global_position.normalized()

	var tangent := Vector2(-dir.y, dir.x)
	velocity = dir * launch_speed + tangent * launch_speed * 0.55

	if flame:
		flame.visible = true

	_unregister_from_planet()

func _process(delta: float) -> void:
	match state:
		State.LAUNCHING, State.ORBITING:
			_step_physics(delta)

func _step_physics(delta: float) -> void:
	if not planet_ref:
		_find_planet()
		return

	var to_planet: Vector2 = planet_ref.global_position - global_position
	var dist: float = to_planet.length()

	var grav_accel: float = gravity * gravity_scale           # px/s²
	var grav_dir: Vector2 = to_planet / dist if dist > 0.0 else Vector2.ZERO
	velocity += grav_dir * grav_accel * delta

	global_position += velocity * delta

	rotation = (global_position - planet_ref.global_position).angle() + PI * 0.5

	var planet_radius: float = planet_ref.get("radius") if planet_ref.get("radius") != null else 200.0
	if state == State.LAUNCHING and dist > planet_radius * 1.05:
		state = State.ORBITING
		if flame:
			flame.visible = false

func _find_planet() -> void:
	var node = get_parent()
	while node != null:
		if node.has_method("add_item"):
			planet_ref = node
			return
		node = node.get_parent()
	planet_ref = get_tree().get_first_node_in_group("planet")

func _unregister_from_planet() -> void:
	if planet_ref == null:
		return
	if not planet_ref.has_method("remove_item"):
		return
	var items = planet_ref.get("items")
	if items == null:
		return
	for entry in items:
		if entry.get("node") == self:
			planet_ref.remove_item(entry["id"])
			return
