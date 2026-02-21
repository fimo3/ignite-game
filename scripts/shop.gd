extends Control

signal shop_closed

@onready var balance_label: Label = $Panel/VBox/BalanceLabel
@onready var close_button: Button = $Panel/VBox/CloseButton
@onready var mushroom_buy_button: Button = $Panel/VBox/MushroomRow/BuyButton
@onready var mushroom_cost_label: Label = $Panel/VBox/MushroomRow/CostLabel

const MUSHROOM_COST = 15

func _ready() -> void:
	Bank.balance_changed.connect(_on_balance_changed)
	mushroom_buy_button.pressed.connect(_on_buy_mushroom)
	_update_ui()

func _on_balance_changed(_new_balance: int) -> void:
	_update_ui()

func _update_ui() -> void:
	balance_label.text = "Balance: $" + str(Bank.balance)
	mushroom_buy_button.disabled = not Bank.can_afford(MUSHROOM_COST)

func _on_buy_mushroom() -> void:
	if Bank.withdraw(MUSHROOM_COST):
		Inventory.add_item("mushroom")
