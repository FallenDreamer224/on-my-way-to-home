@tool
class_name ExteriorAssetDefinition
extends Resource
## Prepared art/geometry contract. This Resource never changes terrain or utility state.

@export var asset_id: StringName
@export var display_name: String
@export var category: StringName
@export var texture: Texture2D
@export var native_size: Vector2i
@export var opaque_bounds: Rect2i
@export var ground_anchor: Vector2i
@export var footprint_size: Vector2i
@export var occupied_cells: Array[Vector2i] = []
## Cells a future world placer must reserve for routes, including ground hardware clearance.
@export var navigation_reserved_cells: Array[Vector2i] = []
## Reference cell (0,0) relative to the object's front ground/sorting pivot.
@export var grid_origin: Vector2i
@export var footprint_polygon: PackedVector2Array
@export var collision_polygon: PackedVector2Array
@export var interaction_anchor: Vector2i
@export var service_anchor: Vector2i
@export var indicator_anchor: Vector2i
@export var collision_enabled: bool = true
@export var supports_states: bool = false
@export var utility_binding_id: StringName
## Future binding only: no Interactable or equipment command is installed by this library.
@export var interaction_reference: StringName
@export_file("*.json") var provenance_manifest: String
@export var source_files: PackedStringArray
@export var readiness: StringName = &"READY"

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if asset_id == &"" or display_name.is_empty() or texture == null:
		errors.append("Asset identity/texture is required")
	if texture != null and Vector2i(texture.get_size()) != native_size:
		errors.append("Native texture size mismatch")
	if native_size.x <= 0 or native_size.y <= 0 or not Rect2i(Vector2i.ZERO, native_size).encloses(opaque_bounds):
		errors.append("Visible bounds outside native canvas")
	if ground_anchor.x < 0 or ground_anchor.x >= native_size.x or ground_anchor.y < 0 or ground_anchor.y > native_size.y:
		errors.append("Ground anchor outside canvas")
	if footprint_size.x <= 0 or footprint_size.y <= 0 or occupied_cells.size() != footprint_size.x * footprint_size.y:
		errors.append("Explicit footprint cells required")
	var seen: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in occupied_cells:
		if seen.has(cell) or not Rect2i(Vector2i.ZERO, footprint_size).has_point(cell):
			errors.append("Invalid/duplicate occupied cell")
		seen[cell] = true
	if footprint_polygon.size() != 4 or (collision_enabled and collision_polygon.size() < 3):
		errors.append("Footprint/collision geometry required")
	for point: Vector2 in footprint_polygon:
		if not point.is_finite(): errors.append("Nonfinite footprint")
	if collision_enabled and Geometry2D.is_point_in_polygon(Vector2(interaction_anchor), collision_polygon):
		errors.append("Access point must be outside solid collision")
	return errors
