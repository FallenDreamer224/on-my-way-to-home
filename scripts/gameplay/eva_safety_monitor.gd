class_name EvaSafetyMonitor
extends Node
## Chiwis safety dialogue observes the astronaut, never a camera or companion position.

signal notice_requested(text: String, duration: float)
signal zone_changed(zone: EvaSafetyLimits.Zone)

var limits: EvaSafetyLimits
var range_provider: EvaRangeProvider
var suspended: bool = false
var current_zone: EvaSafetyLimits.Zone = EvaSafetyLimits.Zone.NORMAL
var safe_return_direction: Vector2 = Vector2.ZERO
var actor: Astronaut
var modes: GameplayModeCoordinator
var _terrain: TerrainLayer
var _planner: TerrainRoutePlanner
var _cooldown: float = 0.0
var _normal_time: float = 0.0
var _issued: Dictionary[int, bool] = {}
var _last_cell: Vector2i = Vector2i(2147483647, 2147483647)


func configure(player: Astronaut, terrain: TerrainLayer, coordinator: GameplayModeCoordinator, policy: EvaSafetyLimits) -> bool:
	set_physics_process(false)
	limits = null
	if (not is_instance_valid(player) or not is_instance_valid(terrain)
			or not is_instance_valid(coordinator) or policy == null or not policy.validation_errors().is_empty()):
		return false
	if not terrain.is_cell_walkable(policy.return_cell):
		return false
	actor = player
	_terrain = terrain
	modes = coordinator
	limits = policy
	_planner = TerrainRoutePlanner.new(terrain, player.footprint_half_extent)
	_cooldown = 0.0
	_normal_time = 0.0
	_issued.clear()
	_last_cell = Vector2i(2147483647, 2147483647)
	current_zone = EvaSafetyLimits.Zone.NORMAL
	safe_return_direction = Vector2.ZERO
	# Observe the completed actor physics update rather than predicting requested input.
	process_physics_priority = 100
	set_physics_process(true)
	return true


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	if suspended or not is_finite(delta) or delta < 0.0 or limits == null:
		return
	_cooldown = maxf(0.0, _cooldown - delta)
	if (not is_instance_valid(actor) or not is_instance_valid(_terrain) or not is_instance_valid(modes)
			or not modes.is_player_mode() or not actor.control_enabled or not modes.keyboard_input_available()
			or not actor.global_position.is_finite()):
		return
	var cell := IsometricGrid.world_to_tile(actor.global_position, _terrain)
	var next: EvaSafetyLimits.Zone = limits.zone_at(cell)
	if next != current_zone:
		current_zone = next
		zone_changed.emit(current_zone)
	if cell != _last_cell:
		_last_cell = cell
		safe_return_direction = return_direction(actor.global_position)
	if current_zone == EvaSafetyLimits.Zone.NORMAL:
		_normal_time += delta
		if _normal_time >= limits.normal_rearm_seconds:
			_issued.clear()
		return
	_normal_time = 0.0
	if _cooldown > 0.0 or _issued.has(current_zone):
		return
	var boundary: bool = current_zone == EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY
	if (boundary and not limits.boundary_enabled) or (not boundary and not limits.warning_enabled):
		return
	var text: String = limits.boundary_message if boundary else limits.warning_message
	if boundary:
		text += " " + limits.safety_reason
	var direction: Vector2 = return_direction(actor.global_position)
	if direction != Vector2.ZERO:
		text += " Return: " + String(AstronautDirections.from_vector(direction)).to_upper() + "."
	_issued[current_zone] = true
	# A boundary notice also covers the milder warning during retreat.
	if boundary:
		_issued[EvaSafetyLimits.Zone.WARNING] = true
	_cooldown = limits.cooldown_seconds
	notice_requested.emit("Chiwis: " + text, limits.message_duration_seconds)


func return_direction(from: Vector2) -> Vector2:
	if _planner == null or not from.is_finite():
		return Vector2.ZERO
	var target := IsometricGrid.tile_to_world(limits.return_cell, _terrain)
	for point: Vector2 in _planner.route(from, target):
		if point.distance_to(from) > 0.1:
			return (point - from).normalized()
	return Vector2.ZERO


func assess_future_range(remaining_supplies: Dictionary, estimated_return_seconds: float) -> EvaSafetyLimits:
	# Null explicitly means unavailable, not an invented safe distance or a new limit.
	if range_provider == null or not is_finite(estimated_return_seconds) or estimated_return_seconds < 0.0:
		return null
	return range_provider.assess(remaining_supplies, estimated_return_seconds)
