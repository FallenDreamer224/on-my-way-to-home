class_name RuntimeInventory
extends Node
## Partial additions/removals return the exact accepted quantity; zero means no mutation.

signal changed
@export_range(0, 200) var slot_capacity: int = 20
@export var definitions: Array[ItemDefinition] = []
var _catalog: Dictionary[StringName, ItemDefinition] = {}
var _slots: Array[Dictionary] = []


func _ready() -> void:
	for item: ItemDefinition in definitions:
		register_definition(item)
	for index: int in maxi(0, slot_capacity):
		_slots.append({"item_id": &"", "quantity": 0})


func register_definition(item: Variant) -> bool:
	if not is_instance_valid(item) or not item is ItemDefinition or not item.is_valid_definition() or _catalog.has(item.item_id):
		return false
	_catalog[item.item_id] = item
	return true


func definition(item_id: StringName) -> ItemDefinition:
	return _catalog.get(item_id)


func slot_count() -> int:
	return _slots.size()


func slot_snapshot(index: int) -> Dictionary:
	return _slots[index].duplicate() if index >= 0 and index < _slots.size() else {}


func free_slot_count() -> int:
	var result: int = 0
	for slot: Dictionary in _slots:
		if slot.quantity == 0:
			result += 1
	return result


func get_quantity(item_id: StringName) -> int:
	var result: int = 0
	for slot: Dictionary in _slots:
		if slot.item_id == item_id:
			result += slot.quantity
	return result


func available_quantity_capacity(item_id: StringName) -> int:
	var item: ItemDefinition = definition(item_id)
	if item == null:
		return 0
	var result: int = 0
	for slot: Dictionary in _slots:
		if slot.quantity == 0:
			result += item.stack_limit()
		elif slot.item_id == item_id:
			result += maxi(0, item.stack_limit() - slot.quantity)
	return result


func add_items(item_id: StringName, quantity: int) -> int:
	var item: ItemDefinition = definition(item_id)
	if item == null or quantity <= 0:
		return 0
	var remaining: int = quantity
	# Fill matching stacks first, then empty slots. Slot order is stable.
	for empty_pass: bool in [false, true]:
		for slot: Dictionary in _slots:
			if (slot.quantity == 0) != empty_pass:
				continue
			if slot.quantity > 0 and slot.item_id != item_id:
				continue
			var accepted: int = mini(remaining, maxi(0, item.stack_limit() - slot.quantity))
			if accepted > 0:
				slot.item_id = item_id
				slot.quantity += accepted
				remaining -= accepted
			if remaining == 0:
				break
		if remaining == 0:
			break
	if remaining != quantity:
		changed.emit()
	return quantity - remaining


func remove_items(item_id: StringName, quantity: int) -> int:
	if definition(item_id) == null or quantity <= 0:
		return 0
	var remaining: int = quantity
	for slot: Dictionary in _slots:
		if slot.item_id != item_id:
			continue
		var removed: int = mini(remaining, slot.quantity)
		slot.quantity -= removed
		remaining -= removed
		if slot.quantity == 0:
			slot.item_id = &""
		if remaining == 0:
			break
	if remaining != quantity:
		changed.emit()
	return quantity - remaining
