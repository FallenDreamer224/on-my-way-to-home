extends SceneTree
## Asset-only import integrity and declared footprint/anchor validation.

func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/base_pack_c.json"))
	var seen: Dictionary = {}
	for record: Dictionary in manifest["assets"]:
		var path: String = "res://" + str(record["runtime_files"][0])
		if seen.has(record["asset_id"]):
			fail("Duplicate asset ID.")
			return
		seen[record["asset_id"]] = true
		var source := Image.new()
		if source.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
			fail("Cannot decode: " + path)
			return
		var texture: Texture2D = load(path) as Texture2D
		if texture == null:
			fail("Missing imported texture: " + path)
			return
		var imported: Image = texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		imported.convert(Image.FORMAT_RGBA8)
		var expected := Vector2i(int(record["native_canvas_size_px"][0]), int(record["native_canvas_size_px"][1]))
		if source.get_size() != expected or imported.get_size() != expected:
			fail("Unexpected dimensions: " + path)
			return
		if imported.has_mipmaps() or source.get_data() != imported.get_data() or FileAccess.get_sha256(path) != record["sha256"]:
			fail("PNG/import integrity mismatch: " + path)
			return
		var bounds: Array = record["opaque_bounds_px"]
		var anchor: Array = record["ground_anchor_px_from_image_top_left"]
		var offset: Array = record["sprite2d_offset_px"]
		if int(anchor[1]) != int(bounds[1]) + int(bounds[3]) or int(offset[0]) != -int(anchor[0]) or int(offset[1]) != -int(anchor[1]):
			fail("Anchor/offset mismatch: " + path)
			return
		if int(anchor[0]) < int(bounds[0]) or int(anchor[0]) >= int(bounds[0]) + int(bounds[2]) or int(anchor[1]) >= expected.y:
			fail("Invalid base contact: " + path)
			return
		var footprint: Array = record["explicit_footprint_grid_cells"]
		var occupied: Array = record["occupied_cells"]
		var cells: Dictionary = {}
		for cell: Array in occupied:
			var key := Vector2i(int(cell[0]), int(cell[1]))
			if cells.has(key) or key.x < 0 or key.y < 0 or key.x >= int(footprint[0]) or key.y >= int(footprint[1]):
				fail("Invalid occupied cells: " + path)
				return
			cells[key] = true
		if cells.size() != int(footprint[0]) * int(footprint[1]):
			fail("Incomplete rectangular footprint: " + path)
			return
		var front: Array = record["sorting_origin_relative_to_reference_cell_px"]
		if int(front[0]) != (int(footprint[0]) - int(footprint[1])) * 32 or int(front[1]) != (int(footprint[0]) + int(footprint[1]) - 1) * 16:
			fail("Footprint projection mismatch: " + path)
			return
	if seen.size() != 10:
		fail("Expected ten base assets.")
		return
	print("PASS: ten base assets; exact native RGBA imports and hashes; no mipmaps; valid contact offsets and explicit 64x32-grid footprint records.")
	quit(0)

func fail(message: String) -> void:
	push_error(message)
	quit(1)
