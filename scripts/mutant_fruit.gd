extends Area2D

@onready var sprite: Sprite2D = $Sprite
@onready var light: PointLight2D = $PointLight2D

var fruit_color: Color = Color(0.8, 0.2, 0.8)

func _ready() -> void:
	_apply_color()

func set_color(c: Color) -> void:
	fruit_color = c
	if is_node_ready():
		_apply_color()

func _apply_color() -> void:
	sprite.modulate = fruit_color
	# Tint the glow light to match
	light.color = fruit_color

func _input_event(_viewport, event, _shape_idx):
	if Input.is_action_just_pressed("right click"):
		Inventory.add_item("mutant_fruit")
		queue_free()

func _on_mouse_entered() -> void:
	sprite.modulate = fruit_color.lightened(0.4)

func _on_mouse_exited() -> void:
	sprite.modulate = fruit_color
