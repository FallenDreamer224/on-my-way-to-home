class_name TelemetryIndicator
extends HBoxContainer
## One telemetry readout: icon, caption, value and a state colour.
## An unavailable indicator is dimmed and states why; it never shows an invented number.
## The stacked layout suits the always-visible strip; the inline layout suits long lists.

var indicator_id: StringName
var available: bool = false
var state: UiKit.State = UiKit.State.OFFLINE
var _icon: Control
var _caption: Label
var _value: Label
var _led: ColorRect


func _init(id: StringName = &"", icon_name: StringName = &"", caption: String = "", inline: bool = false) -> void:
	indicator_id = id
	name = String(id).to_pascal_case() if id != &"" else "Indicator"
	add_theme_constant_override(&"separation", 6)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon = UiKit.compact_icon(icon_name, 20 if not inline else 16)
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_icon)
	_caption = UiKit.label(caption.to_upper(), &"CaptionLabel")
	_caption.name = "Caption"
	_value = UiKit.label("", &"MutedLabel")
	_value.name = "Value"
	if inline:
		_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		add_child(_caption)
		_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		add_child(_value)
	else:
		var column := UiKit.vbox(0)
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(column)
		column.add_child(_caption)
		column.add_child(_value)
	_led = ColorRect.new()
	_led.custom_minimum_size = Vector2(4, 4)
	_led.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_led)
	UiKit.make_passive(self)
	set_unavailable("Not simulated")


func set_reading(text: String, reading_state: UiKit.State = UiKit.State.NOMINAL) -> void:
	available = true
	state = reading_state
	_value.text = text
	_value.theme_type_variation = UiKit.STATE_LABELS[reading_state]
	_icon.modulate.a = 1.0
	_refresh_led()


func set_unavailable(reason: String) -> void:
	available = false
	state = UiKit.State.OFFLINE
	_value.text = reason
	_value.theme_type_variation = &"MutedLabel"
	_icon.modulate.a = 0.4
	_refresh_led()


func value_text() -> String:
	return _value.text


func caption_text() -> String:
	return _caption.text


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and _led != null:
		_refresh_led()


func _refresh_led() -> void:
	_led.color = UiKit.state_color(self, state)
	# Keep the column aligned whether or not a reading is available.
	_led.self_modulate.a = 1.0 if available else 0.0
