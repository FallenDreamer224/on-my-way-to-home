class_name ObjectiveDefinition
extends Resource
## Authored objective text plus one observable completion condition.
## Conditions read facts that existing systems already own; see ObjectiveTracker.

@export var objective_id: StringName
@export var title: String
@export_multiline var guidance: String
@export var optional: bool = false
## One of ObjectiveTracker.CONDITIONS.
@export var condition: StringName
## Item, activity or event identifier the condition refers to.
@export var subject: StringName
@export_range(1, 999) var required: int = 1


func is_valid_definition() -> bool:
	return (not String(objective_id).strip_edges().is_empty() and not title.strip_edges().is_empty()
		and condition in ObjectiveTracker.CONDITIONS and required > 0)
