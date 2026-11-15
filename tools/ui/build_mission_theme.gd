extends SceneTree
## Builds both Mission OS Theme resources from one token table.
## Run after changing design tokens:
##   godot --headless --path . --script res://tools/ui/build_mission_theme.gd
## Colors marked "Pack A" are sampled from assets/ui/ui_pack_a so flat controls match the artwork.

const OUT_STANDARD: String = "res://resources/ui/mission_os_theme.tres"
const OUT_CONTRAST: String = "res://resources/ui/mission_os_theme_high_contrast.tres"
const PACK: String = "res://assets/ui/ui_pack_a/"
const FONTS: String = "res://assets/ui/fonts/"
const TOKEN_TYPE: StringName = &"MissionOS"

const BODY_SIZE: int = 11
const CAPTION_SIZE: int = 8
const HEADING_SIZE: int = 22
const TITLE_SIZE: int = 44

const STANDARD: Dictionary = {
	"void": "070b10", "bg_deep": "0d141b", "bg": "151e26", "bg_raised": "1c2731",
	"surface": "283540", "surface_hover": "32424f", "divider": "465663",
	"text_muted": "758692", "text_secondary": "adb9c0", "text": "dce4e5",
	"accent": "78b7c4", "accent_deep": "386c82", "accent_bright": "a6dbe5",
	"ok": "7fc79b", "ok_dim": "1d3a2b", "warning": "e3b65c", "warning_dim": "40341b",
	"critical": "e2695e", "critical_dim": "45211f",
}
const CONTRAST: Dictionary = {
	"void": "000000", "bg_deep": "000000", "bg": "05080b", "bg_raised": "0b1218",
	"surface": "13202a", "surface_hover": "1f3442", "divider": "c5d3da",
	"text_muted": "c5d3da", "text_secondary": "e8f0f2", "text": "ffffff",
	"accent": "8fe6f7", "accent_deep": "5fb8cc", "accent_bright": "d2f8ff",
	"ok": "86f7a8", "ok_dim": "0d2a18", "warning": "ffd65a", "warning_dim": "2e2405",
	"critical": "ff7b6e", "critical_dim": "330d09",
}

var _c: Dictionary = {}
var _contrast: bool = false
var _body: Font
var _caption: Font
var _caption_bold: Font


func _initialize() -> void:
	var failed: bool = false
	for target: Array in [[OUT_STANDARD, STANDARD, false], [OUT_CONTRAST, CONTRAST, true]]:
		var theme: Theme = _build(target[1], target[2])
		var result: Error = ResourceSaver.save(theme, target[0])
		if result != OK:
			printerr("Could not save %s (%d)" % [target[0], result])
			failed = true
		else:
			print("Saved %s: %d types" % [target[0], theme.get_type_list().size()])
	quit(1 if failed else 0)


func _build(palette: Dictionary, high_contrast: bool) -> Theme:
	_c.clear()
	for key: String in palette:
		_c[key] = Color(String(palette[key]))
	_contrast = high_contrast
	_body = load(FONTS + "departure_mono_regular.otf")
	_caption = _variation(load(FONTS + "silkscreen_regular.ttf"))
	_caption_bold = _variation(load(FONTS + "silkscreen_bold.ttf"))
	var theme := Theme.new()
	theme.default_font = _body
	theme.default_font_size = BODY_SIZE
	_tokens(theme)
	_labels(theme)
	_buttons(theme)
	_toggles(theme)
	_panels(theme)
	_ranges(theme)
	_tabs(theme)
	_misc(theme)
	return theme


func _variation(base: Font) -> FontVariation:
	# Silkscreen is uppercase-only; body glyphs cover symbols it lacks.
	var font := FontVariation.new()
	font.base_font = base
	font.fallbacks = [_body]
	return font


