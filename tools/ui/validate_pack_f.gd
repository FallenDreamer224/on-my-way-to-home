extends SceneTree
## Read-only validation of native recovered UI artwork, imported pixels and provenance.
func _initialize() -> void:
	var errors: PackedStringArray = []
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/ui_pack_f.json"))
	var icons: int = 0
	for record: Dictionary in manifest.assets:
		var runtime: String = "res://" + record.runtime_files[0]
		var source: String = "res://" + record.source_files[0]
		var native := Image.load_from_file(source)
		var imported := load(runtime) as Texture2D
		if native == null or imported == null:
			errors.append("Missing asset: " + record.asset_id)
			continue
		var actual := imported.get_image()
		native.convert(Image.FORMAT_RGBA8)
		actual.convert(Image.FORMAT_RGBA8)
		var size := Vector2i(int(record.native_canvas_size_px[0]), int(record.native_canvas_size_px[1]))
		if native.get_size() != size or actual.get_size() != size or actual.has_mipmaps() or native.get_data() != actual.get_data():
			errors.append("Native/imported pixel mismatch: " + record.asset_id)
		if FileAccess.get_sha256(runtime) != record.sha256 or FileAccess.get_sha256(source) != record.sha256:
			errors.append("Provenance hash mismatch: " + record.asset_id)
		if record.category == "ui_icon":
			icons += 1
			var transparent: int = 0
			var opaque: int = 0
			for y: int in size.y:
				for x: int in size.x:
					var alpha: float = native.get_pixel(x, y).a
					if alpha == 0: transparent += 1
					elif alpha == 1: opaque += 1
					else: errors.append("Interpolated alpha in icon: " + record.asset_id)
			if size != Vector2i(32, 32) or transparent == 0 or opaque == 0:
				errors.append("Icon size/transparency invalid: " + record.asset_id)
	for name: StringName in UiIcons.PACK_F_NAMES:
		if not UiIcons.has_icon(name): errors.append("Unresolved icon: " + name)
	if icons != 24 or manifest.assets.size() != 26 or manifest.fallbacks.size() != 2:
		errors.append("Unexpected Pack F totals")
	for error: String in errors: printerr("FAIL: " + error)
	if errors.is_empty(): print("PASS: 24 native 32x32 icons, two menu illustrations and two explicit fallbacks; exact RGBA/hash/import validation")
	quit(0 if errors.is_empty() else 1)
