extends Node2D
## Development site annotations; no building services, collisions or mission logic.

@onready var ground: TerrainLayer = $"../Terrain/Ground"


func _ready() -> void:
	var region := ground.region as LunarTutorialRegion
	if region == null:
		return
	for id: StringName in region.zones:
		var rect: Rect2i = region.zones[id]
		var label := Label.new()
		label.text = String(id).replace("_", " ").to_upper()
		label.add_theme_font_size_override("font_size", 12)
		label.modulate = Color("98adb9")
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.position = IsometricGrid.tile_to_world(rect.position, ground) + Vector2(-20, -12)
		add_child(label)
	queue_redraw()


func _draw() -> void:
	if not is_node_ready():
		return
	var region := ground.region as LunarTutorialRegion
	if region == null:
		return
	for rect: Rect2i in region.zones.values():
		var points := PackedVector2Array()
		for corner: Vector2 in [Vector2(rect.position) - Vector2(0.5, 0.5), Vector2(rect.end) - Vector2(0.5, rect.size.y + 0.5), Vector2(rect.end) - Vector2(0.5, 0.5), Vector2(rect.position) + Vector2(-0.5, rect.size.y - 0.5)]:
			points.append(Vector2((corner.x - corner.y) * 32, (corner.x + corner.y) * 16))
		points.append(points[0])
		draw_polyline(points, Color(0.4, 0.6, 0.65, 0.5), 1.0, false)
