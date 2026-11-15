extends SceneTree

const SAMPLE: ItemDefinition = preload("res://resources/items/lunar_sample.tres")
const SCRAP: ItemDefinition = preload("res://resources/items/metal_scrap.tres")
const PACK: ItemDefinition = preload("res://resources/items/supply_pack.tres")
var _checks: int = 0
var _failures: Array[String] = []
var _notifications: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for item: ItemDefinition in [SAMPLE, SCRAP, PACK]:
		_check(item.is_valid_definition() and not item.description.is_empty() and "development" in item.tags, "Valid authored development definition")
	_check(SAMPLE.maximum_stack == 10 and SCRAP.maximum_stack == 5 and not PACK.stackable, "Independent authored stack policies")
	var inventory: RuntimeInventory = RuntimeInventory.new()
	inventory.slot_capacity = 3
	inventory.definitions.assign([SAMPLE, SCRAP, PACK])
	root.add_child(inventory)
	inventory.changed.connect(func() -> void: _notifications += 1)
	_check(inventory.slot_count() == 3 and inventory.free_slot_count() == 3, "Empty configurable inventory")
	_check(inventory.available_quantity_capacity(SAMPLE.item_id) == 30, "Capacity in item units")
	_check(inventory.available_quantity_capacity(&"unknown") == 0 and inventory.get_quantity(&"unknown") == 0, "Unknown queries safe")
	var wrong_type: Node = Node.new()
	_check(not inventory.register_definition(null) and not inventory.register_definition(wrong_type), "Invalid item references rejected")
	wrong_type.free()
	_check(not inventory.register_definition(wrong_type), "Freed item reference rejected safely")
	var invalid: ItemDefinition = ItemDefinition.new()
	_check(not inventory.register_definition(invalid), "Blank definition rejected")
	invalid.item_id = &"invalid"
	invalid.display_name = "Invalid"
	invalid.maximum_stack = 0
	_check(not inventory.register_definition(invalid), "Invalid maximum stack rejected")
	_check(not inventory.register_definition(SAMPLE) and not inventory.register_definition(SAMPLE.duplicate()), "Duplicate identifiers rejected")
	for quantity: int in [0, -1, -999]:
		_check(inventory.add_items(SAMPLE.item_id, quantity) == 0 and inventory.remove_items(SAMPLE.item_id, quantity) == 0, "Nonpositive quantities cause no mutation")
	_check(inventory.add_items(&"unknown", 1) == 0 and inventory.remove_items(&"unknown", 1) == 0, "Unknown mutations safe")
	_check(_notifications == 0, "Invalid/no-op changes emit no UI refresh")
	_check(inventory.add_items(SAMPLE.item_id, 8) == 8 and _notifications == 1, "Add emits one transaction notification")
	_check(inventory.add_items(SAMPLE.item_id, 6) == 6, "Additional copies collected")
	_check(inventory.slot_snapshot(0).quantity == 10 and inventory.slot_snapshot(1).quantity == 4, "Fill existing stack then split overflow")
	_check(inventory.get_quantity(SAMPLE.item_id) == 14 and inventory.free_slot_count() == 1, "Quantities and occupied slots")
	var snapshot: Dictionary = inventory.slot_snapshot(0)
	snapshot.quantity = 999
	_check(inventory.get_quantity(SAMPLE.item_id) == 14, "External snapshot cannot mutate runtime quantities")
	_check(inventory.add_items(SCRAP.item_id, 7) == 5 and inventory.get_quantity(SCRAP.item_id) == 5, "Partial addition preserves exact accepted quantity")
	_check(inventory.free_slot_count() == 0 and inventory.available_quantity_capacity(SAMPLE.item_id) == 6, "Full slot count can retain matching stack capacity")
	var before: int = _notifications
	_check(inventory.add_items(PACK.item_id, 1) == 0 and _notifications == before, "Full inventory rejection without mutation")
	_check(inventory.add_items(SAMPLE.item_id, 100) == 6 and inventory.get_quantity(SAMPLE.item_id) == 20, "Full matching stacks enforce limits")
	_check(inventory.remove_items(SAMPLE.item_id, 11) == 11 and inventory.get_quantity(SAMPLE.item_id) == 9, "Removal across stacks")
	_check(inventory.free_slot_count() == 1, "Consumed stack frees slot")
	_check(inventory.remove_items(SAMPLE.item_id, 1000) == 9 and inventory.get_quantity(SAMPLE.item_id) == 0, "Over-removal returns only available quantity")
	_check(inventory.add_items(PACK.item_id, 3) == 2, "Nonstackable items occupy separate slots")
	for index: int in inventory.slot_count():
		var slot: Dictionary = inventory.slot_snapshot(index)
		_check(slot.quantity <= inventory.definition(slot.item_id).stack_limit(), "Every occupied slot respects its item limit")
	_check(inventory.slot_snapshot(-1).is_empty() and inventory.slot_snapshot(99).is_empty(), "Out-of-range slot snapshots safe")
	var empty: RuntimeInventory = RuntimeInventory.new()
	empty.slot_capacity = 0
	empty.definitions.assign([SAMPLE])
	root.add_child(empty)
	_check(empty.add_items(SAMPLE.item_id, 1) == 0 and empty.free_slot_count() == 0, "Zero-slot inventory handles full capacity")
	var independent: RuntimeInventory = RuntimeInventory.new()
	independent.definitions.assign([SAMPLE])
	root.add_child(independent)
	_check(independent.slot_count() == 20 and independent.get_quantity(SAMPLE.item_id) == 0, "Default 20 slots and independent runtime state")
	_check(ItemPlaceholder.texture(SAMPLE).get_size() == Vector2(32, 32), "Native 32 x 32 temporary inventory icon")
	_check(ItemPlaceholder.texture(SAMPLE) == ItemPlaceholder.texture(SAMPLE), "Temporary icons cached")
	inventory.free()
	empty.free()
	independent.free()
	_finish()


func _check(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures.append(label)


func _finish() -> void:
	if _failures.is_empty():
		print("PASS: %d inventory checks" % _checks)
		quit(0)
	else:
		for label: String in _failures:
			printerr("FAIL: " + label)
		quit(1)
