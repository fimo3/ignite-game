extends Node2D


@export var pan_speed := 1.0
@export var zoom_step := 1.1
@export var min_zoom := 0.4
@export var max_zoom := 30.0
@export var cameraLimit = 4000
@onready var camera = $"../Camera2D"
@onready var parent = $".."

var _dragging := false
var _last_mouse_pos := Vector2.ZERO



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _zoom_at_mouse(factor: float):
	var viewport := get_viewport()
	var mouse_screen := viewport.get_mouse_position()

	# World position under cursor BEFORE zoom
	var before := viewport.get_canvas_transform().affine_inverse() * mouse_screen

	var new_zoom :Vector2 = camera.zoom * factor
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)

	# If clamping prevented change, stop.
	if new_zoom == camera.zoom:
		return

	camera.zoom = new_zoom

	# World position under cursor AFTER zoom
	var after := viewport.get_canvas_transform().affine_inverse() * mouse_screen

	# Shift camera so the point under the mouse stays under the mouse
	global_position += (before - after)


func _unhandled_input(event):
	# --- RMB drag panning ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			_dragging = true
			_last_mouse_pos = get_viewport().get_mouse_position()
		else:
			_dragging = false

	if event is InputEventMouseMotion and _dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		var delta := mouse_pos - _last_mouse_pos
		_last_mouse_pos = mouse_pos

		# Move opposite to mouse drag, scaled by zoom so it feels consistent.
		parent.global_position -= delta * (1.0 / camera.zoom.x) * pan_speed
		if parent.global_position.length() >= cameraLimit:
			parent.global_position *= cameraLimit / parent.global_position.length()
	# --- Scroll wheel zoom (toward mouse cursor) ---
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_mouse(zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_mouse(1.0 / zoom_step)
