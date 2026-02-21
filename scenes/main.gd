extends Node2D

@onready var spawner = $Planet/AsteroidSpawner
@export var val = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var sum : float= 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	sum += delta;
	
	if sum > 30.0:
		sum = -5 + randf() * 10;
		if(val >= 20):
			spawner.spawn_MASSIVE()
		else:
			spawner.spawn_random()
			val += 1