func _tokens(theme: Theme) -> void:
	for key: String in _c:
		theme.set_color(StringName(key), TOKEN_TYPE, _c[key])
	theme.set_color(&"scrim", TOKEN_TYPE, Color(_c.void, 0.72 if not _contrast else 0.9))
	for pair: Array in [["space_xs", 2], ["space_s", 4], ["space_m", 8], ["space_l", 12], ["space_xl", 16],
			["border", 2 if _contrast else 1], ["high_contrast", 1 if _contrast else 0]]:
		theme.set_constant(StringName(pair[0]), TOKEN_TYPE, pair[1])
	theme.set_font(&"body", TOKEN_TYPE, _body)
	theme.set_font(&"caption", TOKEN_TYPE, _caption)
	theme.set_font(&"caption_bold", TOKEN_TYPE, _caption_bold)
	for pair: Array in [["body", BODY_SIZE], ["caption", CAPTION_SIZE], ["heading", HEADING_SIZE], ["title", TITLE_SIZE]]:
		theme.set_font_size(StringName(pair[0]), TOKEN_TYPE, pair[1])


func _flat(bg: Color, border: Color = Color.TRANSPARENT, width: int = 0, margin_h: int = 8, margin_v: int = 4) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.draw_center = bg.a > 0.0
	style.border_color = border
	style.set_border_width_all((maxi(width, 2) if _contrast and width > 0 else width))
	style.anti_aliasing = false
	style.content_margin_left = margin_h
	style.content_margin_right = margin_h
	style.content_margin_top = margin_v
	style.content_margin_bottom = margin_v
	return style


func _frame(file: String, region: Rect2, slice: Vector4, margin_h: int, margin_v: int) -> StyleBoxTexture:
	# Regions and slice margins are the measured opaque bounds and uniform bands of each Pack A frame.
	var style := StyleBoxTexture.new()
	style.texture = load(PACK + file)
	style.region_rect = region
	style.texture_margin_left = slice.x
	style.texture_margin_top = slice.y
	style.texture_margin_right = slice.z
	style.texture_margin_bottom = slice.w
	style.content_margin_left = margin_h
	style.content_margin_right = margin_h
	style.content_margin_top = margin_v
	style.content_margin_bottom = margin_v
	return style


func _label(theme: Theme, type: StringName, font: Font, size: int, color: Color) -> void:
	if type != &"Label":
		theme.set_type_variation(type, &"Label")
	theme.set_font(&"font", type, font)
	theme.set_font_size(&"font_size", type, size)
	theme.set_color(&"font_color", type, color)
	theme.set_constant(&"line_spacing", type, 2)


func _labels(theme: Theme) -> void:
	_label(theme, &"Label", _body, BODY_SIZE, _c.text)
	_label(theme, &"SecondaryLabel", _body, BODY_SIZE, _c.text_secondary)
	_label(theme, &"MutedLabel", _body, BODY_SIZE, _c.text_muted)
	_label(theme, &"AccentLabel", _body, BODY_SIZE, _c.accent)
	_label(theme, &"OkLabel", _body, BODY_SIZE, _c.ok)
	_label(theme, &"WarningLabel", _body, BODY_SIZE, _c.warning)
	_label(theme, &"CriticalLabel", _body, BODY_SIZE, _c.critical)
	_label(theme, &"CaptionLabel", _caption, CAPTION_SIZE, _c.text_muted)
	_label(theme, &"CaptionAccentLabel", _caption, CAPTION_SIZE, _c.accent)
	_label(theme, &"SectionLabel", _caption_bold, CAPTION_SIZE, _c.accent)
	_label(theme, &"WindowTitleLabel", _caption_bold, CAPTION_SIZE * 2, _c.text)
	_label(theme, &"HeadingLabel", _body, HEADING_SIZE, _c.text)
	_label(theme, &"TitleLabel", _body, TITLE_SIZE, _c.text)
	_label(theme, &"BigValueLabel", _body, HEADING_SIZE, _c.accent_bright)


