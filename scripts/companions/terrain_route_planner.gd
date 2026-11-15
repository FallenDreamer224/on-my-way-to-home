class_name TerrainRoutePlanner
extends RefCounted
## Bounded four-neighbor BFS; every connector is swept with the complete foot rectangle.

var terrain: TerrainLayer
var walkability: TerrainWalkability
var half_extent: Vector2
var node_budget: int = 2048


func _init(layer: TerrainLayer, half: Vector2) -> void:
	terrain = layer
	walkability = TerrainWalkability.new(layer)
	half_extent = half


func clear_segment(start: Vector2, finish: Vector2) -> bool:
	return (walkability.is_position_walkable(start, half_extent)
		and walkability.is_position_walkable(finish, half_extent)
		and walkability.constrain_motion(start, finish - start, half_extent).is_equal_approx(finish - start))


func route(start: Vector2, goal: Vector2) -> PackedVector2Array:
	if not is_instance_valid(terrain) or not start.is_finite() or not goal.is_finite():
		return PackedVector2Array()
	if clear_segment(start, goal):
		return PackedVector2Array([goal])
	var first: Vector2i = IsometricGrid.world_to_tile(start, terrain)
	var last: Vector2i = IsometricGrid.world_to_tile(goal, terrain)
	if not terrain.is_cell_walkable(first) or not terrain.is_cell_walkable(last):
		return PackedVector2Array()
	var first_center: Vector2 = IsometricGrid.tile_to_world(first, terrain)
	var last_center: Vector2 = IsometricGrid.tile_to_world(last, terrain)
	if not clear_segment(start, first_center) or not clear_segment(last_center, goal):
		return PackedVector2Array()
	var queue: Array[Vector2i] = [first]
	var previous: Dictionary[Vector2i, Vector2i] = {first: first}
	var head: int = 0
	while head < queue.size() and head < node_budget:
		var cell: Vector2i = queue[head]
		head += 1
		if cell == last:
			var result: PackedVector2Array = [goal]
			var cursor: Vector2i = last
			while cursor != first:
				result.append(IsometricGrid.tile_to_world(cursor, terrain))
				cursor = previous[cursor]
			result.append(first_center)
			result.reverse()
			return result
		for step: Vector2i in IsometricGrid.CARDINAL_STEPS:
			var neighbor: Vector2i = cell + step
			if previous.has(neighbor) or not terrain.is_cell_walkable(neighbor):
				continue
			if clear_segment(IsometricGrid.tile_to_world(cell, terrain), IsometricGrid.tile_to_world(neighbor, terrain)):
				previous[neighbor] = cell
				queue.append(neighbor)
	return PackedVector2Array()
