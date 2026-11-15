class_name EvaSafetyLimits
extends Resource
## Authored grid limits, not meters, suit endurance or a NASA-certified EVA range.

enum Zone { NORMAL, WARNING, RESTRICTED_BOUNDARY }

@export var allowed_cells: Rect2i = Rect2i(-19, -19, 38, 38)
@export var warning_inset_cells: int = 3
@export var boundary_inset_cells: int = 1
@export var return_cell: Vector2i = Vector2i.ZERO
@export var warning_enabled: bool = true
@export var boundary_enabled: bool = true
@export var cooldown_seconds: float = 6.0
@export var normal_rearm_seconds: float = 3.0
@export var message_duration_seconds: float = 5.0
@export_multiline var warning_message: String = "We're nearing our mission limit. Keep reserves and a known route back."
@export_multiline var boundary_message: String = "Our mission area ends here. We should turn back."
@export_multiline var safety_reason: String = "Keep reserves for return."


func zone_at(cell: Vector2i) -> Zone:
	if not allowed_cells.has_point(cell):
		return Zone.RESTRICTED_BOUNDARY
	var edge: int = mini(mini(cell.x - allowed_cells.position.x, allowed_cells.end.x - 1 - cell.x),
		mini(cell.y - allowed_cells.position.y, allowed_cells.end.y - 1 - cell.y))
	if edge < boundary_inset_cells:
		return Zone.RESTRICTED_BOUNDARY
	return Zone.WARNING if edge < warning_inset_cells else Zone.NORMAL


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if boundary_inset_cells < 1 or warning_inset_cells <= boundary_inset_cells:
		errors.append("Warning inset must exceed the positive boundary inset.")
	if allowed_cells.size.x <= 2 * warning_inset_cells or allowed_cells.size.y <= 2 * warning_inset_cells:
		errors.append("Safety limits require a nonempty normal exploration zone.")
	if not allowed_cells.has_point(return_cell):
		errors.append("Return cell must lie inside the mission area.")
	for value: float in [cooldown_seconds, normal_rearm_seconds, message_duration_seconds]:
		if not is_finite(value) or value <= 0.0:
			errors.append("Safety dialogue timings must be finite and positive.")
	if warning_message.strip_edges().is_empty() or boundary_message.strip_edges().is_empty() or safety_reason.strip_edges().is_empty():
		errors.append("Safety dialogue must contain English message text.")
	return errors
