class_name LunarTutorialRegion
extends TerrainRegion
## Authored fictional outpost layout. Deterministic clustered geology, no random global state.

@export var zones: Dictionary[StringName, Rect2i] = {
	&"landing_unloading": Rect2i(-4, -4, 8, 7),
	&"habitat": Rect2i(-12, -4, 6, 7),
	&"exterior_utilities": Rect2i(-12, 5, 6, 4),
	&"solar_power": Rect2i(-11, -14, 9, 5),
	&"cargo_storage": Rect2i(5, -4, 5, 7),
	&"rover_parking_maintenance": Rect2i(5, -13, 8, 6),
	&"greenhouse_reserved": Rect2i(-3, 7, 7, 6),
	&"sampling_west": Rect2i(-16, 10, 5, 5),
	&"sampling_east": Rect2i(10, 8, 5, 5)
}
@export var crater_centers: Array[Vector2i] = [Vector2i(14, -4), Vector2i(-3, 16)]
@export var crater_radii: Array[int] = [3, 2]
@export var eva_limits: EvaSafetyLimits

## Per-session production placement. Clearance is distinct from physical occupancy.
var navigation_exclusions: Dictionary[Vector2i, bool] = {}
var installed_footprints: Dictionary[Vector2i, StringName] = {}
var prepared_access_cells: Dictionary[Vector2i, bool] = {}


func create_cells() -> Dictionary[Vector2i, int]:
	if not cells.is_empty(): return cells.duplicate()
	var result: Dictionary[Vector2i, int] = {}
	for y: int in range(origin.y, origin.y + size.y):
		for x: int in range(origin.x, origin.x + size.x):
			var cell := Vector2i(x, y)
			# Smooth fixed spatial fields create patches rather than checkerboard noise.
			var field: float = sin(x * 0.23 + y * 0.11) + cos(y * 0.29 - x * 0.09)
			var kind: int = Kind.REGOLITH
			if field > 0.9:
				kind = Kind.LIGHT_REGOLITH
			elif field < -0.7:
				kind = Kind.DARK_REGOLITH
			if _crater_distance(cell) <= 1:
				kind = Kind.DUST_PATCH if _crater_distance(cell) <= 0 else Kind.DARK_REGOLITH
			if is_safe_route(cell) or not zone_at(cell).is_empty():
				kind = Kind.LIGHT_REGOLITH
			if not _interior().has_point(cell):
				kind = Kind.DARK_REGOLITH
			result[cell] = kind
	return result


func _interior() -> Rect2i:
	if eva_limits != null:
		return eva_limits.allowed_cells
	return Rect2i(origin + Vector2i.ONE, size - Vector2i(2, 2))


func zone_at(cell: Vector2i) -> StringName:
	for id: StringName in zones:
		if zones[id].has_point(cell):
			return id
	return &""


func is_safe_route(cell: Vector2i) -> bool:
	# Three-cell-wide orthogonal service corridors connect spawn to every reservation.
	for rect: Rect2i in zones.values():
		var target: Vector2i = rect.position + rect.size / 2
		if (absi(cell.y) <= 1 and cell.x >= mini(0, target.x) - 1 and cell.x <= maxi(0, target.x) + 1
				or absi(cell.x - target.x) <= 1 and cell.y >= mini(0, target.y) - 1 and cell.y <= maxi(0, target.y) + 1):
			return true
	return false


func _crater_distance(cell: Vector2i) -> int:
	var nearest: int = 1000000
	for index: int in mini(crater_centers.size(), crater_radii.size()):
		nearest = mini(nearest, ceili(cell.distance_to(crater_centers[index])) - crater_radii[index])
	return nearest


func is_cell_walkable(cell: Vector2i) -> bool:
	# Authored access aprons may cross a rim; the actual crater cores stay excluded.
	if cell in crater_centers: return false
	return _interior().has_point(cell) and not navigation_exclusions.has(cell) and (prepared_access_cells.has(cell) or _crater_distance(cell) > 0 or is_safe_route(cell) or not zone_at(cell).is_empty())


func surface_at(cell: Vector2i, kind: int) -> SurfaceCellData:
	var data := SurfaceCellData.new()
	data.terrain_type = kind as Kind
	data.walkable = is_cell_walkable(cell)
	data.reserved_zone = zone_at(cell)
	data.occupant_id = installed_footprints.get(cell, &"")
	data.sunlight_exposure = SurfaceCellData.Sunlight.OPEN_SKY_ASSUMED if data.reserved_zone == &"solar_power" else SurfaceCellData.Sunlight.UNSURVEYED
	if not _interior().has_point(cell):
		data.hazard_flags |= SurfaceCellData.Hazard.RESTRICTED
	elif _crater_distance(cell) <= 1 and not is_safe_route(cell) and data.reserved_zone.is_empty():
		data.difficulty = SurfaceCellData.Difficulty.CRATER_RIM
		data.dust_tendency = SurfaceCellData.Dust.HIGH
		data.hazard_flags |= SurfaceCellData.Hazard.CRATER
	elif kind == Kind.DARK_REGOLITH:
		data.difficulty = SurfaceCellData.Difficulty.UNEVEN
		data.hazard_flags |= SurfaceCellData.Hazard.ROUGH
	elif is_safe_route(cell):
		data.dust_tendency = SurfaceCellData.Dust.LOW
	return data


func validation_errors() -> PackedStringArray:
	var errors := super.validation_errors()
	if eva_limits != null:
		errors.append_array(eva_limits.validation_errors())
		if not Rect2i(origin, size).encloses(eva_limits.allowed_cells):
			errors.append("EVA area must lie within the rendered region.")
	if size.x < 3 or size.y < 3:
		errors.append("Tutorial region requires an interior and perimeter.")
	if crater_centers.size() != crater_radii.size():
		errors.append("Every crater must have a radius.")
	for id: StringName in zones:
		if not _interior().encloses(zones[id]) or zones[id].size.x <= 0 or zones[id].size.y <= 0:
			errors.append("Invalid tutorial reservation: " + id)
	return errors
