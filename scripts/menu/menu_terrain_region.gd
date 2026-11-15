class_name MenuTerrainRegion
extends TerrainRegion
## Screen-aligned band of lunar ground for the title scene. Cells are chosen by their
## screen row (i + j) and screen column (i - j), so the band fills a wide, short view.
## Presentation only: it has no walkability, zones or mission meaning.

@export var rows: Vector2i = Vector2i(-7, 17)
@export var columns: Vector2i = Vector2i(-17, 18)


func create_cells() -> Dictionary[Vector2i, int]:
	var result: Dictionary[Vector2i, int] = {}
	for row: int in range(rows.x, rows.y + 1):
		for column: int in range(columns.x, columns.y + 1):
			if posmod(row + column, 2) != 0:
				continue
			@warning_ignore("integer_division")
			var cell := Vector2i((row + column) / 2, (row - column) / 2)
			# The same smooth-field idea as the tutorial region: patches, not checkerboard noise.
			var field: float = sin(cell.x * 0.31 + cell.y * 0.17) + cos(cell.y * 0.27 - cell.x * 0.13)
			var kind: int = Kind.REGOLITH
			if field > 1.0:
				kind = Kind.LIGHT_REGOLITH
			elif field < -0.9:
				kind = Kind.DARK_REGOLITH
			result[cell] = kind
	return result


func is_cell_walkable(_cell: Vector2i) -> bool:
	return true


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if rows.y < rows.x or columns.y < columns.x:
		errors.append("Menu terrain band requires ordered row and column ranges.")
	return errors
