class_name IsometricGrid
extends RefCounted
## Logical cells and origin-centered ground positions. All returned positions are centers.

const TILE_SIZE: Vector2i = Vector2i(64, 32)
const HALF_SIZE: Vector2 = Vector2(32, 16)
const CARDINAL_STEPS: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]


static func tile_to_position(cell: Vector2i) -> Vector2:
	return Vector2((cell.x - cell.y) * 32, (cell.x + cell.y) * 16)


static func position_to_fractional_tile(position: Vector2) -> Vector2:
	return Vector2(position.x / 64.0 + position.y / 32.0, position.y / 32.0 - position.x / 64.0)


static func position_to_tile(position: Vector2) -> Vector2i:
	# Half-open cell intervals: an exact +0.5 tie belongs to the higher grid index.
	var fractional: Vector2 = position_to_fractional_tile(position)
	return Vector2i(floori(fractional.x + 0.5), floori(fractional.y + 0.5))


static func tile_to_world(cell: Vector2i, layer: TileMapLayer) -> Vector2:
	return layer.to_global(layer.map_to_local(cell))


static func world_to_tile(position: Vector2, layer: TileMapLayer) -> Vector2i:
	# Godot owns exact-edge selection for actual terrain, including its layer transform.
	return layer.local_to_map(layer.to_local(position))


static func neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for step: Vector2i in CARDINAL_STEPS:
		result.append(cell + step)
	return result
