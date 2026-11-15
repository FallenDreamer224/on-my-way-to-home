extends SceneTree
## Native alpha/mask/atlas integrity plus an isolated TileMapLayer assembly preview.

var _checks: int = 0
var _failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/terrain_pack_e.json"))
	var atlas: Image = (load("res://" + str(manifest["atlas"]["file"])) as Texture2D).get_image()
	atlas.convert(Image.FORMAT_RGBA8)
	var images: Dictionary[String, Image] = {}
	var indices: Dictionary[String, int] = {}
	var seen: Dictionary = {}
	for record: Dictionary in manifest["assets"]:
		var path: String = "res://" + str(record["runtime_files"][0])
		var name: String = str(record["asset_id"]).trim_prefix("terrain_pack_e_")
		_check(not seen.has(name), "Unique ID " + name)
		seen[name] = true
		var source := Image.new()
		_check(source.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK, "Decode PNG " + name)
		var texture: Texture2D = load(path) as Texture2D
		var imported: Image = texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		imported.convert(Image.FORMAT_RGBA8)
		_check(source.get_size() == Vector2i(64,32) and imported.get_size() == Vector2i(64,32), "Native 64x32 " + name)
		_check(not imported.has_mipmaps() and source.get_data() == imported.get_data(), "Exact native RGBA import " + name)
		_check(FileAccess.get_sha256(path) == record["sha256"], "Source hash " + name)
		var region: Array = record["atlas_region_px"]
		_check(atlas.get_region(Rect2i(int(region[0]),int(region[1]),64,32)).get_data() == source.get_data(), "Unscaled atlas copy " + name)
		var opaque: int = 0
		var partial: int = 0
		var outside: int = 0
		for y: int in 32:
			for x: int in 64:
				var alpha: float = source.get_pixel(x,y).a
				if alpha > 0.0:
					opaque += 1
					partial += int(alpha < 1.0)
					outside += int(not _mask(x,y))
		_check(partial == 0 and outside == 0 and opaque == int(record["opaque_pixels"]), "Binary alpha inside canonical diamond " + name)
		if str(record["role"]).begins_with("opaque_"):
			_check(opaque == 1024, "Full ground diamond " + name)
		else:
			_check(opaque > 0 and opaque < 1024, "Transparent feature without baked ground " + name)
		var anchor: Array = record["ground_anchor_px_from_image_top_left"]
		var cells: Array = record["occupied_cells"]
		_check(Vector2i(int(anchor[0]),int(anchor[1])) == Vector2i(32,16) and cells.size() == 1 and int(cells[0][0]) == 0 and int(cells[0][1]) == 0, "Center and logical footprint " + name)
		indices[name] = images.size()
		images[name] = source
	_check(images.size() == 13, "Thirteen assets cover ten categories plus edge orientations")
	for cell: Array in manifest["atlas"]["empty_cells"]:
		_check(atlas.get_region(Rect2i(int(cell[0])*64,int(cell[1])*32,64,32)).is_invisible(), "Unused atlas region transparent")
	for before: Dictionary in JSON.parse_string(FileAccess.get_file_as_string("res://" + str(manifest["original_terrain_hash_record"]))):
		if str(before["path"]) == "scripts/world/terrain_layer.gd":
			# This hash records the one-time art-import checkpoint, before 0.8B added
			# authored walkability. Keep the historical record, but test current code
			# behavior rather than prohibiting the documented later implementation.
			await _validate_current_terrain_contract()
		elif str(before["path"]) == "resources/terrain/moon_terrain.tres":
			# Godot saved resource UIDs after the original import. Compare all authored
			# TileSet content, ignoring only those identity annotations.
			var canonical: String = FileAccess.get_file_as_string("res://" + str(before["path"]))
			var uid_annotation := RegEx.new()
			uid_annotation.compile(' uid="uid://[^"]+"')
			canonical = uid_annotation.sub(canonical, "", true)
			_check(canonical.sha256_text() == before["sha256"], "Original TileSet content unchanged except saved UIDs")
		else:
			_check(FileAccess.get_sha256("res://" + str(before["path"])) == before["sha256"], "Original terrain unchanged " + str(before["path"]))
	# Shared-edge raster proof: two adjacent full panels exactly fill their expected union.
	var counts: Dictionary[Vector2i,int] = {}
	var floor_image: Image = images["base_floor_panel_tile"]
	for origin: Vector2i in [Vector2i.ZERO,Vector2i(32,16)]:
		for y: int in 32:
			for x: int in 64:
				if floor_image.get_pixel(x,y).a > 0.0:
					var pixel: Vector2i = origin + Vector2i(x,y)
					counts[pixel] = counts.get(pixel,0) + 1
	_check(counts.size() == 2048, "Adjacent opaque panels have no seam overlap")
	for value: int in counts.values():
		_check(value == 1, "Exactly one floor contribution per covered pixel")
	var path_image: Image = images["worn_footpath_tile"]
	_check(path_image.get_pixel(47,23).a == 1.0 and path_image.get_pixel(16,8).a == 1.0, "Column-axis path endpoints opaque for continuation")
	if "--capture" in OS.get_cmdline_user_args():
		await _render_preview(manifest,indices)
	if _failures.is_empty():
		print("PASS: %d terrain expansion checks" % _checks)
		quit(0)
	else:
		for message: String in _failures:
			printerr("FAIL: " + message)
		quit(1)

