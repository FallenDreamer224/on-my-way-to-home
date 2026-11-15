class_name ItemDefinition
extends Resource
## Authored shared definition. Runtime quantities live only in RuntimeInventory.

@export var item_id: StringName
@export var display_name: String
@export_multiline var description: String
@export var stackable: bool = true
@export_range(1, 9999) var maximum_stack: int = 10
@export var icon: Texture2D
@export var tags: PackedStringArray = []
@export var placeholder_color: Color = Color(0.6, 0.8, 0.85)


func is_valid_definition() -> bool:
	return not String(item_id).strip_edges().is_empty() and not display_name.strip_edges().is_empty() and maximum_stack > 0


func stack_limit() -> int:
	return maximum_stack if stackable else 1
