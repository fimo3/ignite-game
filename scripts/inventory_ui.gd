extends Container

@export var slot_scene: PackedScene = preload("res://scenes/inventory_slot.tscn")
@export var item_icons: Dictionary = {
	"fruit": preload("res://textures/fruit1.png"),
	"mushroom": preload("res://textures/Mushroom_2.png"),
	# mutant_fruit reuses the fruit texture but the slot color will be tinted purple
	# Replace with a dedicated texture once one is available
	"mutant_fruit": preload("res://textures/fruit1.png")
}

const SELL_PRICES = {
	"fruit": 5,
	"mushroom": 10,
	"mutant_fruit": 20
}

const MUSHROOM_COST := 15

# References to sibling nodes inside ShopPanel/VBox
@onready var balance_label: Label = $"../Shop/Panel/VBox/BalanceLabel"
@onready var buy_mushroom_btn: Button = $"../Shop/Panel/VBox/MushroomRow/BuyButton"

func _ready() -> void:
	Inventory.inventory_changed.connect(_on_inventory_changed)
	Bank.balance_changed.connect(_on_balance_changed)
	buy_mushroom_btn.pressed.connect(_on_buy_mushroom)
	_on_inventory_changed()
	_on_balance_changed(Bank.balance)

func _on_balance_changed(new_balance: int) -> void:
	balance_label.text = "$" + str(new_balance)
	buy_mushroom_btn.disabled = not Bank.can_afford(MUSHROOM_COST)

func _on_inventory_changed() -> void:
	for child in get_children():
		child.queue_free()
	for item_name in Inventory.items:
		var count := Inventory.get_count(item_name)
		if count <= 0:
			continue
		var slot = slot_scene.instantiate()
		add_child(slot)
		var sell_price: int = SELL_PRICES.get(item_name, 1)
		slot.setup(item_name, count, item_icons.get(item_name, null), sell_price)
		# Tint mutant fruit slots so they're visually distinct
		if item_name == "mutant_fruit":
			slot.modulate = Color(0.85, 0.4, 1.0)
		var sell_btn: Button = slot.get_node_or_null("Button")
		if sell_btn:
			sell_btn.pressed.connect(_on_sell_pressed.bind(item_name))

func _on_sell_pressed(item_name: String) -> void:
	Inventory.sell_item(item_name, 1)

func _on_buy_mushroom() -> void:
	if Bank.withdraw(MUSHROOM_COST):
		Inventory.add_item("mushroom")
