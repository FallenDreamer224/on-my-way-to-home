extends Marker2D
## Removable development marker; no player logic or input. Root is the ground point.


func _draw() -> void:
	if not OS.is_debug_build():
		return
	draw_line(Vector2(-5, 0), Vector2(5, 0), Color("85e6d3"), 1.0, false)
	draw_line(Vector2(0, -5), Vector2(0, 5), Color("85e6d3"), 1.0, false)
