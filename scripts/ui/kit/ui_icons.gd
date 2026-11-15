class_name UiIcons
extends RefCounted
## Stable icon names for interface code. Every icon is a native 32 x 32 canvas with a compact
## centered pictogram; draw it unscaled. Pack A is the original UI delivery, Pack F fills its gaps.

const PACK_A: String = "res://assets/ui/ui_pack_a/icon_%s.png"
const PACK_F: String = "res://assets/ui/ui_pack_f/icon_%s.png"
const PACK_A_NAMES: Array[StringName] = [
	&"health", &"sleep", &"radiation", &"emotion", &"cardiac", &"defense",
	&"inventory", &"lunar_sample", &"metal_scrap", &"supply_tool",
]
const PACK_F_NAMES: Array[StringName] = [
	&"oxygen", &"carbon_dioxide", &"battery", &"fatigue", &"warning", &"power", &"water", &"air",
	&"greenhouse", &"gear", &"wrench", &"research", &"mission", &"location", &"temperature",
	&"pressure", &"solar", &"habitat", &"greens_seed", &"fresh_greens", &"dry_ration",
	&"prepared_meal", &"check", &"helmet", &"database", &"comms",
]
## Inventory items whose icon name differs from the item identifier.
const ITEM_ALIASES: Dictionary[StringName, StringName] = {&"supply_pack": &"supply_tool"}

static var _cache: Dictionary[StringName, Texture2D] = {}


static func texture(name: StringName) -> Texture2D:
	if _cache.has(name):
		return _cache[name]
	var path: String = ""
	if name in PACK_A_NAMES:
		path = PACK_A % name
	elif name in PACK_F_NAMES:
		path = PACK_F % name
	var result: Texture2D = load(path) if not path.is_empty() and ResourceLoader.exists(path) else null
	_cache[name] = result
	return result


static func has_icon(name: StringName) -> bool:
	return texture(name) != null


## Authored definition icon first, then the shared registry, then the neutral placeholder.
static func item_texture(item: ItemDefinition) -> Texture2D:
	if item == null:
		return null
	if item.icon != null:
		return item.icon
	var registered: Texture2D = texture(ITEM_ALIASES.get(item.item_id, item.item_id))
	return registered if registered != null else ItemPlaceholder.texture(item)
