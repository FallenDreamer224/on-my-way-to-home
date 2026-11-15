extends SceneTree
## Verifies the shipped PNGs survive Godot import without pixel changes.

func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/ui_pack_a.json"))
	var count: int = 0
	for record: Dictionary in manifest["assets"]:
		var path: String = "res://" + str(record["runtime_files"][0])
		var source := Image.new()
		if source.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
			fail("Cannot decode source PNG: " + path)
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
		if imported.has_mipmaps() or source.get_data() != imported.get_data():
			fail("Imported pixels differ or mipmaps enabled: " + path)
			return
		count += 1
	if count != 23:
		fail("Expected exactly 23 textures.")
		return
	print("PASS: 23 imported UI textures preserve exact RGBA pixels, native dimensions and no mipmaps.")
	quit(0)

func fail(message: String) -> void:
	push_error(message)
	quit(1)
