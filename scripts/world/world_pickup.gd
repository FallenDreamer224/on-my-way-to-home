class_name WorldPickup
extends Node2D
## Nonblocking pickup. Only accepted quantities leave the world.

const ITEM_APPEARANCES: Dictionary[StringName, PropAppearance] = {
	&"lunar_sample": preload("res://resources/props/lunar_sample.tres"),
	&"metal_scrap": preload("res://resources/props/metal_scrap.tres"),
	&"supply_pack": preload("res://resources/props/supply_pack.tres"),
}

@export var item: ItemDefinition
@export var quantity: int = 1
@export var pickup_id: String = ""
@export var appearance: PropAppearance
@onready var interaction: Interactable = $Interaction
@onready var visual: WorldProp = $Visual


func _ready() -> void:
	interaction.display_name = item.display_name if item != null else "Unavailable pickup"
	interaction.action_label = "Collect"
	interaction.selection_id = pickup_id
	# Resolve visuals separately from shared item definitions and runtime quantities.
	visual.appearance = appearance if appearance != null else ITEM_APPEARANCES.get(item.item_id) if item != null else null


func is_available() -> bool:
	return not is_queued_for_deletion() and quantity > 0 and item != null and item.is_valid_definition()


func collect(inventory: RuntimeInventory) -> int:
	if not is_available() or not is_instance_valid(inventory) or inventory.definition(item.item_id) != item:
		return 0
	var accepted: int = inventory.add_items(item.item_id, quantity)
	quantity -= accepted
	if accepted > 0 and quantity == 0:
		interaction.available = false
		queue_free()
	return accepted


