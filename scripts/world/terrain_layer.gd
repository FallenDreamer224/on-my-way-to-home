class_name TerrainLayer
extends TileMapLayer
## Render a logical region once. Future authored data uses the same cell-to-source mapping.

@export var region: TerrainRegion
@export var replacement_textures: Array[Texture2D] = []
@export var terrain_art: TileSet

var terrain_cells: Dictionary[Vector2i, int] = {}
var _blocked_cells: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	clear()
	terrain_cells.clear()
	_blocked_cells.clear()
	if region == null:
		push_error("TerrainLayer requires a TerrainRegion resource.")
		return
	var errors: PackedStringArray = region.validation_errors()
	if not errors.is_empty():
		push_error("Invalid terrain region: " + "; ".join(errors))
		return
	tile_set = terrain_art if terrain_art != null and replacement_textures.is_empty() else PlaceholderTerrain.create_tile_set(replacement_textures)
	if tile_set == null:
		return
	# Duplicate authored data; never mutate a shared configuration resource during startup.
	terrain_cells = region.create_cells()
	for cell: Vector2i in terrain_cells:
		if not region.is_cell_walkable(cell):
			_blocked_cells[cell] = true
		var kind: int = terrain_cells[cell]
		set_cell(cell, kind, _visual_variant(cell, kind))


func is_cell_walkable(cell: Vector2i) -> bool:
	return terrain_cells.has(cell) and not _blocked_cells.has(cell)


func world_rect() -> Rect2:
	var bounds := Rect2()
	var first: bool = true
	for cell: Vector2i in terrain_cells:
		var center := IsometricGrid.tile_to_world(cell, self)
		var diamond_rect := Rect2(center - Vector2(32, 16), Vector2(64, 32))
		bounds = diamond_rect if first else bounds.merge(diamond_rect)
		first = false
	return bounds


func _visual_variant(cell: Vector2i, kind: int) -> Vector2i:
	# Render-only variation. Logical terrain, source IDs and the global RNG stay unchanged.
	var source: TileSetAtlasSource = tile_set.get_source(kind) as TileSetAtlasSource
	var cell_hash: int = ((cell.x * 73856093) ^ (cell.y * 19349663) ^ (kind * 83492791)) & 0x7fffffff
	return source.get_tile_id(cell_hash % source.get_tiles_count())
