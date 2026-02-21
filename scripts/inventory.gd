extends Node

var items : Dictionary = {}

signal inventory_changed

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

func get_count(item_name: String) -> int:
	return items.get(item_name, 0)
