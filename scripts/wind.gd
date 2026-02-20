extends Sprite2D

@export var speedRadPerSec := 1.0
@export var radius := 217
@export var variation := 20
@onready var camera := $"../CameraNode/Camera2D"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transform = transform.rotated(delta * speedRadPerSec)
	pass
