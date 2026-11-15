class_name InteractionDetector
extends Area2D
## Signal-maintained nearby set; selection/execution revalidate world distance and terrain.

signal target_changed(target: Interactable)
signal attempted(success: bool)
@export var interaction_range: float = 48.0:
	set(value):
		interaction_range = value
		if is_node_ready():
			($CollisionShape2D.shape as CircleShape2D).radius = maxf(0.01, value) if is_finite(value) else 0.01
var enabled: bool = false
var target: Interactable
var last_result_message: String = ""
var actor: Astronaut
var inventory: RuntimeInventory
var _nearby: Array[Interactable] = []
var _requires_release: bool = false


func _ready() -> void:
	area_entered.connect(_entered)
	area_exited.connect(_exited)
	interaction_range = interaction_range


func configure(player: Astronaut, items: RuntimeInventory) -> void:
	actor = player
	inventory = items


func set_enabled(value: bool) -> void:
	enabled = value
	_requires_release = Input.is_action_pressed("interact_primary")
	refresh_target()


func _entered(area: Area2D) -> void:
	if area is Interactable and area not in _nearby:
		_nearby.append(area)


func _exited(area: Area2D) -> void:
	_nearby.erase(area)


func _physics_process(_delta: float) -> void:
	if not Input.is_action_pressed("interact_primary"):
		_requires_release = false
	refresh_target()


func _can_receive_input() -> bool:
	return enabled and is_instance_valid(actor) and actor.control_enabled and get_viewport().gui_get_focus_owner() == null


func _valid(candidate: Variant) -> bool:
	if (not is_instance_valid(candidate) or not candidate is Interactable or not candidate.is_available()
			or not is_instance_valid(actor) or actor.walkability == null or not is_finite(interaction_range) or interaction_range <= 0):
		return false
	var offset: Vector2 = candidate.global_position - actor.global_position
	return (offset.is_finite() and offset.length_squared() <= interaction_range * interaction_range
		and actor.walkability.is_position_walkable(candidate.global_position, actor.footprint_half_extent)
		and actor.walkability.constrain_motion(actor.global_position, offset, actor.footprint_half_extent).is_equal_approx(offset))


func refresh_target() -> void:
	var nearest: Interactable
	var best_distance: float = INF
	if _can_receive_input():
		for index: int in range(_nearby.size() - 1, -1, -1):
			var candidate: Variant = _nearby[index]
			if not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
				_nearby.remove_at(index)
				continue
			if not _valid(candidate):
				continue
			var distance: float = actor.global_position.distance_squared_to(candidate.global_position)
			var tie_preferred: bool = (nearest != null and absf(distance - best_distance) <= 0.0001
				and (candidate.selection_key() < nearest.selection_key() or (candidate.selection_key() == nearest.selection_key()
					and String(candidate.get_path()) < String(nearest.get_path()))))
			if distance < best_distance - 0.0001 or tie_preferred:
				nearest = candidate
				best_distance = distance
	if target != nearest:
		target = nearest
		target_changed.emit(target)


func interact() -> bool:
	refresh_target()
	if not _can_receive_input() or not _valid(target) or not is_instance_valid(inventory):
		return false
	var executed: Interactable = target
	var success: bool = executed.execute(inventory)
	last_result_message = executed.result_message(success) if is_instance_valid(executed) else "Collected" if success else "Item unavailable"
	attempted.emit(success)
	refresh_target()
	return success


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("interact_primary"):
		_requires_release = false
	if event.is_action_pressed("interact_primary") and not event.is_echo() and not _requires_release and _can_receive_input():
		_requires_release = true
		interact()
		get_viewport().set_input_as_handled()
