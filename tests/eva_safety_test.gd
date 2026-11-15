extends SceneTree
## Deterministic policy/time tests plus real production full-foot geometry and UI wiring.

var checks: int = 0
var failures: Array[String] = []
var notices: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)


func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var actor: Astronaut = main.astronaut
	var dog: Chiwis = main.chiwis
	var terrain: TerrainLayer = main.get_node("World/Terrain/Ground")
	var monitor: EvaSafetyMonitor = main.get_node("Systems/EvaSafety")
	var policy: EvaSafetyLimits = monitor.limits
	actor.set_physics_process(false)
	dog.set_physics_process(false)
	monitor.set_physics_process(false)
	monitor.notice_requested.connect(func(text: String, _duration: float) -> void: notices.append(text))
	check(policy == (terrain.region as LunarTutorialRegion).eva_limits, "One shared authored policy")
	check(policy.validation_errors().is_empty(), "Valid default limits")
	var original: Dictionary[Vector2i, int] = terrain.terrain_cells.duplicate()
	var counts: Dictionary[int, int] = {}
	for cell: Vector2i in original:
		var zone: int = policy.zone_at(cell)
		counts[zone] = counts.get(zone, 0) + 1
		if not policy.allowed_cells.has_point(cell):
			check(zone == EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY and not terrain.is_cell_walkable(cell), "Outer cells restricted by shared policy")
	check(counts[EvaSafetyLimits.Zone.NORMAL] == 1024, "32x32 normal exploration cells")
	check(counts[EvaSafetyLimits.Zone.WARNING] == 272, "Two-cell warning band")
	check(counts[EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY] == 304, "Approach band plus forbidden ring")
	for cell: Vector2i in [Vector2i(-20, 0), Vector2i(19, 0), Vector2i(0, -20), Vector2i(0, 19), Vector2i(-100, 100)]:
		check(policy.zone_at(cell) == EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY, "Outside policy classification")
	var invalid := policy.duplicate() as EvaSafetyLimits
	invalid.warning_inset_cells = invalid.boundary_inset_cells
	check(not invalid.validation_errors().is_empty(), "Inverted bands rejected")
	invalid = policy.duplicate() as EvaSafetyLimits
	invalid.cooldown_seconds = NAN
	check(not invalid.validation_errors().is_empty(), "Nonfinite timing rejected")
	invalid = policy.duplicate() as EvaSafetyLimits
	invalid.return_cell = Vector2i(100, 100)
	check(not invalid.validation_errors().is_empty(), "Outside return point rejected")
	check(monitor.assess_future_range({}, 10.0) == null, "Absent range model explicitly unavailable")
	var provider := EvaRangeProvider.new()
	check(provider.assess({"oxygen": 1}, 120.0) == null, "Base provider invents no range")
	monitor.range_provider = provider
	check(monitor.assess_future_range({}, NAN) == null, "Nonfinite future return time rejected")
	# Warn once, defer escalation until cooldown, and never repeat while standing.
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(17, 0), terrain)
	monitor.advance(0.1)
	check(notices.size() == 1 and notices[0].begins_with("Chiwis:"), "Chiwis warning on entering band")
	check(main.game_ui.hud.notifications.message.text == notices[0], "Production notice sink updates existing UI")
	await process_frame
	check(main.game_ui.hud.notifications.message.get_line_count() <= 4, "Default warning fits all four visible notice lines")
	check(monitor.safe_return_direction != Vector2.ZERO, "Safe route direction available")
	for tick: int in 100:
		monitor.advance(0.1)
	check(notices.size() == 1, "Standing in warning zone never spams")
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(18, 0), terrain)
	monitor.advance(0.1)
	check(notices.size() == 2 and notices[1].contains("mission area ends"), "Boundary notice escalates")
	check(notices[1].length() <= 180, "Default dialogue fits existing message slot")
	await process_frame
	check(main.game_ui.hud.notifications.message.get_line_count() <= 4, "Default boundary explanation and return hint fully readable")
	for tick: int in 100:
		monitor.advance(0.1)
	check(notices.size() == 2, "Holding at boundary never spams")
	actor.global_position = Vector2.ZERO
	monitor.advance(0.1)
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(17, 0), terrain)
	monitor.advance(0.1)
	check(notices.size() == 2, "Brief normal-zone jitter does not rearm")
	actor.global_position = Vector2.ZERO
	monitor.advance(policy.normal_rearm_seconds)
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(17, 0), terrain)
	monitor.advance(0.1)
	check(notices.size() == 3, "Sustained safe return rearms excursion")
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(18, 0), terrain)
	monitor.advance(0.1)
	check(notices.size() == 3, "Rapid escalation respects global cooldown")
	actor.global_position = Vector2.ZERO
	monitor.advance(policy.cooldown_seconds)
	check(notices.size() == 3, "Leaving boundary cancels deferred message")
	# Camera pan and actor position changes during management must not produce notices.
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(-19, 0), terrain)
	main.management_camera.set_pan_position(Vector2(10000, -10000))
	monitor.advance(100.0)
	check(notices.size() == 3, "Management mode never warns")
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.PLAYER)
	monitor.advance(0.1)
	check(notices.size() == 4, "Return to player evaluates actual actor location")
	actor.global_position = Vector2.ZERO
	monitor.advance(10.0)
	main.player_session.set_inventory_open(true)
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(17, 0), terrain)
	monitor.advance(100.0)
	check(notices.size() == 4, "Inventory modal suppresses warnings")
	main.player_session.set_inventory_open(false)
	monitor.advance(0.1)
	check(notices.size() == 5, "Closing modal resumes actor assessment")
	# Every edge and corner: never cross; diagonal contacts retain tangential motion.
	for cell: Vector2i in [Vector2i(-18, 0), Vector2i(17, 0), Vector2i(0, -18), Vector2i(0, 17), Vector2i(-18, -18), Vector2i(17, 17), Vector2i(-18, 17), Vector2i(17, -18)]:
		var start := IsometricGrid.tile_to_world(cell, terrain)
		for direction: Vector2 in AstronautDirections.VECTORS:
			var desired: Vector2 = direction.normalized() * 2000.0
			var accepted := actor.walkability.constrain_motion(start, desired, actor.footprint_half_extent)
			check(actor.walkability.is_position_walkable(start + accepted, actor.footprint_half_extent), "Swept long/diagonal motion retains full astronaut foot")
			check(policy.allowed_cells.has_point(IsometricGrid.world_to_tile(start + accepted, terrain)), "Movement remains inside mission area")
	# Push toward each edge, then continue along its tangent while pressing outward.
	for edge: Array in [[Vector2i(-18, 0), Vector2(-2, -1), Vector2(2, -1)], [Vector2i(17, 0), Vector2(2, 1), Vector2(2, -1)], [Vector2i(0, -18), Vector2(2, -1), Vector2(2, 1)], [Vector2i(0, 17), Vector2(-2, 1), Vector2(2, 1)]]:
		var start := IsometricGrid.tile_to_world(edge[0], terrain)
		var outward: Vector2 = (edge[1] as Vector2).normalized()
		var tangent: Vector2 = (edge[2] as Vector2).normalized()
		var contact := start + actor.walkability.constrain_motion(start, outward * 100, actor.footprint_half_extent)
		var slide := actor.walkability.constrain_motion(contact, outward * 2 + tangent * 2, actor.footprint_half_extent)
		check(slide.dot(tangent) > 0.5, "Smooth tangent progress while holding outward at edge")
		check(actor.walkability.is_position_walkable(contact + slide, actor.footprint_half_extent), "Sliding remains safe")
		var retreat := actor.walkability.constrain_motion(contact, -outward * 4, actor.footprint_half_extent)
		check(retreat.length() > 1.0, "Retreat never sticks")
		var dog_start := IsometricGrid.tile_to_world(Vector2i(0, 1), terrain)
		var route := dog.planner.route(dog_start, contact)
		check(not route.is_empty(), "Chiwis can navigate to safe boundary contact")
		for point: Vector2 in route:
			check(dog.planner.clear_segment(dog_start, point), "Chiwis route respects same boundary")
			dog_start = point
	check(terrain.terrain_cells == original, "Safety never mutates terrain art/data")
	# Entry, escalation and return on every side and corner, not only the east edge.
	for direction: Vector2i in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1)]:
		actor.global_position = Vector2.ZERO
		monitor.advance(10.0)
		var before: int = notices.size()
		var warning_cell := Vector2i(-17 if direction.x < 0 else 16 if direction.x > 0 else 0, -17 if direction.y < 0 else 16 if direction.y > 0 else 0)
		var edge_cell := Vector2i(-19 if direction.x < 0 else 18 if direction.x > 0 else 0, -19 if direction.y < 0 else 18 if direction.y > 0 else 0)
		actor.global_position = IsometricGrid.tile_to_world(warning_cell, terrain)
		monitor.advance(0.1)
		check(notices.size() == before + 1 and monitor.current_zone == EvaSafetyLimits.Zone.WARNING, "Warning entry on every side/corner")
		actor.global_position = IsometricGrid.tile_to_world(edge_cell, terrain)
		monitor.advance(policy.cooldown_seconds)
		check(notices.size() == before + 2 and monitor.current_zone == EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY, "Escalation on every side/corner")
		actor.global_position = Vector2.ZERO
		monitor.advance(0.1)
		check(monitor.current_zone == EvaSafetyLimits.Zone.NORMAL, "Safe return clears zone state")
	var muted := policy.duplicate() as EvaSafetyLimits
	muted.warning_enabled = false
	muted.boundary_enabled = false
	check(monitor.configure(actor, terrain, main.gameplay_modes, muted), "Dialogue trigger switches configurable")
	monitor.set_physics_process(false)
	var muted_count: int = notices.size()
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(17, 0), terrain)
	monitor.advance(10.0)
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(18, 0), terrain)
	monitor.advance(10.0)
	check(notices.size() == muted_count and not terrain.is_cell_walkable(Vector2i(19, 0)), "Muted dialogue never disables boundary enforcement")
	check(monitor.configure(actor, terrain, main.gameplay_modes, policy), "Restore shared production policy")
	monitor.set_physics_process(false)
	# Capture an actual Chiwis notice at gameplay resolution.
	actor.global_position = Vector2.ZERO
	monitor.advance(10.0)
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(18, 0), terrain)
	monitor.advance(0.1)
	if "--capture" in OS.get_cmdline_user_args():
		main.camera_rig.refresh_follow()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/output/eva_safety.png")
	main.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: " + failure)
	if failures.is_empty():
		print("PASS: %d EVA safety checks" % checks)
	quit(0 if failures.is_empty() else 1)