func _button(theme: Theme, type: StringName, styles: Dictionary, colors: Dictionary, font_size: int = BODY_SIZE) -> void:
	# Built-in classes (OptionButton) are themed directly; only custom names become variations.
	if not ClassDB.class_exists(type):
		theme.set_type_variation(type, &"Button")
	for state: String in styles:
		theme.set_stylebox(StringName(state), type, styles[state])
	for name: String in colors:
		theme.set_color(StringName(name), type, colors[name])
	theme.set_font(&"font", type, _body)
	theme.set_font_size(&"font_size", type, font_size)
	theme.set_constant(&"h_separation", type, 6)
	theme.set_constant(&"outline_size", type, 0)


func _focus(expand: int = 1) -> StyleBoxFlat:
	var style := _flat(Color.TRANSPARENT, _c.accent_bright, 1, 0, 0)
	style.draw_center = false
	style.set_expand_margin_all(expand)
	return style


func _text_colors(normal: Color, hover: Color, pressed: Color) -> Dictionary:
	return {"font_color": normal, "font_hover_color": hover, "font_pressed_color": pressed,
		"font_hover_pressed_color": pressed, "font_focus_color": hover, "font_disabled_color": Color(_c.text_muted, 0.75 if not _contrast else 1.0),
		"icon_normal_color": normal, "icon_hover_color": hover, "icon_pressed_color": pressed,
		"icon_hover_pressed_color": pressed, "icon_focus_color": hover, "icon_disabled_color": Color(_c.text_muted, 0.6)}


