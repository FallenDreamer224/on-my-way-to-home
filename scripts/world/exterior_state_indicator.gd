class_name ExteriorStateIndicator
extends Node2D
## Optional presentation adapter. Read existing equipment state; never command a service.
enum State { OPERATIONAL, DISABLED, DAMAGED, MAINTENANCE }
const COLORS: Array[Color] = [Color("8ac7b0"), Color("667781"), Color("df766c"), Color("dfbc69")]
@export var state: State = State.DISABLED:
	set(value):
		if value < State.OPERATIONAL or value > State.MAINTENANCE: return
		state = value
		queue_redraw()

func display_equipment(equipment: UtilityEquipment) -> bool:
	if equipment == null: return false
	state = (State.DAMAGED if equipment.fault else State.MAINTENANCE if equipment.maintenance
		else State.OPERATIONAL if equipment.enabled and equipment.powered else State.DISABLED)
	return true

func _draw() -> void:
	# Separate six-pixel service marker: no source-image recoloring or blinking.
	draw_rect(Rect2(-4, -4, 8, 8), Color("18232c"))
	draw_rect(Rect2(-2, -2, 4, 4), COLORS[state])
