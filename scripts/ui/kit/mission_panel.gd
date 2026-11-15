class_name MissionPanel
extends PanelContainer
## Modal window body: the flat WindowPanel background plus the nine-slice window frame
## supplied by the active theme (empty in the high-contrast theme).


func _init() -> void:
	theme_type_variation = &"WindowPanel"


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var frame: StyleBox = get_theme_stylebox(&"frame", &"WindowPanel")
	if frame != null and not frame is StyleBoxEmpty:
		draw_style_box(frame, Rect2(Vector2.ZERO, size))
