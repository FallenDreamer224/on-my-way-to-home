extends SceneTree
## Read pixels without modifying source images. Output also supports duplicate intake review.
func _initialize() -> void:
	var input: Array = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var output: Array[Dictionary] = []
	for name: String in input:
		var image := Image.new()
		if image.load_png_from_buffer(FileAccess.get_file_as_bytes(name)) != OK:
			printerr("FAIL: Cannot decode " + name)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		var bounds: Rect2i = image.get_used_rect()
		var bottom: Array[int] = []
		var opaque: int = 0
		var partial: int = 0
		for y: int in image.get_height():
			for x: int in image.get_width():
				var alpha: float = image.get_pixel(x, y).a
				if alpha == 1.0: opaque += 1
				elif alpha > 0: partial += 1
				if alpha > 0 and y == bounds.end.y - 1: bottom.append(x)
		var anchor_x: int = (bottom[0] + bottom[-1]) / 2 if not bottom.is_empty() else image.get_width() / 2
		output.append({"path":name,"size":[image.get_width(),image.get_height()],"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],
			"bottom_anchor":[anchor_x,bounds.end.y],"opaque_pixels":opaque,"partial_alpha_pixels":partial,"sha256":FileAccess.get_sha256(name)})
	var file := FileAccess.open(OS.get_cmdline_user_args()[1], FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "  "))
	print("PASS: measured %d unchanged PNGs" % output.size())
	quit()
