extends Node2D
## Development-only geometry annotations; never installed by the reusable prefab.
var definition: ExteriorAssetDefinition
func _draw() -> void:
	if definition == null or definition.footprint_polygon.size() < 3: return
	var outline: PackedVector2Array = definition.footprint_polygon.duplicate()
	outline.append(outline[0])
	draw_polyline(outline, Color("85b4a0"), 1.0, false)
	if definition.collision_enabled:
		draw_colored_polygon(definition.collision_polygon, Color(0.8, 0.3, 0.2, 0.08))
		var collision: PackedVector2Array = definition.collision_polygon.duplicate()
		collision.append(collision[0])
		draw_polyline(collision, Color("c0836e"), 1.0, false)
	draw_line(Vector2(-4, 0), Vector2(4, 0), Color.WHITE)
	draw_line(Vector2(0, -4), Vector2(0, 4), Color.WHITE)
	var access := Vector2(definition.interaction_anchor)
	draw_rect(Rect2(access - Vector2(3, 3), Vector2(6, 6)), Color("78b7c4"), false)
	var service := Vector2(definition.service_anchor)
	draw_rect(Rect2(service - Vector2(2, 2), Vector2(4, 4)), Color("dfbc69"), false)