func _mask(x: int,y: int) -> bool:
	return absi(2*x-63)+2*absi(2*y-31) <= 64


func _validate_current_terrain_contract() -> void:
	var terrain: TerrainLayer = load("res://scenes/world/terrain_layer.tscn").instantiate()
	terrain.region = load("res://resources/data/lunar_tutorial_region.tres")
	root.add_child(terrain)
	_check(terrain is TileMapLayer and terrain.tile_set.tile_size == Vector2i(64,32), "Current terrain retains native 64x32 TileMapLayer")
	_check(terrain.terrain_cells.size() == 1600 and terrain.get_used_cells().size() == 1600, "Authorized 0.8B map renders complete logical cells")
	var blocked: int = 0
	for cell: Vector2i in terrain.terrain_cells:
		_check(terrain.is_cell_walkable(cell) == terrain.region.is_cell_walkable(cell), "Current authored walkability retained")
		blocked += int(not terrain.is_cell_walkable(cell))
	_check(blocked > 0, "Current map preserves restricted/crater cells")
	terrain.queue_free()
	await process_frame

func _render_preview(manifest: Dictionary,indices: Dictionary[String,int]) -> void:
	var scene := Node2D.new()
	root.add_child(scene)
	var ground: TerrainLayer = (load("res://scenes/world/terrain_layer.tscn") as PackedScene).instantiate()
	scene.add_child(ground)
	var art := TileSet.new()
	art.tile_size = Vector2i(64,32)
	art.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	art.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	art.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL
	for index: int in manifest["assets"].size():
		var record: Dictionary = manifest["assets"][index]
		var source := TileSetAtlasSource.new()
		source.texture = load("res://" + str(record["runtime_files"][0])) as Texture2D
		source.texture_region_size = Vector2i(64,32)
		source.create_tile(Vector2i.ZERO)
		art.add_source(source,index)
	var floor_layer: TileMapLayer = _layer(scene,art)
	var features: TileMapLayer = _layer(scene,art)
	var edge_layers: Array[TileMapLayer] = []
	for index: int in 4:
		edge_layers.append(_layer(scene,art))
	# A three-by-three tutorial floor with transparent boundary strips and composable corners.
	for column: int in range(-1,2):
		for row: int in range(-1,2):
			var cell := Vector2i(column,row)
			var name: String = "utility_floor_pad_tile" if cell == Vector2i.ZERO else "base_floor_panel_tile"
			floor_layer.set_cell(cell,indices[name],Vector2i.ZERO)
			if column == 1: edge_layers[0].set_cell(cell,indices["base_floor_edge_tile"],Vector2i.ZERO)
			if row == 1: edge_layers[1].set_cell(cell,indices["base_floor_edge_tile_sw"],Vector2i.ZERO)
			if column == -1: edge_layers[2].set_cell(cell,indices["base_floor_edge_tile_nw"],Vector2i.ZERO)
			if row == -1: edge_layers[3].set_cell(cell,indices["base_floor_edge_tile_ne"],Vector2i.ZERO)
	features.set_cell(Vector2i(-3,-1),indices["small_crater_overlay"],Vector2i.ZERO)
	features.set_cell(Vector2i(-3,1),indices["rocky_patch_overlay"],Vector2i.ZERO)
	features.set_cell(Vector2i(-1,3),indices["dark_basalt_patch_overlay"],Vector2i.ZERO)
	features.set_cell(Vector2i(1,3),indices["small_dust_debris_overlay"],Vector2i.ZERO)
	for column: int in range(2,5):
		features.set_cell(Vector2i(column,0),indices["worn_footpath_tile"],Vector2i.ZERO)
	floor_layer.set_cell(Vector2i(3,-2),indices["landing_marked_ground_tile"],Vector2i.ZERO)
	floor_layer.set_cell(Vector2i(3,-1),indices["hazard_stripe_floor_tile"],Vector2i.ZERO)
	var camera := Camera2D.new()
	camera.zoom = Vector2(2,2)
	scene.add_child(camera)
	await process_frame
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png("res://tests/output/terrain_pack_e_assembly_2x.png") == OK, "Capture 2x TileMap assembly")
	camera.zoom = Vector2.ONE
	await process_frame
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png("res://tests/output/terrain_pack_e_assembly_1x.png") == OK, "Capture native TileMap assembly")
	scene.queue_free()
	await process_frame

func _layer(parent: Node,art: TileSet) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.tile_set = art
	layer.position = Vector2(-32,-16)
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	parent.add_child(layer)
	return layer

func _check(value: bool,label: String) -> void:
	_checks += 1
	if not value: _failures.append(label)
