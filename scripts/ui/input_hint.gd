class_name InputHint
extends RefCounted
## Bindings are read on UI events/explicit refresh, never polled every frame.


static func label(action: StringName) -> String:
	var fallback: String = "Unbound"
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
		fallback = event.as_text()
	return fallback
