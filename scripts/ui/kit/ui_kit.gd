class_name UiKit
extends RefCounted
## Factory for shared Mission OS components. Styling lives in the Theme resources built by
## tools/ui/build_mission_theme.gd; callers pass data in and receive plain Controls back.

enum State { NOMINAL, OK, WARNING, CRITICAL, OFFLINE }

const TOKENS: StringName = &"MissionOS"
const STANDARD_THEME: Theme = preload("res://resources/ui/mission_os_theme.tres")
const CONTRAST_THEME: Theme = preload("res://resources/ui/mission_os_theme_high_contrast.tres")
const STATE_LABELS: Dictionary[State, StringName] = {
	State.NOMINAL: &"Label", State.OK: &"OkLabel", State.WARNING: &"WarningLabel",
	State.CRITICAL: &"CriticalLabel", State.OFFLINE: &"MutedLabel",
}
const STATE_TOKENS: Dictionary[State, StringName] = {
	State.NOMINAL: &"accent", State.OK: &"ok", State.WARNING: &"warning",
	State.CRITICAL: &"critical", State.OFFLINE: &"text_muted",
}
const STATE_GAUGES: Dictionary[State, StringName] = {
	State.NOMINAL: &"AccentProgressBar", State.OK: &"OkProgressBar", State.WARNING: &"WarningProgressBar",
	State.CRITICAL: &"CriticalProgressBar", State.OFFLINE: &"ProgressBar",
}


static func theme(high_contrast: bool = false) -> Theme:
	return CONTRAST_THEME if high_contrast else STANDARD_THEME


static func color(control: Control, token: StringName) -> Color:
	return control.get_theme_color(token, TOKENS)


static func state_color(control: Control, state: State) -> Color:
	return color(control, STATE_TOKENS[state])


static func label(text: String = "", variation: StringName = &"") -> Label:
	var result := Label.new()
	result.text = text
	if variation != &"":
		result.theme_type_variation = variation
	return result


static func wrapped(text: String = "", variation: StringName = &"", minimum_width: float = 0.0) -> Label:
	var result: Label = label(text, variation)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.custom_minimum_size.x = minimum_width
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return result


static func button(text: String, variation: StringName = &"", on_pressed: Callable = Callable()) -> Button:
	var result := Button.new()
	result.text = text
	if variation != &"":
		result.theme_type_variation = variation
	if on_pressed.is_valid():
		result.pressed.connect(on_pressed)
	return result


## Native-size icon; the 32 x 32 canvas is never scaled.
static func icon(name: StringName) -> TextureRect:
	return texture_rect(UiIcons.texture(name))


static func texture_rect(texture: Texture2D) -> TextureRect:
	var result := TextureRect.new()
	result.texture = texture
	result.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	result.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	result.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result


## Icons carry transparent padding. This shows only the centered pictogram area at native
## scale inside a smaller box, without resampling the texture.
static func compact_icon(name: StringName, box: int = 20) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(box, box)
	holder.clip_contents = true
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var image: TextureRect = icon(name)
	image.position = (Vector2(box, box) - Vector2(32, 32)) * 0.5
	image.size = Vector2(32, 32)
	holder.add_child(image)
	return holder


static func hbox(separation: int = 4) -> HBoxContainer:
	var result := HBoxContainer.new()
	result.add_theme_constant_override(&"separation", separation)
	return result


static func vbox(separation: int = 4) -> VBoxContainer:
	var result := VBoxContainer.new()
	result.add_theme_constant_override(&"separation", separation)
	return result


static func margin(left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var result := MarginContainer.new()
	result.add_theme_constant_override(&"margin_left", left)
	result.add_theme_constant_override(&"margin_top", top)
	result.add_theme_constant_override(&"margin_right", right)
	result.add_theme_constant_override(&"margin_bottom", bottom)
	return result


static func spacer() -> Control:
	var result := Control.new()
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result


static func separator() -> HSeparator:
	return HSeparator.new()


static func panel(variation: StringName = &"") -> PanelContainer:
	var result := PanelContainer.new()
	if variation != &"":
		result.theme_type_variation = variation
	return result


static func gauge(state: State = State.NOMINAL, minimum_width: float = 0.0) -> ProgressBar:
	var result := ProgressBar.new()
	result.show_percentage = false
	result.custom_minimum_size = Vector2(minimum_width, 8)
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	result.theme_type_variation = STATE_GAUGES[state]
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result


static func scroll(minimum_size: Vector2 = Vector2.ZERO) -> ScrollContainer:
	var result := ScrollContainer.new()
	result.custom_minimum_size = minimum_size
	result.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return result


## Title row shared by every modal window: icon, title, optional note and a close button.
static func window_header(title: String, icon_name: StringName, close_text: String, on_close: Callable) -> HBoxContainer:
	var row: HBoxContainer = hbox(8)
	if UiIcons.has_icon(icon_name):
		row.add_child(compact_icon(icon_name, 22))
	var caption: Label = label(title, &"WindowTitleLabel")
	caption.name = "Title"
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(caption)
	if on_close.is_valid():
		var close: Button = button(close_text, &"", on_close)
		close.name = "Close"
		close.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(close)
	return row


## Label/value row for telemetry lists. Returns the value label through `out`.
static func value_row(caption: String, value_variation: StringName = &"") -> Array:
	var row: HBoxContainer = hbox(8)
	var name_label: Label = label(caption, &"SecondaryLabel")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var value: Label = label("", value_variation)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	return [row, value]


## Viewport size in the control's own canvas units; smaller than 960 x 540 when the UI is scaled up.
static func logical_size(control: Control) -> Vector2:
	if not control.is_inside_tree():
		return Vector2(960, 540)
	var scale: Vector2 = control.get_canvas_transform().get_scale()
	var view: Vector2 = control.get_viewport_rect().size
	return Vector2(view.x / maxf(scale.x, 0.01), view.y / maxf(scale.y, 0.01))


## Sizes a free-positioned window to its design size, clamped to the visible area, and centers it.
static func center_modal(control: Control, design: Vector2, edge: float = 8.0) -> void:
	var view: Vector2 = logical_size(control)
	var fitted := Vector2(minf(design.x, view.x - edge * 2.0), minf(design.y, view.y - edge * 2.0))
	control.size = fitted
	control.position = ((view - fitted) * 0.5).round()


## World-space annotation labels (room titles, station names) use the interface typeface.
## They live under the game camera, whose zoom is always a whole number, so they stay sharp.
static func style_world_label(target: Label, caption: bool = false) -> void:
	var font_name: StringName = &"caption" if caption else &"body"
	target.add_theme_font_override(&"font", STANDARD_THEME.get_font(font_name, TOKENS))
	target.add_theme_font_size_override(&"font_size", STANDARD_THEME.get_font_size(font_name, TOKENS))
	target.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


## Passive presentation never takes pointer input or keyboard focus.
static func make_passive(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.focus_mode = Control.FOCUS_NONE
	for child: Node in node.get_children():
		make_passive(child)


## Short readable form of a model identifier such as "equipment_offline/co2_removal".
static func humanize(identifier: String) -> String:
	return identifier.replace("/", ": ").replace("_", " ").capitalize()
