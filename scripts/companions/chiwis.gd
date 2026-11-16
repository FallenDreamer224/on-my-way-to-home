class_name Chiwis
extends CharacterBody2D
## Autonomous following only; mode policy and target are injected externally.

enum State { IDLE, FOLLOWING, WAITING }
@export var preferred_distance: float = 36.0
@export var activation_distance: float = 56.0
@export var movement_speed: float = 90.0
## Nearby cruise matches normal astronaut walking; the original 90 px/s cap is catch-up speed.
@export var walk_speed: float = 80.0
var running: bool = false
var _slow_motion_seconds: float = 0.0
@export var retry_interval: float = 0.35
@export var follow_target: Node2D
var state: State = State.IDLE
var follow_enabled: bool = false
var facing: StringName = &"s"
var planner: TerrainRoutePlanner
var _following_intent: bool = false
var _retry_remaining: float = 0.0
var _route: PackedVector2Array = []
var _waypoint: int = 0
var _goal_cell: Vector2i
var reserved_access: PackedVector2Array = []
var _parking_player: Vector2 = Vector2.INF
var _parking_cached: Vector2 = Vector2.ZERO


func parking_goal(player_position: Vector2) -> Vector2:
	if player_position.distance_to(_parking_player) < 1: return _parking_cached
	var near_access: bool = false
	for point: Vector2 in reserved_access:
		if point.distance_to(player_position) < 24: near_access = true
	if not near_access or planner == null: return player_position
	var best: Vector2 = player_position
	var score: float = INF
	for cell: Vector2i in planner.terrain.terrain_cells:
		var point := IsometricGrid.tile_to_world(cell, planner.terrain)
		if point.distance_to(player_position) > 48 or point.distance_to(player_position) < 24: continue
		var clear: bool = true
		for access: Vector2 in reserved_access:
			if point.distance_to(access) < 24: clear = false
		if clear and point.distance_to(global_position) < score and not planner.route(global_position, point).is_empty():
			best = point
			score = point.distance_to(global_position)
	_parking_player = player_position
	_parking_cached = best
	return best
@onready var visual: AstronautAnimation = $AnimatedSprite2D
@onready var footprint_half_extent: Vector2 = ($CollisionShape2D.shape as RectangleShape2D).size / 2.0


func configure_terrain(terrain: TerrainLayer) -> void:
	_parking_player = Vector2.INF
	planner = TerrainRoutePlanner.new(terrain, footprint_half_extent)
	_route.clear()


func set_follow_target(target: Variant) -> void:
	follow_target = target if is_instance_valid(target) and target is Node2D else null
	_following_intent = false
	_route.clear()
	_retry_remaining = 0.0


func set_follow_enabled(enabled: bool) -> void:
	follow_enabled = enabled
	_route.clear()
	_retry_remaining = 0.0
	_stop(State.IDLE if enabled else State.WAITING)


func _stop(next_state: State) -> void:
	running = false
	_slow_motion_seconds = 0.0
	state = next_state
	velocity = Vector2.ZERO
	if is_node_ready():
		visual.select_state(&"idle", facing)


func _physics_process(delta: float) -> void:
	if (not follow_enabled or planner == null or not is_instance_valid(planner.terrain)
			or not is_instance_valid(follow_target) or follow_target.is_queued_for_deletion()
			or not follow_target.is_inside_tree() or not follow_target.global_position.is_finite()):
		_stop(State.WAITING)
		return
	var goal: Vector2 = parking_goal(follow_target.global_position)
	var distance: float = global_position.distance_to(goal)
	var stop_distance: float = maxf(0.0, preferred_distance)
	var start_distance: float = maxf(stop_distance + 1.0, activation_distance)
	if not goal.is_equal_approx(follow_target.global_position):
		stop_distance = 2
		start_distance = 4
	if distance <= stop_distance + 0.01:
		_following_intent = false
		_route.clear()
		_stop(State.IDLE)
		return
	if distance >= start_distance and not _following_intent:
		_following_intent = true
		_retry_remaining = 0.0
	if not _following_intent:
		_stop(State.IDLE)
		return
	_retry_remaining -= delta
	var goal_cell: Vector2i = IsometricGrid.world_to_tile(goal, planner.terrain)
	if goal_cell != _goal_cell or _retry_remaining <= 0.0:
		_route = planner.route(global_position, goal)
		_waypoint = 0
		_goal_cell = goal_cell
		_retry_remaining = maxf(0.05, retry_interval)
	while _waypoint < _route.size() and global_position.distance_to(_route[_waypoint]) < 0.1:
		_waypoint += 1
	if _waypoint >= _route.size():
		_stop(State.WAITING)
		return
	# Last endpoint follows a moving target in the same cell; every actual step is swept.
	var destination: Vector2 = goal if _waypoint == _route.size() - 1 else _route[_waypoint]
	var heading: Vector2 = destination - global_position
	if delta <= 0.0 or not is_finite(movement_speed) or movement_speed <= 0.0:
		_stop(State.WAITING)
		return
	var speed: float = movement_speed
	if distance <= start_distance + stop_distance and is_finite(walk_speed) and walk_speed > 0:
		speed = minf(movement_speed, walk_speed)
	var length: float = minf(speed * delta, minf(heading.length(), distance - stop_distance))
	var requested: Vector2 = heading.normalized() * length
	var motion: Vector2 = planner.walkability.constrain_motion(global_position, requested, footprint_half_extent)
	if not motion.is_equal_approx(requested) or motion.length_squared() < 0.000001:
		_route.clear()
		_stop(State.WAITING)
		return
	var before: Vector2 = global_position
	velocity = motion / delta
	move_and_slide()
	if global_position.distance_squared_to(before) < 0.000001:
		_route.clear()
		_stop(State.WAITING)
		return
	var actual_motion: Vector2 = global_position - before
	facing = AstronautDirections.from_vector(actual_motion)
	state = State.FOLLOWING
	select_moving_animation(actual_motion.length() / delta, delta)


func select_moving_animation(actual_speed: float, delta: float) -> void:
	if actual_speed > walk_speed + 0.01:
		running = true
		_slow_motion_seconds = 0.0
	else:
		_slow_motion_seconds += delta
		# Short route-waypoint steps must not flash a walk frame between sustained run steps.
		if _slow_motion_seconds >= 0.1:
			running = false
	visual.select_state(&"run" if running else &"walk", facing)
