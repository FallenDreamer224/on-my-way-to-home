class_name ObjectiveTracker
extends Node
## Presentation adapter for tutorial objectives. It observes facts owned by the inventory,
## habitat director and daily-life log; it never grants rewards, gates systems or stores progress
## anywhere else. A full mission/campaign controller remains future work.

signal objective_completed(definition: ObjectiveDefinition)
signal mission_completed
signal changed

const CONDITIONS: Array[StringName] = [&"has_item", &"inside_habitat", &"activity_completed", &"event"]

var mission: MissionDefinition
var inventory: RuntimeInventory
var director: HabitatDirector
var daily: DailyLife
var completed: Dictionary[StringName, bool] = {}
var mission_complete: bool = false
var _events: Dictionary[StringName, int] = {}


func configure(definition: MissionDefinition, items: RuntimeInventory, habitat: HabitatDirector, routines: DailyLife) -> bool:
	if definition == null or not definition.validation_errors().is_empty():
		return false
	mission = definition
	inventory = items
	director = habitat
	daily = routines
	completed.clear()
	_events.clear()
	mission_complete = false
	if is_instance_valid(inventory):
		inventory.changed.connect(evaluate)
	if is_instance_valid(director):
		director.location_changed.connect(func(_location: StringName) -> void: evaluate())
	if is_instance_valid(daily):
		daily.changed.connect(evaluate)
	evaluate()
	return true


## Records a one-off presentation event such as opening the inventory.
func note_event(event: StringName) -> void:
	_events[event] = int(_events.get(event, 0)) + 1
	evaluate()


func is_complete(objective_id: StringName) -> bool:
	return completed.get(objective_id, false)


func active_objective() -> ObjectiveDefinition:
	if mission == null:
		return null
	for entry: ObjectiveDefinition in mission.objectives:
		if not is_complete(entry.objective_id):
			return entry
	return null


func progress() -> Vector2i:
	if mission == null:
		return Vector2i.ZERO
	var done: int = 0
	for entry: ObjectiveDefinition in mission.objectives:
		if is_complete(entry.objective_id):
			done += 1
	return Vector2i(done, mission.objectives.size())


func optional_progress() -> Vector2i:
	if mission == null:
		return Vector2i.ZERO
	var done: int = 0
	for entry: ObjectiveDefinition in mission.optional_tasks:
		if is_complete(entry.objective_id):
			done += 1
	return Vector2i(done, mission.optional_tasks.size())


func evaluate() -> void:
	if mission == null:
		return
	var updated: bool = false
	# Ordered objectives complete one at a time; a fact that already holds cascades at once.
	for entry: ObjectiveDefinition in mission.objectives:
		if is_complete(entry.objective_id):
			continue
		if not _satisfied(entry):
			break
		completed[entry.objective_id] = true
		updated = true
		objective_completed.emit(entry)
	for entry: ObjectiveDefinition in mission.optional_tasks:
		if not is_complete(entry.objective_id) and _satisfied(entry):
			completed[entry.objective_id] = true
			updated = true
			objective_completed.emit(entry)
	if not mission_complete and active_objective() == null:
		mission_complete = true
		updated = true
		mission_completed.emit()
	if updated:
		changed.emit()


func _satisfied(entry: ObjectiveDefinition) -> bool:
	match entry.condition:
		&"has_item":
			return is_instance_valid(inventory) and inventory.get_quantity(entry.subject) >= entry.required
		&"inside_habitat":
			return is_instance_valid(director) and director.location not in [&"outside", &"crew_airlock"]
		&"activity_completed":
			return is_instance_valid(daily) and int(daily.completed.get(String(entry.subject), 0)) >= entry.required
		&"event":
			return int(_events.get(entry.subject, 0)) >= entry.required
	return false
