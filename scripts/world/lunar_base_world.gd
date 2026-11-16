class_name LunarBaseWorld
extends Node
## Production composition adapter. Existing services retain all quantities and behavior.

const OUTPOST: PackedScene = preload("res://scenes/world/lunar_outpost.tscn")
var assembly: LunarBaseAssembly
var occlusion_guard: ExteriorOcclusionGuard
var spawn_cell: Vector2i
var companion_spawn_cell: Vector2i
var original_cells: Dictionary[Vector2i, int]
var _main: Node

func compose(main: Node, ground: TerrainLayer) -> void:
	_main = main
	original_cells = ground.terrain_cells.duplicate()
	assembly = OUTPOST.instantiate()
	main.get_node("World/Entities/Buildings").add_child(assembly)
	# Duplicate configuration per session; never add occupancy to a shared source Resource.
	var region: LunarTutorialRegion = ground.region.duplicate(true)
	region.cells = original_cells.duplicate()
	region.eva_limits = region.eva_limits.duplicate(true)
	region.eva_limits.allowed_cells = Rect2i(LunarBaseAssembly.cell(assembly.layout.mission_area.origin), LunarBaseAssembly.cell(assembly.layout.mission_area.size))
	region.navigation_exclusions = assembly.occupied.duplicate()
	for at: Array in assembly.layout.get("sealed_service_cells", []):
		region.navigation_exclusions[LunarBaseAssembly.cell(at)] = true
	region.eva_limits.return_cell = assembly.entry_cell()
	for at: Vector2i in assembly.occupied:
		for step: Vector2i in IsometricGrid.CARDINAL_STEPS:
			var access: Vector2i = at + step
			if region.eva_limits.allowed_cells.has_point(access) and not assembly.occupied.has(access):
				region.prepared_access_cells[access] = true
	for access: Array in assembly.layout.get("prepared_access_cells", []):
		region.prepared_access_cells[LunarBaseAssembly.cell(access)] = true
	ground.region = region
	ground.rebuild()
	assert(ground.terrain_cells == original_cells, "Outpost placement must preserve lunar terrain kinds")
	for obj: Node2D in assembly.hulls.values(): _record_footprint(obj, ground, region)
	for obj: Node2D in assembly.equipment.values(): _record_footprint(obj, ground, region)
	var pads := TileMapLayer.new()
	pads.name = "OutpostAccessPads"
	pads.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pads.tile_set = preload("res://resources/interiors/interior_floor.tres")
	pads.position = ground.position
	pads.z_index = 1
	main.get_node("World/Terrain").add_child(pads)
	for at: Array in assembly.layout.get("walkway_cells", []):
		var point := LunarBaseAssembly.cell(at)
		pads.set_cell(point, 1, Vector2i.ZERO)
		region.installed_footprints[point] = &"maintenance_walkway"
	spawn_cell = LunarBaseAssembly.cell(assembly.layout.spawn)
	companion_spawn_cell = LunarBaseAssembly.cell(assembly.layout.companion_spawn)
	for pickup: WorldPickup in main.get_node("World/Entities/Props").get_children():
		if assembly.layout.pickups.has(pickup.pickup_id):
			pickup.position = IsometricGrid.tile_to_world(LunarBaseAssembly.cell(assembly.layout.pickups[pickup.pickup_id]), ground)
	main.get_node("World/SiteLayout").hide()
	occlusion_guard = ExteriorOcclusionGuard.new()
	add_child(occlusion_guard)
	occlusion_guard.configure(assembly, main.astronaut, main.chiwis)

func _record_footprint(obj: Node2D, ground: TerrainLayer, region: LunarTutorialRegion) -> void:
	var definition: ExteriorAssetDefinition = obj.get_meta("definition") if obj.has_meta("definition") else null
	if definition == null:
		definition = load("res://resources/exterior/" + String(obj.name) + ".tres")
	var origin := IsometricGrid.world_to_tile(obj.global_position + Vector2(definition.grid_origin), ground)
	for offset: Vector2i in definition.occupied_cells:
		region.installed_footprints[origin + offset] = definition.asset_id

func bind_director(director: HabitatDirector) -> void:
	for module: Dictionary in assembly.layout.modules:
		var id := StringName(module.id)
		var scene: PackedScene = load("res://" + String(module.room_scene))
		# Registration is required in release builds too; never put its side effect in assert.
		if not director.register_prepared_room(id, scene, assembly.layout.room_port_overrides.get(String(id), {})):
			push_error("Could not register furnished production room: " + String(id))
	director.exterior_entry.position = IsometricGrid.tile_to_world(assembly.entry_cell(), director.outside_terrain())
	director.exterior_entry.display_name = "Outpost crew airlock"
	# The native hatch supplies the art; keep the existing interaction area and prompt.
	director.exterior_entry.self_modulate.a = 0
	for child: Node in director.exterior_entry.get_children():
		if child is Label: child.hide()
	assembly.bind_airlock(director)

func bind_utilities(utilities: UtilityService) -> void:
	for obj: Node2D in assembly.equipment.values():
		var indicator := obj.get_node_or_null("StateIndicator") as ExteriorStateIndicator
		var definition: ExteriorAssetDefinition = obj.get_meta("definition") if obj.has_meta("definition") else null
		if indicator == null or definition == null or not utilities.model.equipment.has(String(definition.utility_binding_id)): continue
		var equipment: UtilityEquipment = utilities.model.equipment[String(definition.utility_binding_id)]
		var refresh := func() -> void: indicator.display_equipment(equipment)
		utilities.model.changed.connect(refresh)
		indicator.show()
		refresh.call()
