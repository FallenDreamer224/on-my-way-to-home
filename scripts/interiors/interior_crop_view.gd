class_name InteriorCropView
extends Node2D
## Read-only presentation adapter. No growth, resource, harvest or failure simulation.

var daily: DailyLife
var tray_index: int = 0
var stage: StringName = &"empty"
var status: String = "Unbound"
var progress: float = 0
var light_powered: bool = false
var _leaves: Sprite2D
const PROFILES: Dictionary = {
	&"germinating": preload("res://resources/interiors/props/greens_germinating.tres"),
	&"small": preload("res://resources/interiors/props/greens_small.tres"),
	&"intermediate": preload("res://resources/interiors/props/greens_intermediate.tres"),
	&"mature": preload("res://resources/interiors/props/greens_mature.tres"),
}

func _ready() -> void:
	_leaves = Sprite2D.new()
	_leaves.centered = false
	_leaves.position = Vector2(-14, -46)
	_leaves.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_leaves)
	refresh()

func bind_model(model: DailyLife, index: int) -> void:
	if daily != null and daily.changed.is_connected(refresh): daily.changed.disconnect(refresh)
	daily = model
	tray_index = index
	if daily != null: daily.changed.connect(refresh)
	if is_node_ready(): refresh()

func refresh() -> void:
	stage = &"empty"
	progress = 0
	light_powered = false
	if daily != null and tray_index >= 0 and tray_index < daily.trays.size():
		var tray: Dictionary = daily.trays[tray_index]
		status = String(tray.status)
		progress = clampf(float(tray.growth_s) / float(daily.settings.crop.growth_s), 0, 1)
		light_powered = bool(tray.light) and daily.utilities.model.equipment.greenhouse_lights.powered
		if tray.planted:
			if int(tray.remaining_yield) > 0: stage = &"mature"
			elif progress < 0.03: stage = &"seeded"
			elif progress < 0.15: stage = &"germinating"
			elif progress < 0.4: stage = &"small"
			else: stage = &"intermediate"
	if _leaves != null:
		_leaves.visible = stage not in [&"empty", &"seeded"]
		if _leaves.visible:
			var profile: InteriorPropDefinition = PROFILES[stage]
			_leaves.texture = profile.texture
			_leaves.offset = -Vector2(profile.attachment_anchor)
	queue_redraw()

func _draw() -> void:
	if stage == &"seeded":
		for point: Vector2 in [Vector2(-34, -68), Vector2(-20, -61), Vector2(-6, -54)]: draw_rect(Rect2(point, Vector2(2, 2)), Color("b0a47b"))
	draw_rect(Rect2(-5, -15, 4, 3), Color("86c4b2") if light_powered else Color("394854"))
