extends CanvasLayer

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_start_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_button_up() -> void:
	get_tree().quit()