func _buttons(theme: Theme) -> void:
	var disabled := _flat(_c.bg, _c.surface, 1)
	_button(theme, &"Button", {
		"normal": _flat(_c.bg_raised, _c.divider, 1), "hover": _flat(_c.surface, _c.accent, 1),
		"pressed": _flat(_c.accent_deep, _c.accent, 1), "hover_pressed": _flat(_c.accent_deep, _c.accent_bright, 1),
		"disabled": disabled, "focus": _focus()},
		_text_colors(_c.text, _c.accent_bright, _c.text))
	_button(theme, &"PrimaryButton", {
		"normal": _flat(_c.accent_deep, _c.accent, 1), "hover": _flat(_c.accent_deep.lightened(0.14), _c.accent_bright, 1),
		"pressed": _flat(_c.accent, _c.accent_bright, 1), "hover_pressed": _flat(_c.accent, _c.accent_bright, 1),
		"disabled": disabled, "focus": _focus()},
		_text_colors(_c.text, Color.WHITE, _c.bg_deep))
	_button(theme, &"DangerButton", {
		"normal": _flat(_c.critical_dim, _c.critical, 1), "hover": _flat(_c.critical_dim.lightened(0.1), _c.critical, 1),
		"pressed": _flat(_c.critical, _c.critical, 1), "hover_pressed": _flat(_c.critical, _c.critical, 1),
		"disabled": disabled, "focus": _focus()},
		_text_colors(_c.text, Color.WHITE, _c.bg_deep))
	var clear := _flat(Color.TRANSPARENT, Color.TRANSPARENT, 0)
	_button(theme, &"GhostButton", {
		"normal": clear, "hover": _flat(_c.surface, Color.TRANSPARENT, 0), "pressed": _flat(_c.surface_hover, Color.TRANSPARENT, 0),
		"hover_pressed": _flat(_c.surface_hover, Color.TRANSPARENT, 0), "disabled": clear, "focus": _focus(0)},
		_text_colors(_c.text_secondary, _c.accent_bright, _c.text))
	# Title-screen entries: large type, a cyan rule marks the focused line.
	var menu_hover := _flat(Color(_c.surface, 0.55), Color.TRANSPARENT, 0, 12, 4)
	menu_hover.border_color = _c.accent
	menu_hover.border_width_left = 3
	var menu_clear := _flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 12, 4)
	menu_clear.border_width_left = 3
	menu_clear.border_color = Color.TRANSPARENT
	var menu_pressed := _flat(Color(_c.accent_deep, 0.8), Color.TRANSPARENT, 0, 12, 4)
	menu_pressed.border_color = _c.accent_bright
	menu_pressed.border_width_left = 3
	_button(theme, &"TitleMenuButton", {
		"normal": menu_clear, "hover": menu_hover, "pressed": menu_pressed, "hover_pressed": menu_pressed,
		"disabled": menu_clear, "focus": menu_hover},
		_text_colors(_c.text_secondary, Color.WHITE, Color.WHITE), HEADING_SIZE)
	theme.set_color(&"font_focus_color", &"TitleMenuButton", Color.WHITE)
	# List rows and dashboard rail entries are toggle buttons; the selected row keeps an accent rule.
	var row_selected := _flat(_c.surface, Color.TRANSPARENT, 0, 8, 3)
	row_selected.border_color = _c.accent
	row_selected.border_width_left = 2
	var row_clear := _flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 8, 3)
	row_clear.border_width_left = 2
	row_clear.border_color = Color.TRANSPARENT
	var row_hover := _flat(_c.bg_raised, Color.TRANSPARENT, 0, 8, 3)
	row_hover.border_width_left = 2
	row_hover.border_color = _c.divider
	_button(theme, &"ListButton", {
		"normal": row_clear, "hover": row_hover, "pressed": row_selected, "hover_pressed": row_selected,
		"disabled": row_clear, "focus": _focus(0)},
		_text_colors(_c.text_secondary, _c.text, _c.text))
	var rail_selected := _flat(_c.surface, Color.TRANSPARENT, 0, 2, 2)
	rail_selected.border_color = _c.accent
	rail_selected.border_width_left = 2
	var rail_clear := _flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 2, 2)
	rail_clear.border_width_left = 2
	rail_clear.border_color = Color.TRANSPARENT
	var rail_hover := _flat(_c.bg_raised, Color.TRANSPARENT, 0, 2, 2)
	rail_hover.border_width_left = 2
	rail_hover.border_color = _c.divider
	_button(theme, &"RailButton", {
		"normal": rail_clear, "hover": rail_hover, "pressed": rail_selected, "hover_pressed": rail_selected,
		"disabled": rail_clear, "focus": _focus(0)},
		_text_colors(_c.text_secondary, _c.text, _c.text))
	# Inventory slots draw the complete native 48 x 48 Pack A canvases; controls keep that exact size.
	var slot_normal: StyleBox
	var slot_selected: StyleBox
	if _contrast:
		slot_normal = _flat(_c.bg, _c.divider, 2, 0, 0)
		slot_selected = _flat(_c.surface, _c.accent_bright, 2, 0, 0)
	else:
		slot_normal = _frame("inventory_slot_normal.png", Rect2(0, 0, 48, 48), Vector4.ZERO, 0, 0)
		slot_selected = _frame("inventory_slot_selected.png", Rect2(0, 0, 48, 48), Vector4.ZERO, 0, 0)
	# Stack quantities sit in the transparent band under the 26-pixel frame art.
	for style: StyleBox in [slot_normal, slot_selected]:
		style.content_margin_top = 37
		style.content_margin_bottom = 1
		style.content_margin_left = 2
		style.content_margin_right = 6
	_button(theme, &"SlotButton", {
		"normal": slot_normal, "hover": slot_selected, "pressed": slot_selected, "hover_pressed": slot_selected,
		"disabled": slot_normal, "focus": StyleBoxEmpty.new()},
		_text_colors(_c.text, _c.text, _c.text))
	theme.set_font(&"font", &"SlotButton", _caption)
	theme.set_font_size(&"font_size", &"SlotButton", CAPTION_SIZE)
	_button(theme, &"OptionButton", {
		"normal": _flat(_c.bg_raised, _c.divider, 1), "hover": _flat(_c.surface, _c.accent, 1),
		"pressed": _flat(_c.accent_deep, _c.accent, 1), "hover_pressed": _flat(_c.accent_deep, _c.accent_bright, 1),
		"disabled": disabled, "focus": _focus()},
		_text_colors(_c.text, _c.accent_bright, _c.text))
	theme.set_icon(&"arrow", &"OptionButton", _pixels(["#######", ".#####.", "..###..", "...#..."], {"#": _c.text_secondary}))
	theme.set_constant(&"arrow_margin", &"OptionButton", 6)
	theme.set_constant(&"modulate_arrow", &"OptionButton", 0)


