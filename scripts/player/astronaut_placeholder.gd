class_name AstronautPlaceholder
extends RefCounted
## Minimal development art, built once in memory. No provider calls or saved images.

static var _frames: SpriteFrames


static func frames() -> SpriteFrames:
	if _frames != null:
		return _frames
	_frames = SpriteFrames.new()
	_frames.remove_animation(&"default")
	for index: int in 8:
		for state: String in ["idle", "walk"]:
			var clip: StringName = StringName(state + "_" + AstronautDirections.NAMES[index])
			_frames.add_animation(clip)
			_frames.set_animation_speed(clip, 6.0 if state == "walk" else 1.0)
			_frames.set_animation_loop(clip, true)
			for frame: int in (4 if state == "walk" else 1):
				_frames.add_frame(clip, _texture(index, frame, state == "walk"))
	return _frames


static func _texture(direction: int, frame: int, walking: bool) -> ImageTexture:
	var image: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Visible height 50px, canvas anchor (32,56). One boot always retains the baseline.
	image.fill_rect(Rect2i(24, 26, 17, 24), Color("c8cbd0"))
	image.fill_rect(Rect2i(20, 29, 4, 17), Color("9fa6b0"))
	image.fill_rect(Rect2i(41, 29, 4, 17), Color("9fa6b0"))
	for y: int in range(6, 29):
		for x: int in range(21, 44):
			if Vector2(x - 32, y - 17).length_squared() <= 121.0:
				image.set_pixel(x, y, Color("e4e6e8"))
	var left_lift: int = 2 if walking and frame == 1 else 0
	var right_lift: int = 2 if walking and frame == 3 else 0
	image.fill_rect(Rect2i(25, 48, 6, 8 - left_lift), Color("75818f"))
	image.fill_rect(Rect2i(34, 48, 6, 8 - right_lift), Color("75818f"))
	image.fill_rect(Rect2i(27, 12, 11, 11), Color("354657"))
	var facing: Vector2 = AstronautDirections.VECTORS[direction].normalized()
	# Eight distinct direction marks; no horizontal flipping substitutes for coverage.
	for step: int in range(2, 10):
		var point: Vector2i = Vector2i((Vector2(32, 35) + facing * step).round())
		image.set_pixelv(point, Color("e9bc59"))
	var visor_mark: Vector2i = Vector2i((Vector2(32, 17) + facing * 5).round())
	image.fill_rect(Rect2i(visor_mark - Vector2i.ONE, Vector2i(3, 3)), Color("85e6d3"))
	return ImageTexture.create_from_image(image)
