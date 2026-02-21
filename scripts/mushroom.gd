extends StaticBody2D

enum State { PLANTED, LAUNCHING, ORBITING }

@export var launch_speed := 600.0
@export var orbit_height := 280.0  # Distance from planet center
@export var orbit_speed := 1.2     # Radians per second

var state: State = State.PLANTED
var orbit_angle: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var planet_ref: Node2D = null

# Rocket flame particles (simple sprite child)
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
	state = State.LAUNCHING
	# Remove from planet's item tracking - find planet
	_find_planet()
	
	# Remove static collision so it doesn't block things
	$Collision.disabled = true if has_node("Collision") else null
	
	# Calculate launch direction (away from planet center)
	var dir: Vector2
	if planet_ref:
		dir = (global_position - planet_ref.global_position).normalized()
	else:
		dir = Vector2.UP
	
	velocity = dir * launch_speed
	
	# Show flame effect
	if flame:
		flame.visible = true

func _process(delta: float) -> void:
	match state:
		State.LAUNCHING:
			_process_launch(delta)
		State.ORBITING:
			_process_orbit(delta)

func _process_launch(delta: float) -> void:
	if not planet_ref:
		_find_planet()
		return
	
	global_position += velocity * delta
	# Slow down as we reach orbit height
	var dist = global_position.distance_to(planet_ref.global_position)
	if dist >= orbit_height:
		# Transition to orbit
		state = State.ORBITING
		# Set orbit angle based on current position relative to planet
		var rel = global_position - planet_ref.global_position
		orbit_angle = rel.angle()
		if flame:
			flame.visible = false

func _process_orbit(delta: float) -> void:
	if not planet_ref:
		return
	orbit_angle += orbit_speed * delta
	var orbit_pos = planet_ref.global_position + Vector2.from_angle(orbit_angle) * orbit_height
	global_position = orbit_pos
	# Face the direction of travel (tangent)
	rotation = orbit_angle + PI * 0.5

func _find_planet() -> void:
	# Walk up tree to find the planet sprite
	var node = get_parent()
	while node != null:
		if node.has_method("add_item"):
			planet_ref = node
			return
		node = node.get_parent()
	# Fallback: search from root
	planet_ref = get_tree().get_first_node_in_group("planet")
