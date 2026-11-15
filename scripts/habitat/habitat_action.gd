class_name HabitatAction
extends Interactable

var handler: Callable
var room_id: StringName
var action_id: StringName
var destination: StringName


func _draw() -> void:
	draw_colored_polygon(HabitatRoom.diamond(Vector2.ZERO), Color(0.12, 0.24, 0.3, 0.55))
	draw_rect(Rect2(-5, -12, 10, 12), Color("81bdc9"), false, 1)


func execute(_inventory: RuntimeInventory) -> bool:
	return bool(handler.call(self)) if handler.is_valid() else false


func result_message(_success: bool) -> String:
	# The director reports committed outcomes; no misleading pickup feedback.
	return ""
