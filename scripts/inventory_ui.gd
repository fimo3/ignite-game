extends Container

@export var slot_scene : PackedScene = preload("res://scenes/inventory_slot.tscn")
@export var item_icons : Dictionary = {
	"fruit": preload("res://textures/fruit1.png"),
	"mushroom": preload("res://textures/Mushroom_1.png")
}

func _ready():
	Inventory.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed()

func _on_inventory_changed():
	for child in get_children():
		child.queue_free()
	for item_name in Inventory.items:
		var count = Inventory.get_count(item_name)
		if count <= 0:
			continue
		var slot = slot_scene.instantiate()
		add_child(slot)
		slot.setup(item_name, count, item_icons.get(item_name, null), 1)
