extends Node

signal balance_changed(new_balance: int)

var balance: int = 100  # Starting money

func deposit(amount: int) -> void:
	balance += amount
	emit_signal("balance_changed", balance)

func withdraw(amount: int) -> bool:
	if balance < amount:
		return false
	balance -= amount
	emit_signal("balance_changed", balance)
	return true

func can_afford(amount: int) -> bool:
	return balance >= amount
