class_name PlaceholderTerrain
extends RefCounted
## Temporary CPU-generated pixel diamonds. No generated files or external art services.

const COLORS: Array[Color] = [Color("777b80"), Color("83878b"), Color("696d73"), Color("939087")]


static func create_tile_set(textures: Array[Texture2D] = []) -> TileSet:
	if not textures.is_empty() and textures.size() != COLORS.size():
		push_error("Terrain replacement requires four 64 x 32 textures, in terrain-kind order.")
		return null
	var result: TileSet = TileSet.new()
	result.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	result.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	result.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL
	result.tile_size = IsometricGrid.TILE_SIZE
	for kind: int in COLORS.size():
		var texture: Texture2D = _create_texture(kind) if textures.is_empty() else textures[kind]
		if texture == null or texture.get_size() != Vector2(IsometricGrid.TILE_SIZE):
			push_error("Incompatible terrain texture; expected exactly 64 x 32. No resizing performed.")
			return null
		var source: TileSetAtlasSource = TileSetAtlasSource.new()
		source.texture = texture
		source.texture_region_size = IsometricGrid.TILE_SIZE
		source.create_tile(Vector2i.ZERO)
		result.add_source(source, kind)
	return result


static func _create_texture(kind: int) -> ImageTexture:
	var image: Image = Image.create(64, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y: int in 32:
		for x: int in 64:
			var diamond_distance: float = absf((x + 0.5 - 32.0) / 32.0) + absf((y + 0.5 - 16.0) / 16.0)
			if diamond_distance > 1.0:
				continue
			var shade: float = -0.07 if diamond_distance > 0.92 else 0.0
			if posmod(x * 13 + y * 23, 47) == 0:
				shade -= 0.05
			var color: Color = COLORS[kind]
			image.set_pixel(x, y, Color(color.r + shade, color.g + shade, color.b + shade, 1.0))
	return ImageTexture.create_from_image(image)
