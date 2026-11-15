extends SceneTree
## Targets move only in this isolated test, never through a runtime input/controller.

const RIG_SCENE: PackedScene = preload("res://scenes/camera/camera_rig.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var target: Node2D = Node2D.new()
	root.add_child(target)
	target.position = Vector2(32, 16)
	var rig: PlayerCameraRig = RIG_SCENE.instantiate() as PlayerCameraRig
	rig.follow_target = target
	root.add_child(rig)
	await process_frame
	_check(rig.is_active(), "Active initialization")
	_check(rig.follow_target == target, "Initial target assignment")
	_check(rig.global_position == target.global_position, "Initial centering")
	_check(rig.camera.zoom == Vector2(2, 2), "Default 2x zoom")
	_check(not rig.camera.position_smoothing_enabled, "Smoothing disabled")
	_check(root.get_visible_rect().size == Vector2(960, 540), "Established logical resolution")
	target.position = Vector2(-64, 48)
	await process_frame
	await process_frame
	_check(rig.global_position == target.global_position, "Automatic frame follow")
	_check(rig.camera.get_screen_center_position().is_equal_approx(target.global_position), "Actual native viewport center follows")
	var second: Node2D = Node2D.new()
	root.add_child(second)
	second.position = Vector2(0, -32)
	rig.set_follow_target(second)
	_check(rig.global_position == second.global_position, "Immediate valid target replacement")
	rig.follow_offset = Vector2(8, -12)
	rig.refresh_follow()
	_check(rig.global_position == second.global_position + Vector2(8, -12), "Global follow offset")
	rig.follow_offset = Vector2.ZERO
	second.position = Vector2(0.24, -0.24)
	rig.refresh_follow()
	_check(rig.global_position == Vector2.ZERO, "Subpixel target snapped at 2x")
	_check(second.position == Vector2(0.24, -0.24), "Simulation target never snapped")
	second.position = Vector2(0.76, -0.76)
	rig.refresh_follow()
	_check(rig.global_position == Vector2(1, -1), "Nearest logical-screen pixel snapping")
	var canvas_origin: Vector2 = target.get_canvas_transform().origin
	_check(canvas_origin.is_equal_approx(canvas_origin.round()), "Actual canvas translation lies on logical pixels")
	var before: Vector2 = rig.global_position
	rig.set_follow_target(null)
	await process_frame
	_check(rig.global_position == before, "Null target holds view")
	rig.set_follow_target(second)
	second.queue_free()
	rig.refresh_follow()
	await process_frame
	await process_frame
	_check(rig.global_position == before, "Queued and freed target holds view")
	rig.set_follow_target(target)
	_check(rig.set_zoom_level(3.2) and rig.zoom_level == 3, "Fractional request quantized")
	_check(rig.camera.zoom == Vector2(3, 3), "Native camera zoom updated")
	_check(rig.set_zoom_level(-10.0) and rig.zoom_level == 1, "Negative zoom safely clamped")
	_check(rig.set_zoom_level(100.0) and rig.zoom_level == 4, "Maximum zoom enforced")
	_check(not rig.set_zoom_level(NAN) and rig.zoom_level == 4, "NaN rejected")
	_check(not rig.set_zoom_level(INF) and rig.zoom_level == 4, "Infinite zoom rejected")
	rig.maximum_zoom = 2
	_check(rig.zoom_level == 2 and rig.camera.zoom == Vector2(2, 2), "Runtime limit edit reclamps immediately")
	rig.minimum_zoom = -4
	rig.maximum_zoom = -10
	rig.set_zoom_level(2.0)
	_check(rig.zoom_level == 1, "Invalid configured limits normalized safely")
	rig.minimum_zoom = 2
	rig.maximum_zoom = 3
	rig.set_zoom_level(1.0)
	_check(rig.zoom_level == 2, "Custom configured minimum")
	rig.set_zoom_level(10.0)
	_check(rig.zoom_level == 3, "Custom configured maximum")
	rig.minimum_zoom = 1
	rig.maximum_zoom = 4
	rig.set_zoom_level(2.0)
	rig.deactivate()
	before = rig.global_position
	target.position = Vector2(2000, 2000)
	await process_frame
	await process_frame
	_check(not rig.is_active() and not rig.camera.enabled, "Explicit deactivation")
	_check(not rig.is_processing() and rig.global_position == before, "Inactive rig does not follow")
	rig.activate()
	_check(rig.is_active() and rig.global_position == target.global_position, "Activation reacquires current target")
	rig.bounds_enabled = true
	rig.world_bounds = Rect2(-1000, -1000, 2000, 2000)
	rig.refresh_follow()
	_check(rig.global_position == Vector2(760, 865), "Viewport-aware positive bounds at 2x")
	target.position = Vector2(-2000, -2000)
	rig.refresh_follow()
	_check(rig.global_position == Vector2(-760, -865), "Viewport-aware negative bounds")
	rig.set_zoom_level(1)
	_check(rig.global_position == Vector2(-520, -730), "Bounds recomputed after zoom")
	rig.world_bounds = Rect2(-50, -50, 100, 100)
	target.position = Vector2(17, -23)
	rig.refresh_follow()
	_check(rig.global_position == target.position, "Small map does not force displacement")
	rig.world_bounds = Rect2(-1000, -50, 2000, 100)
	target.position = Vector2(2000, 23)
	rig.refresh_follow()
	_check(rig.global_position == Vector2(520, 23), "Undersized bound axes handled independently")
	rig.world_bounds = Rect2(Vector2(INF, 0), Vector2(2000, 2000))
	rig.refresh_follow()
	_check(rig.global_position == target.position, "Invalid nonfinite bounds ignored safely")
	rig.bounds_enabled = false
	rig.refresh_follow()
	_check(rig.global_position == target.position, "Optional bounds can be disabled")
	var other: Camera2D = Camera2D.new()
	root.add_child(other)
	other.make_current()
	rig.refresh_follow()
	_check(not rig.is_active() and other.is_current(), "Follow never steals current status from another camera")
	rig.deactivate()
	_check(other.is_current(), "Deactivation preserves other current camera")
	rig.activate()
	_check(rig.is_active(), "Explicit activation may take ownership")
	other.queue_free()
	rig.queue_free()
	target.queue_free()
	await process_frame
	var idle_rig: PlayerCameraRig = RIG_SCENE.instantiate() as PlayerCameraRig
	idle_rig.active_on_start = false
	root.add_child(idle_rig)
	_check(not idle_rig.is_active() and not idle_rig.is_processing(), "Inactive startup configuration")
	idle_rig.activate()
	_check(idle_rig.is_active() and idle_rig.global_position == Vector2.ZERO, "Missing initial target safe")
	idle_rig.queue_free()
	await process_frame
	var main: Node = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var main_rig: PlayerCameraRig = main.get_node("CameraRig") as PlayerCameraRig
	var marker: Node2D = main.get_node("World/Entities/Players/Astronaut") as Node2D
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground") as TerrainLayer
	var original_cells: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	_check(marker.global_position == IsometricGrid.tile_to_world(Vector2i.ZERO, ground), "Main marker placed through native grid API")
	_check(main_rig.follow_target == marker and main_rig.is_active(), "Main target wired and camera active")
	_check(main_rig.camera.get_screen_center_position().is_equal_approx(marker.global_position), "Main actual native viewport centered")
	_check(ground.get_used_cells().size() == ground.region.size.x * ground.region.size.y and ground.region.size == Vector2i(40, 40), "Production lunar map dimensions retained")
	for cell: Vector2i in [Vector2i(1, -2), Vector2i(-3, 1), Vector2i.ZERO]:
		marker.global_position = IsometricGrid.tile_to_world(cell, ground)
		await process_frame
		await process_frame
		_check(main_rig.global_position == marker.global_position, "Follow in original isometric terrain")
	_check(ground.terrain_cells == original_cells and ground.region.cells.is_empty(), "Camera never mutates terrain/state data")
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d player camera checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
