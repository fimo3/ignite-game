extends Node

var items : Dictionary = {}

signal inventory_changed

# Item sell prices
const SELL_PRICES = {
	"fruit": 5,
	"mushroom": 10,
	"mutant_fruit": 20
}

func add_item(item_name: String, amount: int = 1):
	if items.has(item_name):
		items[item_name] += amount
	else:
		items[item_name] = amount
	emit_signal("inventory_changed")

func remove_item(item_name: String, amount: int = 1):
	if not items.has(item_name):
		return
	items[item_name] -= amount
	if items[item_name] <= 0:
		items.erase(item_name)
	emit_signal("inventory_changed")

func sell_item(item_name: String, amount: int = 1) -> bool:
	if get_count(item_name) < amount:
		return false
	var price = SELL_PRICES.get(item_name, 1) * amount
	remove_item(item_name, amount)
	Bank.deposit(price)
	return true

func get_count(item_name: String) -> int:
	return items.get(item_name, 0)
