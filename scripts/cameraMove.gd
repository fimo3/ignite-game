extends Node2D
@export var pan_speed := 1.0
@export var zoom_step := 1.1
@export var min_zoom := 0.4
@export var max_zoom := 30.0
@export var cameraLimit = 4000
@onready var camera = $"../Camera2D"
@onready var parent = $".."
@onready var bg : Sprite2D = $"../BG"
@onready var bgplanets : Sprite2D = $"../../BGPlanet"
var _dragging := false
var _last_mouse_pos := Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	pass

func _zoom_at_mouse(factor: float):
	var viewport := get_viewport()
	var mouse_screen := viewport.get_mouse_position()
	var before := viewport.get_canvas_transform().affine_inverse() * mouse_screen
	var new_zoom : Vector2 = camera.zoom * factor
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	if new_zoom == camera.zoom:
		return
	camera.zoom = new_zoom
	bg.scale.x = .6 / new_zoom.x
	bg.scale.y = .6 / new_zoom.y
	var after := viewport.get_canvas_transform().affine_inverse() * mouse_screen
	global_position += (before - after)

func _unhandled_input(event):
	# --- Middle mouse drag panning ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_dragging = event.pressed
		if _dragging:
			_last_mouse_pos = get_viewport().get_mouse_position()

	if event is InputEventMouseMotion and _dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		var delta := mouse_pos - _last_mouse_pos
		_last_mouse_pos = mouse_pos
		parent.global_position -= delta * (1.0 / camera.zoom.x) * pan_speed
		bgplanets.global_position -= delta * (1.0 / camera.zoom.x) * pan_speed / 2.0
		if parent.global_position.length() >= cameraLimit:
			parent.global_position *= cameraLimit / parent.global_position.length()
		if bgplanets.global_position.length() >= cameraLimit / 2:
			bgplanets.global_position *= cameraLimit / (bgplanets.global_position.length() * 2)

	# --- Scroll wheel zoom ---
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_mouse(zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_mouse(1.0 / zoom_step)
