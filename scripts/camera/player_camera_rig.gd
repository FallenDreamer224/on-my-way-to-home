class_name PlayerCameraRig
extends Node2D
## Input-independent target following. Keep this rig unscaled and unrotated.

@export var follow_target: Node2D
@export var follow_offset: Vector2 = Vector2.ZERO
@export_range(1, 16, 1) var minimum_zoom: int = 1:
	set(value):
		minimum_zoom = maxi(1, value)
		if is_node_ready():
			zoom_level = zoom_level
@export_range(1, 16, 1) var maximum_zoom: int = 4:
	set(value):
		maximum_zoom = maxi(1, value)
		if is_node_ready():
			zoom_level = zoom_level
@export_range(1, 16, 1) var zoom_level: int = 2:
	set(value):
		var lower: int = maxi(1, minimum_zoom)
		zoom_level = clampi(value, lower, maxi(lower, maximum_zoom))
		if is_node_ready():
			camera.zoom = Vector2.ONE * zoom_level
			refresh_follow()
@export var active_on_start: bool = true
@export var bounds_enabled: bool = false
@export var center_small_bounds: bool = false
@export var world_bounds: Rect2 = Rect2()

@onready var camera: Camera2D = $Camera2D

var _active: bool = false


func _ready() -> void:
	zoom_level = zoom_level
	if active_on_start:
		activate()
	else:
		deactivate()


func _process(_delta: float) -> void:
	# Run after normal-priority target transforms. Direct follow has no time integration.
	refresh_follow()


func set_follow_target(target: Node2D) -> void:
	follow_target = target if is_instance_valid(target) else null
	if is_node_ready():
		refresh_follow()


func set_zoom_level(requested: float) -> bool:
	if not is_finite(requested):
		return false
	var lower: int = maxi(1, minimum_zoom)
	var upper: int = maxi(lower, maximum_zoom)
	zoom_level = roundi(clampf(requested, lower, upper))
	return true


func activate() -> void:
	_active = true
	if not is_node_ready():
		active_on_start = true
		return
	camera.enabled = true
	refresh_follow()
	camera.make_current()
	set_process(true)


func deactivate() -> void:
	_active = false
	if not is_node_ready():
		active_on_start = false
		return
	camera.enabled = false
	set_process(false)


func is_active() -> bool:
	return _active and is_node_ready() and camera.enabled and camera.is_current()


func refresh_follow() -> void:
	if not _active or not is_node_ready():
		return
	# Hold the last valid view when a target is absent, freed, queued, or detached.
	if not is_instance_valid(follow_target):
		return
	if follow_target.is_queued_for_deletion() or not follow_target.is_inside_tree():
		return
	var desired: Vector2 = follow_target.global_position + follow_offset
	if not desired.is_finite():
		return
	# Quantize camera translation to logical-screen pixels, never the simulation target.
	global_position = CameraFraming.center(desired, zoom_level, get_viewport_rect().size, bounds_enabled, world_bounds, true, center_small_bounds)
	camera.force_update_scroll()
