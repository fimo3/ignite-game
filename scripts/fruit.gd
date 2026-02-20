extends Area2D

@onready var sprite = $Sprite

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	sprite.modulate = Color(0.0, 0.62, 0.0, 1.0)


func _on_mouse_exited() -> void:
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
