class_name ExteriorArtRegion
extends TerrainRegion
## Isolated preview occupancy over copied production cell data; never mutates its Resource.
var blocked: Dictionary[Vector2i,bool] = {}
func is_cell_walkable(at: Vector2i) -> bool: return cells.has(at) and not blocked.has(at)
