extends SceneTree
## Native PNG/import and ground-anchor checks; no world mutation or generation.

func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/props_pack_b.json"))
	var seen: Dictionary = {}
	for record: Dictionary in manifest["assets"]:
		var path: String = "res://" + str(record["runtime_files"][0])
		if seen.has(record["asset_id"]):
			fail("Duplicate prop ID.")
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
		if source.get_size() != Vector2i(64, 64) or imported.get_size() != Vector2i(64, 64):
			fail("Unexpected dimensions: " + path)
			return
		if imported.has_mipmaps() or source.get_data() != imported.get_data():
			fail("Imported pixels differ or mipmaps enabled: " + path)
			return
		if FileAccess.get_sha256(path) != record["sha256"]:
			fail("PNG hash mismatch: " + path)
			return
		var bounds: Array = record["opaque_bounds_px"]
		var anchor: Array = record["ground_anchor_px_from_image_top_left"]
		var offset: Array = record["sprite2d_offset_px"]
		if int(anchor[1]) != int(bounds[1]) + int(bounds[3]) or int(offset[0]) != -int(anchor[0]) or int(offset[1]) != -int(anchor[1]):
			fail("Ground anchor or visual offset mismatch: " + path)
			return
		if int(anchor[0]) < int(bounds[0]) or int(anchor[0]) >= int(bounds[0]) + int(bounds[2]) or int(anchor[1]) >= 64:
			fail("Ground anchor outside usable canvas: " + path)
			return
	if seen.size() != 10:
		fail("Expected ten props.")
		return
	print("PASS: ten 64x64 props; exact RGBA import and PNG hashes; no mipmaps; consistent ground-anchor offsets.")
	quit(0)

func fail(message: String) -> void:
	push_error(message)
	quit(1)
