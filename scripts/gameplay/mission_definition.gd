class_name MissionDefinition
extends Resource
## Ordered tutorial objectives and independent optional tasks for one mission card.

@export var mission_id: StringName
@export var title: String
@export_multiline var summary: String
@export var objectives: Array[ObjectiveDefinition] = []
@export var optional_tasks: Array[ObjectiveDefinition] = []


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if String(mission_id).strip_edges().is_empty() or title.strip_edges().is_empty():
		errors.append("Mission requires an identifier and title.")
	if objectives.is_empty():
		errors.append("Mission requires at least one objective.")
	var seen: Dictionary[StringName, bool] = {}
	for entry: ObjectiveDefinition in objectives + optional_tasks:
		if entry == null or not entry.is_valid_definition():
			errors.append("Invalid objective definition.")
			continue
		if seen.has(entry.objective_id):
			errors.append("Duplicate objective identifier: " + String(entry.objective_id))
		seen[entry.objective_id] = true
	for entry: ObjectiveDefinition in objectives:
		if entry != null and entry.optional:
			errors.append("Ordered objectives cannot be optional: " + String(entry.objective_id))
	return errors
