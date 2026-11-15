class_name TerrainWalkability
extends RefCounted
## Swept foot-rectangle vs missing terrain diamonds. No invented obstacle nodes or map size.

const AXES: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2(1, 2), Vector2(1, -2)]
var layer: TerrainLayer


func _init(terrain: TerrainLayer) -> void:
	layer = terrain


func is_position_walkable(world_position: Vector2, half_extent: Vector2) -> bool:
	return _fraction(world_position, Vector2.ZERO, half_extent) == 1.0


func constrain_motion(start: Vector2, motion: Vector2, half_extent: Vector2) -> Vector2:
	if not motion.is_finite() or not is_position_walkable(start, half_extent):
		return Vector2.ZERO
	var fraction: float = _fraction(start, motion, half_extent)
	if fraction == 1.0:
		return motion
	var accepted: Vector2 = motion * fraction
	var remainder: Vector2 = motion - accepted
	# Simple screen-axis sliding at terrain edges; each segment is swept, not endpoint-only.
	var horizontal: Vector2 = Vector2(remainder.x, 0)
	accepted += horizontal * _fraction(start + accepted, horizontal, half_extent)
	var vertical: Vector2 = Vector2(0, remainder.y)
	accepted += vertical * _fraction(start + accepted, vertical, half_extent)
	# CharacterBody2D applies one displacement, not the intermediate slide segments.
	# Re-sweep that chord so sliding can never cut across a sparse hole or concave edge.
	var best: Vector2 = accepted * _fraction(start, accepted, half_extent)
	# Diamond edges are diagonal in screen space. Project the remainder along
	# those tangents too, then sweep the final chord to preserve hole/edge safety.
	var contact: Vector2 = motion * fraction
	for tangent: Vector2 in [Vector2(2, 1).normalized(), Vector2(2, -1).normalized()]:
		var slide: Vector2 = tangent * (motion - contact).dot(tangent)
		slide *= _fraction(start + contact, slide, half_extent)
		var candidate: Vector2 = contact + slide
		candidate *= _fraction(start, candidate, half_extent)
		if candidate.distance_squared_to(motion) < best.distance_squared_to(motion):
			best = candidate
	return best


func _fraction(start: Vector2, motion: Vector2, half_extent: Vector2) -> float:
	if (not is_instance_valid(layer) or not start.is_finite() or not motion.is_finite()
			or not half_extent.is_finite() or half_extent.x <= 0.0 or half_extent.y <= 0.0):
		return 0.0
	# The established world is unscaled/unrotated; translations are supported.
	if layer.global_transform.x != Vector2.RIGHT or layer.global_transform.y != Vector2.DOWN:
		return 0.0
	var local_start: Vector2 = layer.to_local(start)
	var zero: Vector2 = layer.map_to_local(Vector2i.ZERO)
	var first: Vector2 = IsometricGrid.position_to_fractional_tile(local_start - zero)
	var last: Vector2 = IsometricGrid.position_to_fractional_tile(local_start + motion - zero)
	var half: Vector2 = half_extent
	var reach: float = half.x / 64.0 + half.y / 32.0
	var low: Vector2i = Vector2i(floori(minf(first.x, last.x) - reach + 0.5), floori(minf(first.y, last.y) - reach + 0.5))
	var high: Vector2i = Vector2i(floori(maxf(first.x, last.x) + reach + 0.5), floori(maxf(first.y, last.y) + reach + 0.5))
	var result: float = 1.0
	for y: int in range(low.y, high.y + 1):
		for x: int in range(low.x, high.x + 1):
			var cell: Vector2i = Vector2i(x, y)
			if not layer.is_cell_walkable(cell):
				result = minf(result, _contact(local_start - layer.map_to_local(cell), motion, half))
	# Stop just short of a swept contact to avoid roundoff leaving the next step embedded.
	if motion != Vector2.ZERO and result < 1.0:
		result = maxf(0.0, result - 0.001 / maxf(motion.length(), 0.001))
	return result


func _contact(relative: Vector2, motion: Vector2, half: Vector2) -> float:
	# Separating-axis intervals for an AABB swept against a 64x32 diamond.
	var enter: float = 0.0
	var leave: float = 1.0
	for axis: Vector2 in AXES:
		var radius: float = maxf(absf(axis.x) * 32.0, absf(axis.y) * 16.0) + absf(axis.x) * half.x + absf(axis.y) * half.y
		var distance: float = relative.dot(axis)
		var speed: float = motion.dot(axis)
		if speed == 0.0:
			if absf(distance) >= radius:
				return 1.0
			continue
		var first: float = (-radius - distance) / speed
		var last: float = (radius - distance) / speed
		enter = maxf(enter, minf(first, last))
		leave = minf(leave, maxf(first, last))
		if enter >= leave:
			return 1.0
	return enter