func _toggles(theme: Theme) -> void:
	var box_off := _box_icon(11, _c.divider, _c.bg_deep, Color.TRANSPARENT)
	var box_on := _box_icon(11, _c.accent, _c.bg_deep, _c.accent)
	var box_off_disabled := _box_icon(11, _c.surface, _c.bg, Color.TRANSPARENT)
	var box_on_disabled := _box_icon(11, _c.surface, _c.bg, _c.divider)
	var switch_off := _switch_icon(false, false)
	var switch_on := _switch_icon(true, false)
	var colors: Dictionary = _text_colors(_c.text, _c.accent_bright, _c.text)
	var clear := _flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 4, 3)
	var hover := _flat(_c.bg_raised, Color.TRANSPARENT, 0, 4, 3)
	for type: StringName in [&"CheckBox", &"CheckButton"]:
		for state: String in ["normal", "pressed", "disabled", "hover", "hover_pressed"]:
			theme.set_stylebox(StringName(state), type, hover if state.begins_with("hover") else clear)
		theme.set_stylebox(&"focus", type, _focus(0))
		for name: String in colors:
			theme.set_color(StringName(name), type, colors[name])
		theme.set_font(&"font", type, _body)
		theme.set_font_size(&"font_size", type, BODY_SIZE)
		theme.set_constant(&"h_separation", type, 6)
		theme.set_constant(&"check_v_offset", type, 0)
	for pair: Array in [["checked", box_on], ["unchecked", box_off], ["checked_disabled", box_on_disabled],
			["unchecked_disabled", box_off_disabled], ["radio_checked", box_on], ["radio_unchecked", box_off],
			["radio_checked_disabled", box_on_disabled], ["radio_unchecked_disabled", box_off_disabled]]:
		theme.set_icon(StringName(pair[0]), &"CheckBox", pair[1])
	for pair: Array in [["checked", switch_on], ["unchecked", switch_off], ["checked_mirrored", switch_on],
			["unchecked_mirrored", switch_off], ["checked_disabled", _switch_icon(true, true)],
			["unchecked_disabled", _switch_icon(false, true)], ["checked_disabled_mirrored", _switch_icon(true, true)],
			["unchecked_disabled_mirrored", _switch_icon(false, true)]]:
		theme.set_icon(StringName(pair[0]), &"CheckButton", pair[1])
	# Menus opened by OptionButton.
	theme.set_stylebox(&"panel", &"PopupMenu", _flat(_c.bg, _c.accent_deep, 1, 2, 2))
	theme.set_stylebox(&"hover", &"PopupMenu", _flat(_c.surface, Color.TRANSPARENT, 0, 4, 2))
	var separator := StyleBoxLine.new()
	separator.color = _c.divider
	theme.set_stylebox(&"separator", &"PopupMenu", separator)
	theme.set_color(&"font_color", &"PopupMenu", _c.text)
	theme.set_color(&"font_hover_color", &"PopupMenu", _c.accent_bright)
	theme.set_color(&"font_disabled_color", &"PopupMenu", _c.text_muted)
	theme.set_color(&"font_separator_color", &"PopupMenu", _c.text_muted)
	theme.set_font(&"font", &"PopupMenu", _body)
	theme.set_font_size(&"font_size", &"PopupMenu", BODY_SIZE)
	theme.set_constant(&"v_separation", &"PopupMenu", 4)
	theme.set_constant(&"h_separation", &"PopupMenu", 6)
	theme.set_constant(&"item_start_padding", &"PopupMenu", 6)
	theme.set_constant(&"item_end_padding", &"PopupMenu", 6)
	for pair: Array in [["checked", box_on], ["unchecked", box_off], ["radio_checked", box_on], ["radio_unchecked", box_off],
			["checked_disabled", box_on_disabled], ["unchecked_disabled", box_off_disabled],
			["radio_checked_disabled", box_on_disabled], ["radio_unchecked_disabled", box_off_disabled]]:
		theme.set_icon(StringName(pair[0]), &"PopupMenu", pair[1])


