extends SceneTree
## Installed-world topology, physical occupancy and live EVA wiring; no preview fixture.
var checks: int = 0
var failures: PackedStringArray = []
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label)
func run() -> void:
	var main: Node = GameEntry.new_game()
	root.add_child(main)
	await process_frame
	await physics_frame
	var base: LunarBaseWorld = main.lunar_base
	var ground: TerrainLayer = base.get_parent().get_parent().get_node("World/Terrain/Ground")
	var region := ground.region as LunarTutorialRegion
	var source: LunarTutorialRegion = load("res://resources/data/lunar_tutorial_region.tres")
	check(region != source and region.eva_limits != source.eva_limits, "Production configuration is per-session")
	check(source.cells.is_empty() and source.navigation_exclusions.is_empty() and source.installed_footprints.is_empty(), "Source region is never mutated")
	check(source.eva_limits.allowed_cells == Rect2i(-19,-19,38,38), "Original policy Resource is unchanged")
	check(region.eva_limits.allowed_cells == Rect2i(-19,-19,39,38), "Production mission perimeter remains unchanged")
	check(ground.terrain_cells == source.create_cells(), "All original logical terrain kinds remain byte-for-value equivalent")
	check(base.assembly.hulls.is_empty() and base.assembly.layout.modules.size() == 9 and base.assembly.equipment.size() == 2, "Only the entrance and lander remain outside; nine furnished compartments retained")
	check(region.installed_footprints.size() == 20 and region.navigation_exclusions.size() >= region.installed_footprints.size(), "Entrance/lander physical footprints and navigation clearance recorded separately")
	var lander: Node2D = base.assembly.equipment[&"moon_lander"]
	var lander_definition: ExteriorAssetDefinition = lander.get_meta("definition")
	check(lander.position == IsometricGrid.tile_to_position(Vector2i(-17,13))-Vector2(lander_definition.grid_origin) and lander.scale == Vector2.ONE and lander.rotation == 0, "Lander position, scale and orientation remain exact")
	var start: Vector2i = IsometricGrid.world_to_tile(main.astronaut.global_position, ground)
	var queue: Array[Vector2i] = [start]
	var seen: Dictionary[Vector2i,bool] = {start:true}
	var cursor: int = 0
	while cursor < queue.size():
		var at: Vector2i = queue[cursor];cursor += 1
		for step: Vector2i in IsometricGrid.CARDINAL_STEPS:
			var next: Vector2i = at + step
			if ground.is_cell_walkable(next) and not seen.has(next): seen[next]=true;queue.append(next)
	var walkable: int = 0
	var isolated: Array[Vector2i] = []
	for at: Vector2i in ground.terrain_cells:
		var surface: SurfaceCellData = region.surface_at(at, ground.terrain_cells[at])
		check(surface.walkable == ground.is_cell_walkable(at), "Surface metadata matches actual navigation")
		if ground.is_cell_walkable(at):
			walkable += 1
			if not seen.has(at): isolated.append(at)
			check(main.astronaut.walkability.is_position_walkable(IsometricGrid.tile_to_world(at,ground), main.astronaut.footprint_half_extent), "Astronaut fits every advertised safe cell")
			check(main.chiwis.planner.walkability.is_position_walkable(IsometricGrid.tile_to_world(at,ground), main.chiwis.footprint_half_extent), "Chiwis fits every advertised safe cell")
		if region.navigation_exclusions.has(at): check(not ground.is_cell_walkable(at), "Installed geometry/clearance blocks both actors")
		if region.installed_footprints.has(at): check(surface.occupant_id != &"", "Actual structure identity in environmental data")
	check(isolated.is_empty(), "Every advertised safe exterior cell connects to arrival; isolated="+str(isolated))
	check(walkable > 500, "Research outpost leaves substantial walkable exploration surface")
	var planner: TerrainRoutePlanner = main.chiwis.planner
	for obj: Node2D in base.assembly.hulls.values():
		check(obj.scale == Vector2.ONE and obj.rotation == 0, "Exterior hull retains native proportions")
	for item: Dictionary in base.assembly.layout.equipment:
		var obj: Node2D = base.assembly.equipment[StringName(item.id)]
		var definition: ExteriorAssetDefinition = obj.get_meta("definition")
		var origin := LunarBaseAssembly.cell(item.cell)
		var approachable: bool = false
		var reserved: Array[Vector2i] = definition.navigation_reserved_cells if definition.collision_enabled else definition.occupied_cells
		for offset: Vector2i in reserved:
			for step: Vector2i in IsometricGrid.CARDINAL_STEPS:
				var access: Vector2i = origin + offset + step
				if seen.has(access): approachable = true
		check(approachable, "Installation has a connected exterior approach: " + String(item.id))
		check(obj.scale == Vector2.ONE and obj.rotation == 0, "Installation retains native proportions: " + String(item.id))
	for child: WorldPickup in main.get_node("World/Entities/Props").get_children():
		check(not planner.route(main.chiwis.global_position, child.global_position).is_empty(), "Every preserved pickup is accessible")
	var director: HabitatDirector = main.get_node("Systems/HabitatDirector")
	check(not planner.route(main.chiwis.global_position, director.exterior_entry.global_position).is_empty(), "Real exterior hatch has a full-foot route")
	for id: StringName in director.definitions:
		var room: HabitatRoom = director.prepare_room(id)
		check(room is InteriorArtRoom and room.state == director.states[id], "Reviewed room and original persistent state: "+String(id))
		var floor_layer: TerrainLayer = room.get_node("Floor")
		var room_planner := TerrainRoutePlanner.new(floor_layer, main.astronaut.footprint_half_extent)
		var spawn := IsometricGrid.tile_to_world(HabitatRoom.cell(room.definition.spawn), floor_layer)
		for action: HabitatAction in room.actions.values():
			check(not room_planner.route(spawn, action.global_position).is_empty(), "All furnished room approach points are connected: "+String(id)+"/"+String(action.action_id))
	# Exercise warning/cooldown against the ACTUAL installed map and production policy.
	var monitor: EvaSafetyMonitor = main.get_node("Systems/EvaSafety")
	monitor.set_physics_process(false)
	main.astronaut.set_physics_process(false)
	main.chiwis.set_physics_process(false)
	var notices: Array[String] = []
	monitor.notice_requested.connect(func(text: String, _seconds: float) -> void: notices.append(text))
	var targets: Dictionary[int,Vector2i] = {}
	for at: Vector2i in ground.terrain_cells:
		if ground.is_cell_walkable(at): targets[region.eva_limits.zone_at(at)] = at
	main.astronaut.global_position = IsometricGrid.tile_to_world(targets[EvaSafetyLimits.Zone.WARNING], ground)
	monitor.advance(10)
	check(notices.size()==1, "Real installed map still emits an EVA warning")
	monitor.advance(.1)
	check(notices.size()==1, "Production warning does not spam")
	main.astronaut.global_position = IsometricGrid.tile_to_world(targets[EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY], ground)
	monitor.advance(10)
	check(notices.size()==2 and monitor.safe_return_direction != Vector2.ZERO, "Boundary guidance can route back around installed hulls")
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
	monitor.advance(10)
	check(notices.size()==2, "Management-camera activity does not issue astronaut warnings")
	main.queue_free()
	await process_frame
	for failure: String in failures: printerr("FAIL: "+failure)
	if failures.is_empty(): print("PASS: %d installed production occupancy/topology/EVA checks; %d walkable cells" % [checks,walkable])
	quit(0 if failures.is_empty() else 1)
