class_name Interactable
extends Area2D
## Small native detection/availability/execution contract; no player-controller dependency.

@export var display_name: String = "Object"
@export var action_label: String = "Use"
@export var selection_id: String = ""
@export var available: bool = true


func is_available() -> bool:
	return available and is_inside_tree() and not is_queued_for_deletion() and can_process()


func execute(_inventory: RuntimeInventory) -> bool:
	return false


func result_message(success: bool) -> String:
	return "Collected" if success else "Inventory full or item unavailable"


func selection_key() -> String:
	return selection_id if not selection_id.is_empty() else String(get_path())
