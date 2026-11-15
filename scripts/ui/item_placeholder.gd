class_name ItemPlaceholder
extends RefCounted
## Temporary native 32 x 32 indicators, generated once in memory; no final artwork.

static var _cache: Dictionary[StringName, Texture2D] = {}


static func texture(item: ItemDefinition) -> Texture2D:
	if item.icon != null:
		return item.icon
	if not _cache.has(item.item_id):
		var image: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 0, 0))
		image.fill_rect(Rect2i(2, 2, 28, 28), Color("15232c"))
		image.fill_rect(Rect2i(4, 4, 24, 24), item.placeholder_color)
		image.fill_rect(Rect2i(9, 14, 14, 4), Color("f0f5ee"))
		_cache[item.item_id] = ImageTexture.create_from_image(image)
	return _cache[item.item_id]
