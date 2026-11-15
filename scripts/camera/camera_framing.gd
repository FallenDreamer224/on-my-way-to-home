class_name CameraFraming
extends RefCounted
## Shared presentation policy; no terrain or input dependencies.


static func center(desired: Vector2, zoom: int, viewport_size: Vector2,
		bounds_enabled: bool, bounds: Rect2, snap: bool = true, center_small: bool = false) -> Vector2:
	var result: Vector2 = (desired * zoom).round() / zoom if snap else desired
	if (bounds_enabled and bounds.position.is_finite() and bounds.size.is_finite()
			and bounds.size.x > 0.0 and bounds.size.y > 0.0):
		var half_view: Vector2 = viewport_size / (2.0 * zoom)
		result.x = _axis(result.x, bounds.position.x, bounds.size.x, half_view.x, zoom, snap, center_small)
		result.y = _axis(result.y, bounds.position.y, bounds.size.y, half_view.y, zoom, snap, center_small)
	return result


static func _axis(value: float, start: float, extent: float, half_view: float, zoom: int, snap: bool, center_small: bool = false) -> float:
	var lower: float = start + half_view
	var upper: float = start + extent - half_view
	if snap:
		lower = ceilf(lower * zoom) / zoom
		upper = floorf(upper * zoom) / zoom
	if lower <= upper:
		return clampf(value, lower, upper)
	var middle: float = start + extent / 2.0
	return (roundf(middle * zoom) / zoom if snap else middle) if center_small else value