func _panel(theme: Theme, type: StringName, style: StyleBox) -> void:
	if type != &"PanelContainer":
		theme.set_type_variation(type, &"PanelContainer")
	theme.set_stylebox(&"panel", type, style)


func _panels(theme: Theme) -> void:
	_panel(theme, &"PanelContainer", _flat(Color(_c.bg, 1.0 if _contrast else 0.96), _c.divider, 1, 8, 6))
	theme.set_stylebox(&"panel", &"Panel", _flat(Color(_c.bg, 1.0 if _contrast else 0.96), _c.divider, 1, 8, 6))
	_panel(theme, &"HudPanel", _flat(Color(_c.bg_deep, 1.0 if _contrast else 0.86), _c.surface if not _contrast else _c.divider, 1, 8, 5))
	_panel(theme, &"InsetPanel", _flat(_c.bg_deep, _c.surface if not _contrast else _c.divider, 1, 6, 6))
	_panel(theme, &"KeycapPanel", _flat(_c.surface, _c.divider, 1, 4, 1))
	_panel(theme, &"PortraitPanel", _flat(_c.bg_deep, _c.divider, 1, 2, 2))
	# Selection frame: a border only, drawn over the selected item.
	theme.set_type_variation(&"SelectionFrame", &"Panel")
	theme.set_stylebox(&"panel", &"SelectionFrame", _flat(Color.TRANSPARENT, _c.accent_bright, 1, 0, 0))
	_panel(theme, &"PlainPanel", _flat(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0, 0))
	_panel(theme, &"WindowPanel", _flat(_c.bg_deep, _c.accent_deep if not _contrast else _c.text, 1, 14, 12))
	_panel(theme, &"DockPanel", _flat(Color(_c.bg_deep, 1.0 if _contrast else 0.94), _c.accent_deep if not _contrast else _c.text, 1, 8, 8))
	_panel(theme, &"WarningBanner", _flat(_c.warning_dim, _c.warning, 1, 8, 4))
	_panel(theme, &"CriticalBanner", _flat(_c.critical_dim, _c.critical, 1, 8, 4))
	_panel(theme, &"OkBanner", _flat(_c.ok_dim, _c.ok, 1, 8, 4))
	if _contrast:
		_panel(theme, &"NoticePanel", _flat(_c.bg, _c.accent, 2, 10, 7))
		_panel(theme, &"ChipPanel", _flat(_c.bg, _c.divider, 2, 8, 5))
		_panel(theme, &"PromptPanel", _flat(_c.bg, _c.text, 2, 12, 6))
		theme.set_stylebox(&"frame", &"WindowPanel", StyleBoxEmpty.new())
	else:
		_panel(theme, &"NoticePanel", _frame("notification_panel.png", Rect2(19, 9, 155, 44), Vector4(7, 7, 7, 7), 10, 7))
		_panel(theme, &"ChipPanel", _frame("panel_small.png", Rect2(9, 5, 110, 54), Vector4(9, 10, 9, 10), 9, 6))
		_panel(theme, &"PromptPanel", _frame("interaction_prompt.png", Rect2(12, 2, 136, 27), Vector4(11, 11, 11, 11), 13, 6))
		# Open-center window frame; MissionPanel draws it above the flat WindowPanel body.
		theme.set_stylebox(&"frame", &"WindowPanel", _frame("panel_large.png", Rect2(20, 30, 216, 115), Vector4(20, 19, 20, 19), 0, 0))
	theme.set_stylebox(&"panel", &"TooltipPanel", _flat(_c.surface, _c.accent_deep if not _contrast else _c.text, 1, 6, 4))
	theme.set_color(&"font_color", &"TooltipLabel", _c.text)
	theme.set_font(&"font", &"TooltipLabel", _body)
	theme.set_font_size(&"font_size", &"TooltipLabel", BODY_SIZE)
	theme.set_stylebox(&"panel", &"ScrollContainer", StyleBoxEmpty.new())


