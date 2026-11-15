class_name InteriorRoomRegion
extends HabitatRoomRegion
## The same TerrainLayer/full-foot navigation contract, including door thresholds.

var thresholds: Array[Vector2i] = []
var floor_kind: int = Kind.REGOLITH

func create_cells() -> Dictionary[Vector2i, int]:
	var result: Dictionary[Vector2i, int] = {}
	for y: int in range(1, size.y - 1):
		for x: int in range(1, size.x - 1): result[Vector2i(x, y)] = floor_kind
	for at: Vector2i in thresholds: result[at] = Kind.DUST_PATCH
	return result

func is_cell_walkable(at: Vector2i) -> bool:
	return (Rect2i(Vector2i.ONE, size - Vector2i(2, 2)).has_point(at) or at in thresholds) and at not in blocked_cells
