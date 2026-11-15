class_name GameplayModeCoordinator
extends Node
## Camera/input policy only. World state and future player controllers remain external.

enum Mode { PLAYER, BASE_MANAGEMENT }
signal mode_changed(mode: Mode)

var player_camera: PlayerCameraRig
var management_camera: BaseManagementCameraRig
var current_mode: Mode:
	get:
		return _mode
var _mode: Mode = Mode.PLAYER
var _initialized: bool = false
var _management_visited: bool = false
var _transitioning: bool = false
var modal_input_blocked: bool = false


func _ready() -> void:
	set_process(false)


func initialize(player: Variant, management: Variant) -> bool:
	if _initialized or not _usable(player) or not _usable(management):
		return false
	if not player is PlayerCameraRig or not management is BaseManagementCameraRig:
		return false
	player_camera = player
	management_camera = management
	_initialized = true
	player_camera.activate()
	management_camera.deactivate()
	mode_changed.emit(_mode)
	return true


func is_player_mode() -> bool:
	return _initialized and _mode == Mode.PLAYER


func is_management_mode() -> bool:
	return _initialized and _mode == Mode.BASE_MANAGEMENT


func request_mode(requested: int) -> bool:
	if (not _initialized or modal_input_blocked or _transitioning or requested == _mode
			or requested not in [Mode.PLAYER, Mode.BASE_MANAGEMENT]
			or not _usable(player_camera) or not _usable(management_camera)):
		return false
	_transitioning = true
	if requested == Mode.BASE_MANAGEMENT:
		if not _management_visited:
			var target: Variant = player_camera.follow_target
			var center: Vector2 = player_camera.global_position
			if is_instance_valid(target) and target.is_inside_tree() and not target.is_queued_for_deletion():
				center = target.global_position
			management_camera.set_pan_position(center)
			_management_visited = true
		# Prepare and select the incoming camera before disabling the outgoing one:
		# no viewport iteration can see an uninitialized/fallback camera.
		management_camera.activate()
		player_camera.deactivate()
		_mode = Mode.BASE_MANAGEMENT
	else:
		player_camera.activate()
		management_camera.deactivate()
		_mode = Mode.PLAYER
	set_process(_mode == Mode.BASE_MANAGEMENT)
	mode_changed.emit(_mode)
	_transitioning = false
	return true


func _process(delta: float) -> void:
	route_pan(read_pan_direction(), delta)


func keyboard_input_available() -> bool:
	return not modal_input_blocked and get_viewport().gui_get_focus_owner() == null


func read_pan_direction() -> Vector2:
	return (Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down")
			+ Input.get_vector("camera_pan_left", "camera_pan_right", "camera_pan_up", "camera_pan_down")).limit_length(1.0)


func route_pan(direction: Vector2, delta: float) -> void:
	if is_management_mode() and keyboard_input_available() and _usable(management_camera):
		management_camera.pan(direction, delta)


func _unhandled_input(event: InputEvent) -> void:
	if route_unhandled_input(event):
		get_viewport().set_input_as_handled()


func route_unhandled_input(event: InputEvent) -> bool:
	if not _initialized or not keyboard_input_available() or event.is_echo():
		return false
	if event.is_action_pressed("mode_switch"):
		return request_mode(Mode.BASE_MANAGEMENT if is_player_mode() else Mode.PLAYER)
	if is_management_mode() and _usable(management_camera):
		if event.is_action_pressed("camera_zoom_in"):
			management_camera.set_zoom_level(management_camera.zoom_level + 1)
			return true
		if event.is_action_pressed("camera_zoom_out"):
			management_camera.set_zoom_level(management_camera.zoom_level - 1)
			return true
	return false


func _usable(rig: Variant) -> bool:
	# Variant is deliberate: a typed Object argument rejects a freed instance before this guard.
	return (is_instance_valid(rig) and rig is Node2D and not rig.is_queued_for_deletion() and rig.is_node_ready()
			and rig.is_inside_tree() and is_instance_valid(rig.get("camera")))
