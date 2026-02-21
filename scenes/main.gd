extends Node2D

@onready var spawner = $Planet/AsteroidSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var sum := 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sum += delta;
	
	if sum > 30:
		sum = 0;
		spawner.spawn_random()
