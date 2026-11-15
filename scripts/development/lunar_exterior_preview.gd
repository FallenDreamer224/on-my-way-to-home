extends Node2D
## Native 1x asset inspection bays. No production scene, inventory, utility or terrain edits.
const THEME: Theme = preload("res://resources/ui/mission_os_theme.tres")
const GUIDE: Script = preload("res://scripts/development/exterior_guides.gd")
const GROUND: PackedScene = preload("res://scenes/world/terrain_layer.tscn")
const ASTRONAUT_ART: CharacterArtProfile = preload("res://resources/characters/astronaut_art.tres")
const CHIWIS_ART: CharacterArtProfile = preload("res://resources/characters/chiwis_art.tres")
const BAY: Vector2i = Vector2i(960, 540)
const VIEWS: PackedStringArray = ["habitat", "power", "lander", "science", "props", "safety", "sorting", "states"]
var camera: Camera2D
var entries: Dictionary[String, Node2D] = {}
var guides: Array[Node2D] = []
var view_id: String = "habitat"

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var stages: Array[Node2D] = []
	for index: int in VIEWS.size():
		var stage := Node2D.new()
		stage.name = VIEWS[index].to_pascal_case()
		stage.position = Vector2(index % 2 * BAY.x, index / 2 * BAY.y)
		add_child(stage)
		stages.append(stage)
		var floor_layer: TerrainLayer = GROUND.instantiate()
		floor_layer.region = MenuTerrainRegion.new()
		floor_layer.region.rows = Vector2i(-11, 16)
		floor_layer.region.columns = Vector2i(-16, 16)
		floor_layer.position += Vector2(480, 250)
		floor_layer.z_index = -10
		stage.add_child(floor_layer)
		var entities := Node2D.new()
		entities.name = "Entities"
		entities.y_sort_enabled = true
		stage.add_child(entities)
		label(stage, "%d  %s  /  NATIVE 1X" % [index + 1, VIEWS[index].to_upper()], Vector2(20, 12), 15)
		label(stage, "1-8: inspection bay   G: guides   white: pivot   green: footprint   cyan: access   amber: service", Vector2(20, 34))
		label(stage, "Prepared art only. Labels/markers are development overlays; no new equipment simulation.", Vector2(20, 516))
		var reference_y: int = 140 if index in [4, 5] else 474
		_actor(entities, ASTRONAUT_ART, Vector2(418, reference_y), "Astronaut")
		_actor(entities, CHIWIS_ART, Vector2(474, reference_y), "Chiwis")
		label(stage, "64x64 original frames / shared ground origin", Vector2(340, reference_y + 17))
	# Shared shell roles respect the compact existing interior architecture.
	place(stages[0], "small_habitat_module", Vector2(202, 310))
	place(stages[0], "airlock_module", Vector2(474, 315))
	place(stages[0], "greenhouse_module", Vector2(768, 315))
	label(stages[0], "Habitat shell also serves research / engineering / shelter roles. Closed hatches only; passage art deferred.", Vector2(35, 370))
	place(stages[1], "solar_panel_array", Vector2(210, 240))
	place(stages[1], "battery_power_unit", Vector2(430, 240))
	place(stages[1], "small_connector_utility_box", Vector2(597, 240))
	place(stages[1], "work_control_console", Vector2(773, 240))
	place(stages[1], "radiator_bank", Vector2(210, 420))
	place(stages[1], "eclss_service_cabinet", Vector2(592, 415))
	place(stages[1], "utility_oxygen_tank", Vector2(778, 420))
	place(stages[2], "landing_marker_decal", Vector2(310, 406), false)
	place(stages[2], "moon_lander", Vector2(310, 406))
	place(stages[2], "deployed_ramp", Vector2(560, 420))
	place(stages[2], "support_cargo_container", Vector2(635, 250))
	place(stages[2], "storage_crate_large", Vector2(790, 270))
	place(stages[2], "tool_case", Vector2(653, 390))
	place(stages[2], "utility_crate", Vector2(796, 390))
	place(stages[3], "field_sensor_tripod", Vector2(210, 280))
	place(stages[3], "work_control_console", Vector2(430, 280))
	place(stages[3], "communications_antenna", Vector2(680, 280))
	place(stages[3], "lunar_sample", Vector2(200, 412))
	place(stages[3], "small_resource_canister", Vector2(700, 412))
	place(stages[3], "small_equipment_box", Vector2(830, 412))
	label(stages[3], "Field sampling kit = existing cases + sample canister + sensor. No scientific performance specifications.", Vector2(30, 330))
	var props: PackedStringArray = ["lunar_sample", "metal_scrap", "supply_pack", "small_equipment_box", "tool_case", "small_resource_canister", "utility_crate", "rock_cluster", "broken_machine_part", "beacon_marker"]
	for index: int in props.size():
		place(stages[4], props[index], Vector2(110 + index % 5 * 180, 240 + index / 5 * 156))
	place(stages[5], "light_beacon_pole", Vector2(160, 248))
	place(stages[5], "beacon_marker", Vector2(338, 248))
	var tiles: PackedStringArray = ["small_crater_overlay", "rocky_patch_overlay", "dark_basalt_patch_overlay", "worn_footpath_tile", "base_floor_panel_tile", "base_floor_edge_tile", "base_floor_edge_tile_sw", "base_floor_edge_tile_nw", "base_floor_edge_tile_ne", "utility_floor_pad_tile", "small_dust_debris_overlay", "landing_marked_ground_tile", "hazard_stripe_floor_tile"]
	for index: int in tiles.size():
		var tile: Node2D = place(stages[5], tiles[index], Vector2(110 + index % 5 * 180, 320 + index / 5 * 56), false)
		label(stages[5], tiles[index].replace("_tile", "").replace("_overlay", "").replace("_", " ").left(23), tile.position + Vector2(-65, 22), 9)
	var sorted_habitat: Node2D = place(stages[6], "small_habitat_module", Vector2(410, 320))
	var sorting_entities: Node2D = stages[6].get_node("Entities")
	_actor(sorting_entities, ASTRONAUT_ART, sorted_habitat.position + Vector2(64, -92), "BehindReference")
	_actor(sorting_entities, CHIWIS_ART, sorted_habitat.position + Vector2(20, 18), "FrontReference")
	place(stages[6], "storage_crate_large", Vector2(740, 310))
	label(stages[6], "Shared Y-sort: astronaut behind shell / Chiwis in front. Solid floor envelopes reserve movement clearance.", Vector2(30, 390))
	for index: int in 4:
		var item: Node2D = place(stages[7], "battery_power_unit", Vector2(160 + index * 210, 288), false, str(index))
		var indicator: ExteriorStateIndicator = item.get_node("StateIndicator")
		indicator.show()
		indicator.state = index as ExteriorStateIndicator.State
		label(stages[7], ["OPERATIONAL", "DISABLED", "DAMAGED", "MAINTENANCE"][index], item.position + Vector2(-55, 38))
	label(stages[7], "Separate static service markers preserve all source pixels. Optional adapter reads existing UtilityEquipment only.", Vector2(30, 375))
	camera = Camera2D.new()
	camera.name = "InspectionCamera"
	camera.position_smoothing_enabled = false
	add_child(camera)
	camera.make_current()
	show_view("habitat")