func _ranges(theme: Theme) -> void:
	for pair: Array in [["ProgressBar", _c.accent_deep], ["OkProgressBar", _c.ok], ["WarningProgressBar", _c.warning],
			["CriticalProgressBar", _c.critical], ["AccentProgressBar", _c.accent]]:
		var type := StringName(pair[0])
		if type != &"ProgressBar":
			theme.set_type_variation(type, &"ProgressBar")
		theme.set_stylebox(&"background", type, _flat(_c.bg_deep, _c.divider, 1, 0, 0))
		var fill := _flat(pair[1], Color.TRANSPARENT, 0, 0, 0)
		# Keep the fill inside the one-pixel track border.
		fill.border_color = _c.bg_deep
		fill.set_border_width_all(2 if not _contrast else 3)
		theme.set_stylebox(&"fill", type, fill)
		theme.set_color(&"font_color", type, _c.text)
		theme.set_font(&"font", type, _caption)
		theme.set_font_size(&"font_size", type, CAPTION_SIZE)
	var track := _flat(_c.surface, Color.TRANSPARENT, 0, 0, 0)
	track.content_margin_top = 2
	track.content_margin_bottom = 2
	var filled := _flat(_c.accent_deep, Color.TRANSPARENT, 0, 0, 0)
	var filled_bright := _flat(_c.accent, Color.TRANSPARENT, 0, 0, 0)
	theme.set_stylebox(&"slider", &"HSlider", track)
	theme.set_stylebox(&"grabber_area", &"HSlider", filled)
	theme.set_stylebox(&"grabber_area_highlight", &"HSlider", filled_bright)
	theme.set_icon(&"grabber", &"HSlider", _grabber_icon(_c.text_secondary))
	theme.set_icon(&"grabber_highlight", &"HSlider", _grabber_icon(_c.accent_bright))
	theme.set_icon(&"grabber_disabled", &"HSlider", _grabber_icon(_c.divider))
	theme.set_icon(&"tick", &"HSlider", _pixels(["#", "#", "#"], {"#": _c.divider}))
	for type: StringName in [&"VScrollBar", &"HScrollBar"]:
		var groove := _flat(_c.bg_deep, Color.TRANSPARENT, 0, 0, 0)
		groove.content_margin_left = 3
		groove.content_margin_right = 3
		groove.content_margin_top = 3
		groove.content_margin_bottom = 3
		theme.set_stylebox(&"scroll", type, groove)
		theme.set_stylebox(&"scroll_focus", type, groove)
		theme.set_stylebox(&"grabber", type, _flat(_c.divider, Color.TRANSPARENT, 0, 0, 0))
		theme.set_stylebox(&"grabber_highlight", type, _flat(_c.accent_deep, Color.TRANSPARENT, 0, 0, 0))
		theme.set_stylebox(&"grabber_pressed", type, _flat(_c.accent, Color.TRANSPARENT, 0, 0, 0))
	for type: StringName in [&"HSeparator", &"VSeparator"]:
		var line := StyleBoxLine.new()
		line.color = _c.divider if _contrast else Color(_c.divider, 0.7)
		line.thickness = 2 if _contrast else 1
		line.vertical = type == &"VSeparator"
		theme.set_stylebox(&"separator", type, line)
		theme.set_constant(&"separation", type, 5)


