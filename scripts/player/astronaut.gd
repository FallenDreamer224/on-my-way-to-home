class_name Astronaut
extends CharacterBody2D
## Physics movement and facing only. Mode policy is injected by the composition root.

const MOVEMENT_ACTIONS: Array[StringName] = [&"player_move_left", &"player_move_right", &"player_move_up", &"player_move_down", &"camera_pan_left", &"camera_pan_right", &"camera_pan_up", &"camera_pan_down"]
@export var walk_speed: float = 80.0
@export var run_speed: float = 140.0
var running: bool = false
var facing: StringName = &"s"
var control_enabled: bool = false
var _requires_neutral: bool = true
var walkability: TerrainWalkability
@onready var visual: AstronautAnimation = $AnimatedSprite2D
@onready var footprint_half_extent: Vector2 = ($CollisionShape2D.shape as RectangleShape2D).size / 2.0


func configure_terrain(terrain: TerrainLayer) -> void:
	walkability = TerrainWalkability.new(terrain)


func set_control_enabled(enabled: bool) -> void:
	control_enabled = enabled
	_requires_neutral = _movement_held() if enabled else true
	stop_movement()


func _movement_held() -> bool:
	for action: StringName in MOVEMENT_ACTIONS:
		if Input.is_action_pressed(action):
			return true
	return false


func stop_movement() -> void:
	running = false
	velocity = Vector2.ZERO
	if is_node_ready():
		visual.select_state(&"idle", facing)


func read_movement_input() -> Vector2:
	return (Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
		+ Input.get_vector("camera_pan_left", "camera_pan_right", "camera_pan_up", "camera_pan_down")).limit_length(1.0)


func movement_velocity(direction: Vector2, use_run: bool = false) -> Vector2:
	var speed: float = run_speed if use_run else walk_speed
	return direction.limit_length(1.0) * speed if direction.is_finite() and is_finite(speed) and speed > 0.0 else Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not control_enabled or get_viewport().gui_get_focus_owner() != null:
		_requires_neutral = true
		stop_movement()
		return
	if _requires_neutral:
		if _movement_held():
			stop_movement()
			return
		_requires_neutral = false
	var direction: Vector2 = read_movement_input()
	if direction != Vector2.ZERO:
		facing = AstronautDirections.from_vector(direction)
	var wants_run: bool = Input.is_action_pressed(&"player_run")
	var desired: Vector2 = movement_velocity(direction, wants_run)
	if walkability == null or desired == Vector2.ZERO or delta <= 0.0:
		stop_movement()
		return
	var before: Vector2 = global_position
	velocity = walkability.constrain_motion(before, desired * delta, footprint_half_extent) / delta
	move_and_slide()
	var moved: bool = global_position.distance_squared_to(before) > 0.000001
	running = wants_run and moved
	visual.select_state((&"run" if running else &"walk") if moved else &"idle", facing)
