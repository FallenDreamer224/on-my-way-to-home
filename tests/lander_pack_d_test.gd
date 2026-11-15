extends SceneTree
## Pixel integrity and 4x4 craft/decal alignment; no vehicle gameplay.

func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/lander_pack_d.json"))
	var seen: Dictionary = {}
	for record: Dictionary in manifest["assets"]:
		var path: String = "res://" + str(record["runtime_files"][0])
		if seen.has(record["asset_id"]):
			fail("Duplicate ID.")
			return
		seen[record["asset_id"]] = true
		var source := Image.new()
		if source.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
			fail("Cannot decode PNG: " + path)
			return
		var texture: Texture2D = load(path) as Texture2D
		if texture == null:
			fail("Missing imported texture: " + path)
			return
		var imported: Image = texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		imported.convert(Image.FORMAT_RGBA8)
		var expected := Vector2i(int(record["native_canvas_size_px"][0]), int(record["native_canvas_size_px"][1]))
		if source.get_size() != expected or imported.get_size() != expected or imported.has_mipmaps() or source.get_data() != imported.get_data() or FileAccess.get_sha256(path) != record["sha256"]:
			fail("PNG/native import integrity mismatch: " + path)
			return
		var anchor: Array = record["ground_anchor_px_from_image_top_left"]
		var offset: Array = record["sprite2d_offset_px"]
		if int(anchor[0]) < 0 or int(anchor[1]) < 0 or int(anchor[0]) >= expected.x or int(anchor[1]) >= expected.y or int(offset[0]) != -int(anchor[0]) or int(offset[1]) != -int(anchor[1]):
			fail("Invalid contact/offset: " + path)
			return
		var footprint: Array = record["explicit_footprint_grid_cells"]
		var cells: Dictionary = {}
		for cell: Array in record["occupied_cells"]:
			var key := Vector2i(int(cell[0]), int(cell[1]))
			if cells.has(key) or key.x < 0 or key.y < 0 or key.x >= int(footprint[0]) or key.y >= int(footprint[1]):
				fail("Invalid occupied cells: " + path)
				return
			cells[key] = true
		if cells.size() != int(footprint[0]) * int(footprint[1]):
			fail("Incomplete footprint: " + path)
			return
		if record.has("image_footprint_vertices_px"):
			var vertices: Array = record["image_footprint_vertices_px"]
			var outline: Array = record["footprint_outline_relative_to_reference_cell_px"]
			var front: Array = record["sorting_origin_relative_to_reference_cell_px"]
			for index: int in 4:
				var expected_vertex := Vector2i(int(anchor[0]) + int(outline[index][0]) - int(front[0]), int(anchor[1]) + int(outline[index][1]) - int(front[1]))
				if Vector2i(int(vertices[index][0]), int(vertices[index][1])) != expected_vertex:
					fail("Craft/decal footprint guide mismatch: " + path)
					return
		if record.has("attachment_anchor_px"):
			var attachment: Array = record["attachment_anchor_px"]
			if source.get_pixel(int(attachment[0]), int(attachment[1])).a == 0.0:
				fail("Ramp connection is not on its deck: " + path)
				return
	if seen.size() != 4:
		fail("Expected craft, ramp, decal and cargo PNGs.")
		return
	print("PASS: four lander-pack PNGs; exact native RGBA imports and hashes; no mipmaps; valid anchors, ramp connection and matching 4x4 craft/decal guides.")
	quit(0)

func fail(message: String) -> void:
	push_error(message)
	quit(1)