func _tabs(theme: Theme) -> void:
	var selected := _flat(_c.surface, Color.TRANSPARENT, 0, 10, 4)
	selected.border_color = _c.accent
	selected.border_width_top = 2
	var unselected := _flat(_c.bg_raised, Color.TRANSPARENT, 0, 10, 4)
	unselected.border_color = _c.bg_raised
	unselected.border_width_top = 2
	var hovered := _flat(_c.surface, Color.TRANSPARENT, 0, 10, 4)
	hovered.border_color = _c.divider
	hovered.border_width_top = 2
	for type: StringName in [&"TabBar", &"TabContainer"]:
		theme.set_stylebox(&"tab_selected", type, selected)
		theme.set_stylebox(&"tab_unselected", type, unselected)
		theme.set_stylebox(&"tab_hovered", type, hovered)
		theme.set_stylebox(&"tab_disabled", type, unselected)
		theme.set_stylebox(&"tab_focus", type, _focus(0))
		theme.set_color(&"font_selected_color", type, _c.text)
		theme.set_color(&"font_unselected_color", type, _c.text_muted)
		theme.set_color(&"font_hovered_color", type, _c.accent_bright)
		theme.set_color(&"font_disabled_color", type, Color(_c.text_muted, 0.6))
		theme.set_font(&"font", type, _body)
		theme.set_font_size(&"font_size", type, BODY_SIZE)
		theme.set_constant(&"h_separation", type, 4)
	theme.set_stylebox(&"panel", &"TabContainer", _flat(_c.bg, _c.divider, 1, 10, 8))
	theme.set_stylebox(&"tabbar_background", &"TabContainer", StyleBoxEmpty.new())


func _misc(theme: Theme) -> void:
	theme.set_color(&"default_color", &"RichTextLabel", _c.text)
	theme.set_font(&"normal_font", &"RichTextLabel", _body)
	theme.set_font(&"bold_font", &"RichTextLabel", _body)
	theme.set_font_size(&"normal_font_size", &"RichTextLabel", BODY_SIZE)
	theme.set_font_size(&"bold_font_size", &"RichTextLabel", BODY_SIZE)
	theme.set_constant(&"line_separation", &"RichTextLabel", 2)
	theme.set_stylebox(&"normal", &"RichTextLabel", StyleBoxEmpty.new())
	theme.set_stylebox(&"focus", &"RichTextLabel", StyleBoxEmpty.new())
	for type: StringName in [&"BoxContainer", &"HBoxContainer", &"VBoxContainer"]:
		theme.set_constant(&"separation", type, 4)
	theme.set_constant(&"h_separation", &"GridContainer", 4)
	theme.set_constant(&"v_separation", &"GridContainer", 4)
	for name: String in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		theme.set_constant(StringName(name), &"MarginContainer", 0)


func _pixels(rows: PackedStringArray, colors: Dictionary) -> ImageTexture:
	var image := Image.create(rows[0].length(), rows.size(), false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y: int in rows.size():
		for x: int in rows[y].length():
			var key: String = rows[y][x]
			if colors.has(key):
				image.set_pixel(x, y, colors[key])
	return ImageTexture.create_from_image(image)


func _box_icon(size: int, border: Color, fill: Color, mark: Color) -> ImageTexture:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(border)
	var inset: int = 2 if _contrast else 1
	image.fill_rect(Rect2i(inset, inset, size - inset * 2, size - inset * 2), fill)
	if mark.a > 0.0:
		image.fill_rect(Rect2i(3, 3, size - 6, size - 6), mark)
	return ImageTexture.create_from_image(image)


func _switch_icon(on: bool, disabled: bool) -> ImageTexture:
	var image := Image.create(22, 11, false, Image.FORMAT_RGBA8)
	var border: Color = _c.surface if disabled else (_c.accent if on else _c.divider)
	image.fill(border)
	image.fill_rect(Rect2i(1, 1, 20, 9), (_c.accent_deep if on and not disabled else _c.bg_deep))
	var knob: Color = _c.divider if disabled else (_c.text if on else _c.text_muted)
	image.fill_rect(Rect2i(12 if on else 3, 3, 7, 5), knob)
	return ImageTexture.create_from_image(image)


func _grabber_icon(color: Color) -> ImageTexture:
	var image := Image.create(7, 13, false, Image.FORMAT_RGBA8)
	image.fill(_c.bg_deep)
	image.fill_rect(Rect2i(1, 1, 5, 11), color)
	return ImageTexture.create_from_image(image)
