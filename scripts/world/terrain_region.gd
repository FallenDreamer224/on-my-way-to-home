class_name TerrainRegion
extends Resource
## Logical terrain only: no node, texture, viewport, or camera dependencies.

enum Kind { REGOLITH, LIGHT_REGOLITH, DARK_REGOLITH, DUST_PATCH }

@export var origin: Vector2i = Vector2i(-6, -6)
@export var size: Vector2i = Vector2i(12, 12)
@export var cells: Dictionary[Vector2i, int] = {}


func create_cells() -> Dictionary[Vector2i, int]:
	return cells.duplicate() if not cells.is_empty() else create_lunar_test_cells()


func is_cell_walkable(cell: Vector2i) -> bool:
	return Rect2i(origin, size).has_point(cell)


func create_lunar_test_cells() -> Dictionary[Vector2i, int]:
	# Small deterministic fixture; deliberately not a procedural world generator.
	var result: Dictionary[Vector2i, int] = {}
	for row: int in range(origin.y, origin.y + size.y):
		for column: int in range(origin.x, origin.x + size.x):
			var cell: Vector2i = Vector2i(column, row)
			var value: int = posmod(column * 17 + row * 31, 11)
			var kind: int = Kind.REGOLITH
			if value < 2:
				kind = Kind.LIGHT_REGOLITH
			elif value > 8:
				kind = Kind.DARK_REGOLITH
			if cell.distance_squared_to(Vector2i(1, -2)) <= 4:
				kind = Kind.DUST_PATCH
			result[cell] = kind
	return result


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if size.x <= 0 or size.y <= 0:
		errors.append("Terrain region size must be positive.")
	for cell: Vector2i in cells:
		if not Rect2i(origin, size).has_point(cell):
			errors.append("Terrain cell lies outside the declared region: %s" % cell)
		if cells[cell] < Kind.REGOLITH or cells[cell] > Kind.DUST_PATCH:
			errors.append("Unknown terrain kind at %s" % cell)
	return errors