func show_view(id: String) -> bool:
	var index: int = VIEWS.find(id)
	if index < 0: return false
	view_id = id
	camera.position = Vector2(index % 2 * BAY.x + BAY.x / 2, index / 2 * BAY.y + BAY.y / 2)
	camera.force_update_scroll()
	return true

func place(stage: Node2D, id: String, at: Vector2, show_name: bool = true, suffix: String = "") -> Node2D:
	var prefab: PackedScene = load("res://scenes/exterior/%s.tscn" % id)
	var item: Node2D = prefab.instantiate()
	var definition: ExteriorAssetDefinition = item.get_meta(&"definition")
	# Snap the reference cell, not the padded sprite or frontmost contact vertex.
	var reference: Vector2 = at + Vector2(definition.grid_origin) - Vector2(480, 250)
	var cell: Vector2i = IsometricGrid.position_to_tile(reference)
	at = Vector2((cell.x - cell.y) * 32, (cell.x + cell.y) * 16) + Vector2(480, 250) - Vector2(definition.grid_origin)
	item.position = at
	stage.get_node("Entities").add_child(item)
	entries[stage.name.to_snake_case() + "/" + id + suffix] = item
	var guide := Node2D.new()
	guide.set_script(GUIDE)
	guide.definition = definition
	guide.position = at
	guide.z_index = -2
	stage.add_child(guide)
	guides.append(guide)
	if show_name:
		label(stage, id.replace("_", " "), at + Vector2(-70, 38))
	return item

func _actor(parent: Node2D, profile: CharacterArtProfile, at: Vector2, actor_name: String) -> void:
	var root := Node2D.new()
	root.name = actor_name
	root.position = at
	var visual := AstronautAnimation.new()
	visual.art_profile = profile
	root.add_child(visual)
	parent.add_child(root)
	visual.select_state(&"idle", &"s")

func label(parent: Node2D, text: String, at: Vector2, font_size: int = 11) -> void:
	var caption := Label.new()
	caption.theme = THEME
	caption.add_theme_font_size_override(&"font_size", font_size)
	caption.add_theme_color_override(&"font_color", Color("dce4e5") if at.y < 60 or at.y > 508 else Color("18232c"))
	caption.text = text
	caption.position = at.round()
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(caption)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8:
			show_view(VIEWS[event.keycode - KEY_1])
		elif event.keycode == KEY_G:
			for guide: Node2D in guides: guide.visible = not guide.visible
