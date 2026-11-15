class_name InteriorPropDefinition
extends Resource
## Native presentation metadata. Quantities and actions belong to existing services.

@export var asset_id: StringName
@export var texture: Texture2D
@export var native_size: Vector2i
@export var opaque_bounds: Rect2i
@export var ground_anchor: Vector2i
@export var attachment_anchor: Vector2i
@export var footprint: Vector2i = Vector2i.ONE
@export var grid_origin: Vector2i
@export var interaction_anchor: Vector2i = Vector2i(0, 24)
@export var provenance: String
@export var source_files: PackedStringArray
@export var reused: bool = false

func validation_errors() -> PackedStringArray:
	var result: PackedStringArray = []
	if asset_id.is_empty() or texture == null: result.append("Missing identity/texture")
	if texture != null and texture.get_size() != Vector2(native_size): result.append("Native dimensions differ")
	if not Rect2i(Vector2i.ZERO, native_size).encloses(opaque_bounds): result.append("Invalid opaque bounds")
	if ground_anchor.x < 0 or ground_anchor.x > native_size.x or ground_anchor.y < 0 or ground_anchor.y > native_size.y: result.append("Invalid anchor")
	if footprint.x < 0 or footprint.y < 0 or provenance.is_empty() or source_files.is_empty(): result.append("Incomplete footprint/provenance")
	return result
