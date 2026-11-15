class_name KeyHint
extends HBoxContainer
## Keycap plus caption for one InputMap action. Labels are read on refresh, never polled.

var action: StringName
var caption: String:
	set(value):
		caption = value
		if _text != null:
			_text.text = value
var _key: Label
var _text: Label


func _init(input_action: StringName = &"", text: String = "") -> void:
	action = input_action
	add_theme_constant_override(&"separation", 4)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cap := PanelContainer.new()
	cap.theme_type_variation = &"KeycapPanel"
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_key = Label.new()
	_key.theme_type_variation = &"CaptionAccentLabel"
	_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.add_child(_key)
	add_child(cap)
	_text = Label.new()
	_text.theme_type_variation = &"SecondaryLabel"
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_text)
	caption = text
	refresh()


func refresh() -> void:
	_key.text = InputHint.label(action).to_upper() if action != &"" else ""


## Plain text form used by tests and screen summaries, e.g. "[I] Inventory".
func plain_text() -> String:
	return "[%s] %s" % [InputHint.label(action), caption]
