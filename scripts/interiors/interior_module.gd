class_name InteriorModule
extends Node2D
## Original native 2D construction geometry, not edited/generated bitmap art.

enum Kind { WALL, CORNER, WINDOW, SERVICE, SUPPORT, DOOR, CABLE_STRAIGHT, CABLE_CORNER, CABLE_VERTICAL }
@export var kind: Kind = Kind.WALL
@export var axis: Vector2i = Vector2i(1, 0)
@export var cutaway: bool = false
@export var reinforced: bool = false
@export var closed: bool = false:
	set(value):
		closed = value
		queue_redraw()

func _draw() -> void:
	var end := IsometricGrid.tile_to_position(axis)
	var height: int = 8 if cutaway else 60
	var top := Vector2(0, -height)
	var face := PackedVector2Array([Vector2.ZERO, end, end + top, top])
	var edge := Color("273b4b")
	var light := Color("b6c3cc") if axis.x != 0 else Color("8b9da9")
	if reinforced: light = Color("7e929e")
	if kind in [Kind.CABLE_STRAIGHT, Kind.CABLE_CORNER, Kind.CABLE_VERTICAL]:
		var a := Vector2(0, -18)
		var b := a + (Vector2(0, -24) if kind == Kind.CABLE_VERTICAL else end)
		draw_line(a, b, edge, 4, false)
		draw_line(a, b, Color("7097a9"), 2, false)
		if kind == Kind.CABLE_CORNER: draw_line(b, b + Vector2(-16, 8), Color("7097a9"), 2, false)
		return
	if kind == Kind.DOOR:
		# A native frame and retractable leaf share the same threshold and orientation.
		draw_line(Vector2.ZERO, top, edge, 5, false)
		draw_line(end, end + top, edge, 5, false)
		draw_line(top, end + top, light, 5, false)
		if closed:
			draw_colored_polygon(face, Color("5c7384"))
			draw_line(end * 0.5, end * 0.5 + top, edge, 2, false)
			draw_circle(end * 0.5 + top * 0.4, 2, Color("d8ab72"), false)
		else: draw_line(Vector2.ZERO, end, Color("79bbc8"), 2, false)
		return
	draw_colored_polygon(face, light)
	draw_polyline(PackedVector2Array([Vector2.ZERO, top, end + top, end]), edge, 2, false)
	draw_line(top + Vector2(0, 6), end + top + Vector2(0, 6), Color("dce5e8"), 2, false)
	if not cutaway:
		draw_line(Vector2(0, -12), end + Vector2(0, -12), Color("516b7e"), 3, false)
		if kind == Kind.WINDOW:
			var window := PackedVector2Array([top * 0.35 + end * 0.15, top * 0.35 + end * 0.85, top * 0.8 + end * 0.85, top * 0.8 + end * 0.15])
			draw_colored_polygon(window, Color("293e52"))
			draw_line(window[2], window[3], Color("86b1c3"), 1, false)
		elif kind == Kind.SERVICE:
			draw_line(end * 0.5 + Vector2(0, -20), end * 0.5 + Vector2(0, -46), edge, 2, false)
		elif kind == Kind.SUPPORT or kind == Kind.CORNER:
			draw_line(top + end * 0.2, end * 0.2, edge, 4, false)
