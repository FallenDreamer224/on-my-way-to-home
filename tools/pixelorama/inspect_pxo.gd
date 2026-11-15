extends SceneTree
## Read-only inspection of PXO v8 ZIP projects. Never execute source metadata.

func _initialize() -> void:
	var records: Array[Dictionary] = []
	var output: String = "res://tests/output/pxo_inspection"
	DirAccess.make_dir_recursive_absolute(output)
	var source_root: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("assets")
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	var source_option: int = arguments.find("--source-root")
	if source_option >= 0 and source_option + 1 < arguments.size():
		source_root = arguments[source_option + 1]
	var folders: Array[String] = ["characters", "animations"]
	if "--animations-only" in arguments:
		folders.assign(["animations"])
	for folder: String in folders:
		var source_dir: String = source_root.path_join(folder)
		for filename: String in DirAccess.get_files_at(source_dir):
			if not filename.ends_with(".pxo"):
				continue
			var path: String = source_dir.path_join(filename)
			var zip: ZIPReader = ZIPReader.new()
			assert(zip.open(path) == OK)
			var data: Dictionary = JSON.parse_string(zip.read_file("data.json").get_string_from_utf8())
			assert(int(data.color_mode) == Image.FORMAT_RGBA8)
			var canvas: Vector2i = Vector2i(data.size_x, data.size_y)
			var strip: Image = Image.create(canvas.x * data.frames.size(), canvas.y, false, Image.FORMAT_RGBA8)
			strip.fill(Color.TRANSPARENT)
			var frames: Array[Dictionary] = []
			for index: int in data.frames.size():
				var image: Image = composite(zip, data, index)
				strip.blit_rect(image, Rect2i(Vector2i.ZERO, canvas), Vector2i(index * canvas.x, 0))
				var info: Dictionary = {"source_frame": index + 1, "duration": data.frames[index].duration, "bounds": var_to_str(image.get_used_rect()), "empty": image.is_invisible(), "cels": data.frames[index].cels}
				frames.append(info)
				assert(image.save_png(output.path_join(filename.trim_suffix(".pxo") + "_%02d.png" % (index + 1))) == OK)
			assert(strip.save_png(output.path_join(filename.trim_suffix(".pxo") + "_strip.png")) == OK)
			records.append({"source": folder + "/" + filename, "sha256": FileAccess.get_sha256(path), "canvas": [canvas.x, canvas.y], "pixelorama_version": data.pixelorama_version, "pxo_version": data.pxo_version, "fps": data.fps, "layers": data.layers, "frames": frames, "reference_images": data.reference_images})
			zip.close()
	var file: FileAccess = FileAccess.open(output.path_join("inventory.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(records, "  "))
	print("Inspected %d source files without modifying them." % records.size())
	quit()


static func composite(zip: ZIPReader, data: Dictionary, frame_index: int) -> Image:
	var canvas: Image = Image.create(data.size_x, data.size_y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	for index: int in data.layers.size():
		var layer: Dictionary = data.layers[index]
		if String(layer.name).to_lower().contains("skeleton") or not layer.visible:
			continue
		assert(layer.type == 0 and layer.blend_mode == 0 and layer.opacity == 1.0 and layer.effects.is_empty())
		var cel: Dictionary = data.frames[frame_index].cels[index]
		assert(cel.opacity == 1.0)
		var size: Vector2i = vector(cel.image_size)
		var offset: Vector2i = vector(cel.offset)
		var bytes: PackedByteArray = zip.read_file("image_data/frames/%d/layer_%d" % [frame_index + 1, index + 1])
		assert(bytes.size() == size.x * size.y * 4)
		var image: Image = Image.create_from_data(size.x, size.y, false, Image.FORMAT_RGBA8, bytes)
		canvas.blend_rect(image, Rect2i(Vector2i.ZERO, size), offset)
	return canvas


static func vector(value: String) -> Vector2i:
	var regex: RegEx = RegEx.new()
	regex.compile("-?[0-9]+")
	var matches: Array[RegExMatch] = regex.search_all(value)
	# Vector2i contains a digit in its type name; only parse its parenthesized values.
	if value.contains("("):
		matches = regex.search_all(value.substr(value.find("(") + 1))
	assert(matches.size() == 2)
	return Vector2i(int(matches[0].get_string()), int(matches[1].get_string()))
