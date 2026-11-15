class_name HabitatRoomRegion
extends TerrainRegion
## Sparse floor: excluded wall and cabinet diamonds are authoritative obstacles.

var blocked_cells: Array[Vector2i] = []


func create_cells() -> Dictionary[Vector2i, int]:
	var result: Dictionary[Vector2i, int] = {}
	for y: int in range(1, size.y - 1):
		for x: int in range(1, size.x - 1):
			var cell := Vector2i(x, y)
			if cell not in blocked_cells:
				result[cell] = Kind.LIGHT_REGOLITH if (x + y) % 2 == 0 else Kind.REGOLITH
	return result
