extends SceneTree
## Read-only pack audit. --build saves the TileSet after the byte-identical atlas is imported.

const ATLAS: String = "res://assets/terrain/moon/moon_regolith_atlas_4x3.png"
const TILE_SET: String = "res://resources/terrain/moon_terrain.tres"
const MANIFEST: String = "res://art/imports/moon_terrain.json"


func _initialize() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	var source: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("assets/tiles/moon_terrain")
	var option: int = arguments.find("--source-root")
	if option >= 0 and option + 1 < arguments.size():
		source = arguments[option + 1]
	var hashes: Array[Dictionary] = []
	_hash_folder(source, "", hashes)
	var supplied: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(source.path_join("manifest.json")))
	assert(supplied.tile_dimensions == [64.0, 32.0] and supplied.number_of_variations == 12)
	var standard: Image = Image.load_from_file(source.path_join("moon_regolith_atlas_4x3.png"))
	var fixed: Image = Image.load_from_file(source.path_join("optional_seam_fixed/moon_regolith_atlas_4x3.png"))
	assert(standard.get_size() == Vector2i(256, 96) and fixed.get_size() == Vector2i(256, 96))
	var variants: Array[Dictionary] = []
	for index: int in 12:
		var coords: Vector2i = Vector2i(index % 4, index / 4)
		var region: Rect2i = Rect2i(coords * Vector2i(64, 32), Vector2i(64, 32))
		var original: Image = standard.get_region(region)
		var corrected: Image = fixed.get_region(region)
		for entry: Array in [["tiles", original], ["optional_seam_fixed/tiles", corrected]]:
			var tile: Image = Image.load_from_file(source.path_join("%s/moon_regolith_%02d.png" % [entry[0], index + 1]))
			assert(tile.get_size() == Vector2i(64, 32) and tile.get_data() == (entry[1] as Image).get_data(), "Individual tile/atlas mismatch")
		var added: int = 0
		var removed: int = 0
		var opaque: int = 0
		for y: int in 32:
			for x: int in 64:
				var expected: bool = absf((x + 0.5 - 32) / 32) + absf((y + 0.5 - 16) / 16) <= 1.0
				var a: Color = original.get_pixel(x, y)
				var b: Color = corrected.get_pixel(x, y)
				assert(b.a == (1.0 if expected else 0.0), "Fixed tile does not tessellate")
				if a.a > 0 and b.a > 0:
					assert(a == b, "Supplied correction changed interior pixels")
				if b.a > 0:
					opaque += 1
				if a.a == 0 and b.a > 0:
					added += 1
				if a.a > 0 and b.a == 0:
					removed += 1
		assert(added == supplied.tiles[index].new_edge_pixels and removed == supplied.tiles[index].removed_outside_mask)
		variants.append({"variant": index + 1, "atlas_coords": [coords.x, coords.y], "region_px": [region.position.x, region.position.y, 64, 32], "source_id": coords.x, "center_anchor_px": [32, 16], "opaque_pixels": opaque, "supplied_added_edge_pixels": added, "supplied_removed_outside_pixels": removed})
	var manifest: Dictionary = {
		"asset_id": "moon_regolith", "standards_version": "1.0.0", "category": "terrain_atlas",
		"source_provider": "User-supplied Pixelorama Moon terrain pack", "source_files": hashes,
		"runtime_files": [ATLAS.trim_prefix("res://"), TILE_SET.trim_prefix("res://")],
		"usage_terms": "Supplied and authorized for this project; no separate redistribution license inferred",
		"native_canvas_size_px": [256, 96], "tile_size_px": [64, 32], "columns": 4, "rows": 3,
		"margin_px": 0, "separation_px": 0, "ground_footprint_grid_cells": [1, 1], "center_anchor_px": [32, 16],
		"physical_scale_intent": "Native unit scale; each diamond occupies one existing ground cell",
		"chosen_source": "optional_seam_fixed/moon_regolith_atlas_4x3.png",
		"chosen_sha256": FileAccess.get_sha256(source.path_join("optional_seam_fixed/moon_regolith_atlas_4x3.png")),
		"review_status": "Verified all individual tiles against both atlases; fixed masks tessellate exactly; shared opaque pixels unchanged",
		"exception": null, "supplied_pack_manifest": supplied, "tile_regions": variants,
		"source_kind_order": ["regolith", "light_regolith", "dark_regolith", "dust_patch"],
		"variation_policy": "Keep source ID equal to logical kind; select one of three atlas rows by stable cell hash, without RNG or logical map edits",
		"rendering": {"filter": "nearest", "compression": "lossless", "mipmaps": false, "rescale": false, "fix_alpha_border": false}
	}
	DirAccess.make_dir_recursive_absolute("res://art/imports")
	var file: FileAccess = FileAccess.open(MANIFEST, FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))
	for record: Dictionary in hashes:
		assert(FileAccess.get_sha256(source.path_join(record.path)) == record.sha256, "External pack changed during audit")
	if "--build" in arguments:
		assert(FileAccess.get_sha256(ATLAS) == manifest.chosen_sha256, "Internal atlas must be an exact source copy")
		_build()
	print("PASS: audited %d external files and 24 individual tiles; all 12 seam-fixed masks/interiors verified." % hashes.size())
	for variant: Dictionary in variants:
		print("Variant %02d: supplied correction adds %d / removes %d edge pixels; %d opaque pixels" % [variant.variant, variant.supplied_added_edge_pixels, variant.supplied_removed_outside_pixels, variant.opaque_pixels])
	quit()


func _hash_folder(root_path: String, folder: String, result: Array[Dictionary]) -> void:
	for file: String in DirAccess.get_files_at(root_path.path_join(folder)):
		var relative: String = folder.path_join(file)
		result.append({"path": relative, "sha256": FileAccess.get_sha256(root_path.path_join(relative))})
	for directory: String in DirAccess.get_directories_at(root_path.path_join(folder)):
		_hash_folder(root_path, folder.path_join(directory), result)


func _build() -> void:
	var texture: Texture2D = load(ATLAS)
	assert(texture != null and texture.get_size() == Vector2(256, 96))
	var terrain: TileSet = TileSet.new()
	terrain.tile_size = Vector2i(64, 32)
	terrain.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	terrain.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	terrain.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL
	for kind: int in 4:
		var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(64, 32)
		for row: int in 3:
			atlas.create_tile(Vector2i(kind, row))
		terrain.add_source(atlas, kind)
	DirAccess.make_dir_recursive_absolute("res://resources/terrain")
	assert(ResourceSaver.save(terrain, TILE_SET) == OK)
	print("Saved four-kind, twelve-variant Moon TileSet.")
