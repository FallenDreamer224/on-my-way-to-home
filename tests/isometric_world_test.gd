extends SceneTree
## Mathematical and native-engine integration checks, without gameplay controllers.

const WORLD: PackedScene = preload("res://scenes/world/world.tscn")
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var world: Node2D = WORLD.instantiate() as Node2D
	# Keep the original 12x12 mathematical/raster fixture independent of production layout.
	world.get_node("Terrain/Ground").region = load("res://resources/data/lunar_test_region.tres")
	root.add_child(world)
	await process_frame
	var layer: TerrainLayer = world.get_node("Terrain/Ground") as TerrainLayer
	_check(layer.tile_set.tile_size == Vector2i(64, 32), "Native tile dimensions")
	_check(layer.tile_set.tile_shape == TileSet.TILE_SHAPE_ISOMETRIC, "Native isometric shape")
	_check(layer.tile_set.tile_layout == TileSet.TILE_LAYOUT_DIAMOND_DOWN, "Native Diamond Down layout")
	_check(layer.tile_set.tile_offset_axis == TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "Horizontal offset axis")
	_check(layer.position == Vector2(-32, -16), "Single documented layer alignment")
	_check(layer.map_to_local(Vector2i.ZERO) == Vector2(32, 16), "Verified Godot local origin")
	_check(IsometricGrid.tile_to_world(Vector2i.ZERO, layer) == Vector2.ZERO, "World origin at cell center")
	_check(IsometricGrid.tile_to_position(Vector2i(1, 0)) == Vector2(32, 16), "Column basis")
	_check(IsometricGrid.tile_to_position(Vector2i(0, 1)) == Vector2(-32, 16), "Row basis")
	for x: int in range(-20, 21):
		for y: int in range(-20, 21):
			var cell: Vector2i = Vector2i(x, y)
			var position: Vector2 = IsometricGrid.tile_to_position(cell)
			_check(IsometricGrid.position_to_tile(position) == cell, "Conceptual round trip %s" % cell)
			_check(IsometricGrid.tile_to_world(cell, layer) == position, "Native center agreement %s" % cell)
			_check(IsometricGrid.world_to_tile(position, layer) == cell, "Native round trip %s" % cell)
			# Points safely inside the diamond, including negative-space cells.
			for offset: Vector2 in [Vector2(15, 0), Vector2(-15, 0), Vector2(0, 7), Vector2(0, -7)]:
				_check(IsometricGrid.position_to_tile(position + offset) == cell, "Interior conceptual selection")
				_check(IsometricGrid.world_to_tile(position + offset, layer) == cell, "Interior native selection")
			var neighbors: Array[Vector2i] = IsometricGrid.neighbors(cell)
			_check(neighbors.size() == 4, "Four neighbors")
			for neighbor: Vector2i in neighbors:
				_check(cell in IsometricGrid.neighbors(neighbor), "Reciprocal adjacency")
				var delta: Vector2 = IsometricGrid.tile_to_position(neighbor) - position
				_check(absf(delta.x) == 32 and absf(delta.y) == 16, "Shared diamond edge alignment")
	_check(IsometricGrid.position_to_tile(Vector2(16, 8)) == Vector2i(1, 0), "Positive exact-half conceptual tie")
	_check(IsometricGrid.position_to_tile(Vector2(-16, -8)) == Vector2i.ZERO, "Negative exact-half conceptual tie")
	for boundary: Vector2 in [Vector2(16, 8), Vector2(-16, -8), Vector2(32, 0), Vector2(0, -16)]:
		var selected: Vector2i = IsometricGrid.world_to_tile(boundary, layer)
		for repeat: int in 5:
			_check(IsometricGrid.world_to_tile(boundary, layer) == selected, "Deterministic native edge selection")
	world.position = Vector2(173, -91)
	world.scale = Vector2(2, 2)
	for cell: Vector2i in [Vector2i(-8, 3), Vector2i.ZERO, Vector2i(7, -9)]:
		_check(IsometricGrid.world_to_tile(IsometricGrid.tile_to_world(cell, layer), layer) == cell, "Transformed layer round trip")
	world.position = Vector2.ZERO
	world.scale = Vector2.ONE
	_check(layer.region.validation_errors().is_empty(), "Region configuration valid")
	_check(layer.region.cells.is_empty(), "Shared fixture resource unchanged by startup")
	_check(layer.terrain_cells.size() == 144 and layer.get_used_cells().size() == 144, "12 x 12 fixture initialized")
	_check(layer.terrain_cells == layer.region.create_lunar_test_cells(), "Deterministic region generation")
	var used_kinds: Dictionary[int, bool] = {}
	for cell: Vector2i in layer.terrain_cells:
		used_kinds[layer.terrain_cells[cell]] = true
		_check(layer.get_cell_source_id(cell) == layer.terrain_cells[cell], "Data/render terrain kind agreement")
	_check(used_kinds.size() == 4, "All four logical terrain kinds represented")
	_check(layer.get_children().is_empty(), "No per-tile nodes")
	_check(not layer.is_processing(), "No per-frame terrain processing")
	_validate_coverage(layer)
	var replacements: Array[Texture2D] = []
	var replacement_fixture: TileSet = PlaceholderTerrain.create_tile_set()
	for kind: int in 4:
		var source: TileSetAtlasSource = replacement_fixture.get_source(kind) as TileSetAtlasSource
		replacements.append(source.texture)
	layer.replacement_textures = replacements
	layer.rebuild()
	for kind: int in 4:
		var source: TileSetAtlasSource = layer.tile_set.get_source(kind) as TileSetAtlasSource
		_check(source.texture == replacements[kind], "Replacement texture retained without resizing")
	var original: Dictionary[Vector2i, int] = layer.terrain_cells.duplicate()
	layer.rebuild()
	_check(layer.terrain_cells == original and layer.get_used_cells().size() == original.size(), "Rebuild idempotence")
	var authored: TerrainRegion = TerrainRegion.new()
	authored.origin = Vector2i(-2, 1)
	authored.size = Vector2i(3, 4)
	authored.cells[Vector2i(-1, 2)] = TerrainRegion.Kind.DUST_PATCH
	layer.region = authored
	layer.rebuild()
	_check(layer.get_used_cells().size() == 1, "Sparse authored data supported")
	_check(layer.get_cell_source_id(Vector2i(-1, 2)) == TerrainRegion.Kind.DUST_PATCH, "Authored kind rendered")
	layer.terrain_cells[Vector2i(-1, 2)] = TerrainRegion.Kind.REGOLITH
	_check(authored.cells[Vector2i(-1, 2)] == TerrainRegion.Kind.DUST_PATCH, "Authored configuration isolated")
	authored.cells[Vector2i(20, 20)] = 99
	_check(authored.validation_errors().size() == 2, "Out-of-bounds and invalid kind detected")
	var other_size: TerrainRegion = TerrainRegion.new()
	other_size.origin = Vector2i(-10, 8)
	other_size.size = Vector2i(3, 7)
	_check(other_size.create_lunar_test_cells().size() == 21, "Configurable dimensions and origin")
	world.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d isometric world checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _validate_coverage(layer: TerrainLayer) -> void:
	# Rasterize the actual native-size textures at their world centers. Verify every
	# sample in the declared region is covered exactly once, including shared edges.
	var coverage: Dictionary[Vector2i, int] = {}
	for cell: Vector2i in layer.terrain_cells:
		var source: TileSetAtlasSource = layer.tile_set.get_source(layer.terrain_cells[cell]) as TileSetAtlasSource
		var image: Image = source.texture.get_image().get_region(source.get_tile_texture_region(layer.get_cell_atlas_coords(cell)))
		_check(image.get_size() == Vector2i(64, 32) and not image.has_mipmaps(), "Native unmipped texture")
		var corner: Vector2i = Vector2i(IsometricGrid.tile_to_position(cell)) - Vector2i(32, 16)
		for y: int in 32:
			for x: int in 64:
				if image.get_pixel(x, y).a == 1.0:
					var pixel: Vector2i = corner + Vector2i(x, y)
					coverage[pixel] = coverage.get(pixel, 0) + 1
	var gaps: int = 0
	var overlaps: int = 0
	for y: int in range(-208, 176):
		for x: int in range(-384, 384):
			var pixel: Vector2i = Vector2i(x, y)
			var cell: Vector2i = IsometricGrid.position_to_tile(Vector2(pixel) + Vector2(0.5, 0.5))
			var expected: int = 1 if layer.terrain_cells.has(cell) else 0
			var actual: int = coverage.get(pixel, 0)
			if actual < expected:
				gaps += 1
			if actual > expected:
				overlaps += 1
	_check(gaps == 0, "No raster gaps between diamond tiles (%d)" % gaps)
	_check(overlaps == 0, "No raster overlaps or pixels outside region (%d)" % overlaps)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
