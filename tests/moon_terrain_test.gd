extends SceneTree
## Native atlas/raster regression; optional authorized external pack comparison for visual QA.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
const ATLAS: String = "res://assets/terrain/moon/moon_regolith_atlas_4x3.png"
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/moon_terrain.json"))
	_check(FileAccess.get_sha256(ATLAS) == manifest.chosen_sha256, "Runtime atlas is an unchanged copy of the supplied seam-fixed source")
	var raw: Image = Image.load_from_file(ProjectSettings.globalize_path(ATLAS))
	var texture: Texture2D = load(ATLAS)
	_check(raw.get_size() == Vector2i(256, 96) and not texture.get_image().has_mipmaps(), "Native lossless atlas dimensions and no mipmaps")
	_check(texture.get_image().get_data() == raw.get_data(), "Imported RGBA matches original PNG pixels including alpha edges")
	var settings: ConfigFile = ConfigFile.new()
	_check(settings.load(ATLAS + ".import") == OK, "Texture import configuration exists")
	for rule: Array in [["compress/mode", 0], ["mipmaps/generate", false], ["process/size_limit", 0], ["process/fix_alpha_border", false], ["process/premult_alpha", false]]:
		_check(settings.get_value("params", rule[0]) == rule[1], "Preserved texture import: " + rule[0])
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var modes: GameplayModeCoordinator = main.get_node("Systems/GameplayModes")
	var management: BaseManagementCameraRig = main.get_node("BaseManagementCameraRig")
	_check(ground.terrain_art != null and ground.tile_set.resource_path == "res://resources/terrain/moon_terrain.tres", "Native reusable Moon TileSet assigned")
	_check(ground.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and ground.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "Nearest filtering and no repeat")
	_check(ground.position == Vector2(-32, -16) and ground.scale == Vector2.ONE and ground.tile_set.tile_size == Vector2i(64, 32), "Original scale, tile size and native alignment")
	_check(ground.tile_set.get_source_count() == 4 and manifest.tile_regions.size() == 12, "Four stable source IDs, twelve art variants")
	_check(ground.tile_set.get_physics_layers_count() == 0 and ground.tile_set.get_navigation_layers_count() == 0, "Visual TileSet adds no collision/navigation behavior")
	for kind: int in 4:
		var source: TileSetAtlasSource = ground.tile_set.get_source(kind) as TileSetAtlasSource
		_check(source.texture == texture and source.get_tiles_count() == 3, "Each logical kind has three static variants on shared atlas")
		_check(source.texture_region_size == Vector2i(64, 32) and source.margins == Vector2i.ZERO and source.separation == Vector2i.ZERO, "Exact native tile regions without added margin/separation")
		for row: int in 3:
			var coords: Vector2i = Vector2i(kind, row)
			_check(source.has_tile(coords) and source.get_tile_data(coords, 0).texture_origin == Vector2i.ZERO, "Native center anchor, no art offset")
			var image: Image = raw.get_region(source.get_tile_texture_region(coords))
			var valid_mask: bool = true
			var opaque: int = 0
			for y: int in 32:
				for x: int in 64:
					var expected: float = 1.0 if absf((x + 0.5 - 32) / 32) + absf((y + 0.5 - 16) / 16) <= 1.0 else 0.0
					var alpha: float = image.get_pixel(x, y).a
					valid_mask = valid_mask and alpha == expected
					opaque += int(alpha == 1.0)
			_check(valid_mask and opaque == 1024, "Every supplied variant has an exact opaque tessellating diamond")
	var cells: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	var regions: Dictionary[Vector2i, Vector2i] = {}
	var used: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in cells:
		_check(ground.get_cell_source_id(cell) == cells[cell], "Logical kind/source ID preserved")
		regions[cell] = ground.get_cell_atlas_coords(cell)
		used[regions[cell]] = true
	_check(used.size() == 12, "All twelve source variants appear in the unchanged map")
	seed(361)
	var expected_random: int = randi()
	seed(361)
	ground.rebuild()
	_check(randi() == expected_random, "Visual variation does not consume gameplay RNG")
	_check(cells == ground.terrain_cells and cells == ground.region.create_cells(), "Original map data/layout preserved")
	for cell: Vector2i in cells:
		_check(ground.get_cell_atlas_coords(cell) == regions[cell], "Render-only variation deterministic across rebuild")
	var coverage: Dictionary = _coverage(ground)
	_check(coverage.gaps == 0 and coverage.overlaps == 0, "Full native map raster has no gaps/overlap/outside pixels")
	print("Moon raster coverage: " + JSON.stringify(coverage))
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if "--capture" in arguments:
		await _capture("moon_terrain_player_2x")
		modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
		for zoom: int in [1, 2, 3]:
			management.set_zoom_level(zoom)
			await _capture("moon_terrain_management_%dx" % zoom)
	var compare: int = arguments.find("--compare-pack")
	if compare >= 0 and compare + 1 < arguments.size():
		var standard: Image = Image.load_from_file(arguments[compare + 1].path_join("moon_regolith_atlas_4x3.png"))
		var original_coverage: Dictionary = _coverage(ground, standard)
		print("Standard source raster coverage: " + JSON.stringify(original_coverage))
		_check(original_coverage.gaps > 0 and original_coverage.overlaps > 0, "Comparison verifies standard source seam defects")
		var output: FileAccess = FileAccess.open("res://tests/output/moon_terrain_comparison.json", FileAccess.WRITE)
		output.store_string(JSON.stringify({"standard": original_coverage, "seam_fixed": coverage}, "  "))
		if "--capture" in arguments:
			var saved_art: TileSet = ground.tile_set
			ground.tile_set = saved_art.duplicate(true)
			var comparison_texture: ImageTexture = ImageTexture.create_from_image(standard)
			for kind: int in 4:
				(ground.tile_set.get_source(kind) as TileSetAtlasSource).texture = comparison_texture
			ground.update_internals()
			management.set_zoom_level(1)
			await _capture("moon_terrain_standard_management_1x")
			modes.request_mode(GameplayModeCoordinator.Mode.PLAYER)
			await _capture("moon_terrain_standard_player_2x")
			ground.tile_set = saved_art
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d Moon terrain checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _coverage(ground: TerrainLayer, override: Image = null) -> Dictionary:
	var pixels: Dictionary[Vector2i, int] = {}
	var low: Vector2i = Vector2i(2147483647, 2147483647)
	var high: Vector2i = -low
	for cell: Vector2i in ground.terrain_cells:
		var source: TileSetAtlasSource = ground.tile_set.get_source(ground.get_cell_source_id(cell)) as TileSetAtlasSource
		var atlas: Image = source.texture.get_image() if override == null else override
		var image: Image = atlas.get_region(source.get_tile_texture_region(ground.get_cell_atlas_coords(cell)))
		var corner: Vector2i = Vector2i(IsometricGrid.tile_to_world(cell, ground)) - Vector2i(32, 16)
		low = low.min(corner)
		high = high.max(corner + Vector2i(64, 32))
		for y: int in 32:
			for x: int in 64:
				if image.get_pixel(x, y).a > 0:
					var pixel: Vector2i = corner + Vector2i(x, y)
					pixels[pixel] = pixels.get(pixel, 0) + 1
	var gaps: int = 0
	var overlaps: int = 0
	for y: int in range(low.y, high.y):
		for x: int in range(low.x, high.x):
			var pixel: Vector2i = Vector2i(x, y)
			var expected: int = int(ground.terrain_cells.has(IsometricGrid.world_to_tile(Vector2(pixel) + Vector2(0.5, 0.5), ground)))
			var actual: int = pixels.get(pixel, 0)
			gaps += int(actual < expected)
			overlaps += int(actual > expected)
	return {"gaps": gaps, "overlaps_or_outside": overlaps, "overlaps": overlaps, "cells": ground.terrain_cells.size()}


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png("res://tests/output/" + name + ".png") == OK, "Capture " + name)


func _check(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures.append(label)
