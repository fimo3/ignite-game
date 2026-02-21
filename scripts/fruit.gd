extends Area2D

@onready var sprite = $Sprite

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
func _input_event(_viewport, event, _shape_idx):
	if Input.is_action_just_pressed("right click"):
		Inventory.add_item("fruit")
		queue_free()
func _on_mouse_entered() -> void:
	sprite.modulate = Color(0.0, 0.62, 0.0, 1.0)

func _on_mouse_exited() -> void:
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
