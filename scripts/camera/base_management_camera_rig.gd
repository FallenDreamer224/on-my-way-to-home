class_name BaseManagementCameraRig
extends Node2D
## Continuous logical position, independently snapped render position. No input polling.

signal zoom_changed(level: int)

@export var movement_speed: float = 360.0
@export_range(1, 16, 1) var minimum_zoom: int = 1:
	set(value):
		minimum_zoom = maxi(1, value)
		zoom_level = zoom_level
@export_range(1, 16, 1) var maximum_zoom: int = 3:
	set(value):
		maximum_zoom = maxi(1, value)
		zoom_level = zoom_level
@export_range(1, 16, 1) var zoom_level: int = 1:
	set(value):
		var old: int = zoom_level
		zoom_level = clampi(value, maxi(1, minimum_zoom), maxi(maxi(1, minimum_zoom), maximum_zoom))
		if is_node_ready():
			camera.zoom = Vector2.ONE * zoom_level
			refresh_view()
			if old != zoom_level:
				zoom_changed.emit(zoom_level)
@export var pan_position: Vector2 = Vector2.ZERO
@export var bounds_enabled: bool = false
@export var center_small_bounds: bool = false
@export var world_bounds: Rect2 = Rect2()

@onready var camera: Camera2D = $Camera2D
var _active: bool = false


func _ready() -> void:
	zoom_level = zoom_level
	deactivate()


func _process(_delta: float) -> void:
	refresh_view()


func set_zoom_level(requested: float) -> bool:
	if not is_finite(requested):
		return false
	zoom_level = roundi(clampf(requested, maxi(1, minimum_zoom), maxi(maxi(1, minimum_zoom), maximum_zoom)))
	return true


func set_pan_position(position_in_world: Vector2) -> bool:
	if not position_in_world.is_finite():
		return false
	pan_position = position_in_world
	if is_node_ready():
		refresh_view()
	return true


func pan(direction: Vector2, delta: float) -> void:
	if (not is_active() or not direction.is_finite() or not is_finite(delta)
			or delta <= 0.0 or not is_finite(movement_speed) or movement_speed <= 0.0):
		return
	pan_position += direction.limit_length(1.0) * movement_speed * delta / zoom_level
	refresh_view()


func activate() -> void:
	_active = true
	camera.enabled = true
	refresh_view()
	camera.make_current()
	set_process(true)


func deactivate() -> void:
	_active = false
	camera.enabled = false
	set_process(false)


func is_active() -> bool:
	return _active and is_node_ready() and camera.enabled and camera.is_current()


func refresh_view() -> void:
	if not is_node_ready() or not pan_position.is_finite():
		return
	# Clamp accumulated state without snapping; tiny per-frame motion must not be lost.
	pan_position = CameraFraming.center(pan_position, zoom_level, get_viewport_rect().size, bounds_enabled, world_bounds, false, center_small_bounds)
	global_position = CameraFraming.center(pan_position, zoom_level, get_viewport_rect().size, bounds_enabled, world_bounds, true, center_small_bounds)
	if camera.is_current():
		camera.force_update_scroll()
