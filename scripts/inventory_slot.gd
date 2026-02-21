extends Panel

@onready var icon : TextureRect = $TextureRect
@onready var label : Label = $Label
@onready var sellButton : Button = $Button

func setup(item_name: String, count: int, texture: Texture2D, cost: int):
	label.text = "x" + str(count)
	if texture != null:
		icon.texture = texture
	sellButton.text = "Sell for $" + str(cost)
