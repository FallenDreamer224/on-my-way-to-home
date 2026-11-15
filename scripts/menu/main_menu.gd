class_name MainMenu
extends Node
## Title screen: animated lunar backdrop, title and the five menu entries.
## It requests actions through signals; the application root owns sessions and quitting.

signal new_game_requested
signal continue_requested
signal quit_requested

const TITLE: String = "ON MY WAY TO HOME"
const WINDOW_SIZE: Vector2 = Vector2(600, 336)
const ENTRIES: Array[Array] = [
	[&"new_game", "New Game"], [&"continue", "Continue"], [&"settings", "Settings"],
	[&"credits", "Credits"], [&"quit", "Quit"],
]

var settings: AppSettings
var backdrop: MenuBackdrop
var layer: CanvasLayer
var root: Control
var title: Label
var subtitle: Label
var buttons: Dictionary[StringName, Button] = {}
var continue_note: Label
var version_label: Label
var window: MissionPanel
var window_title: Label
var settings_panel: SettingsPanel
var credits_view: CreditsView
var scrim: ColorRect
## Set by the application root. No save system exists yet, so this stays false.
var save_available: bool = false:
	set(value):
		save_available = value
		_refresh_continue()
var _last_focus: Button
var _entrance: Array[Control] = []


func _ready() -> void:
	settings = AppSettings.shared()
	backdrop = MenuBackdrop.new()
	backdrop.name = "Backdrop"
	add_child(backdrop)
	layer = CanvasLayer.new()
	layer.name = "UI"
	layer.layer = 10
	add_child(layer)
	root = Control.new()
	root.name = "Root"
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.add_child(root)
	_build_legibility_bands()
	_build_title()
	_build_entries()
	_build_window()
	settings.changed.connect(_apply_settings)
	get_viewport().size_changed.connect(_apply_settings)
	_apply_settings()
	_refresh_continue()
	_play_entrance()
	buttons[&"new_game"].grab_focus()


func is_window_open() -> bool:
	return window.visible


func open_settings() -> void:
	_open_window("SETTINGS", settings_panel)
	settings_panel.refresh()
	settings_panel.tabs.grab_focus()


func open_credits() -> void:
	_open_window("CREDITS", credits_view)
	credits_view.grab_focus()


func close_window() -> void:
	if not window.visible:
		return
	window.hide()
	scrim.hide()
	if is_instance_valid(_last_focus):
		_last_focus.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"game_pause") and not event.is_echo() and window.visible:
		if not settings_panel.is_capturing():
			close_window()
		get_viewport().set_input_as_handled()


func _build_legibility_bands() -> void:
	# Stepped darkening behind the menu column; hard steps suit the pixel presentation.
	var widths: Array[float] = [304, 40, 40]
	var alphas: Array[float] = [0.8, 0.52, 0.24]
	var x: float = 0.0
	for index: int in widths.size():
		var band := ColorRect.new()
		band.name = "Band%d" % index
		band.color = Color(MenuBackdrop.SPACE_COLOR, alphas[index])
		band.anchor_bottom = 1.0
		band.offset_left = x
		band.offset_right = x + widths[index]
		band.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(band)
		x += widths[index]


func _build_title() -> void:
	var block := UiKit.vbox(2)
	block.name = "TitleBlock"
	block.position = Vector2(44, 52)
	root.add_child(block)
	block.add_child(UiKit.label("LUNAR MISSION OPERATING SYSTEM", &"CaptionAccentLabel"))
	title = UiKit.label(TITLE, &"TitleLabel")
	title.name = "Title"
	block.add_child(title)
	subtitle = UiKit.label("MOON TUTORIAL", &"SectionLabel")
	subtitle.name = "Subtitle"
	block.add_child(subtitle)
	_entrance.append(block)


func _build_entries() -> void:
	var column := UiKit.vbox(2)
	column.name = "Entries"
	column.position = Vector2(34, 232)
	root.add_child(column)
	for entry: Array in ENTRIES:
		var button: Button = UiKit.button(entry[1], &"TitleMenuButton", _activate.bind(entry[0]))
		button.name = String(entry[0]).to_pascal_case()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.x = 250
		button.mouse_entered.connect(func() -> void:
			if not button.disabled and not window.visible:
				button.grab_focus())
		column.add_child(button)
		buttons[entry[0]] = button
		_entrance.append(button)
		if entry[0] == &"continue":
			continue_note = UiKit.label("", &"CaptionLabel")
			continue_note.name = "ContinueNote"
			column.add_child(continue_note)
	# Footer stays inside the darkened menu column, where small captions remain readable.
	var footer := UiKit.vbox(3)
	footer.name = "Footer"
	footer.anchor_top = 1.0
	footer.anchor_bottom = 1.0
	footer.offset_left = 44
	footer.offset_right = 300
	footer.offset_top = -40
	footer.offset_bottom = -12
	footer.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(footer)
	footer.add_child(UiKit.label("ARROWS / MOUSE: SELECT   ENTER: CONFIRM", &"CaptionLabel"))
	version_label = UiKit.label(_version_text(), &"CaptionLabel")
	version_label.name = "Version"
	footer.add_child(version_label)


func _build_window() -> void:
	scrim = ColorRect.new()
	scrim.name = "Scrim"
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.hide()
	root.add_child(scrim)
	window = MissionPanel.new()
	window.name = "Window"
	window.hide()
	root.add_child(window)
	var column := UiKit.vbox(8)
	window.add_child(column)
	var header: HBoxContainer = UiKit.window_header("", &"gear", "Back [Esc]", close_window)
	window_title = header.get_node("Title")
	column.add_child(header)
	settings_panel = SettingsPanel.new()
	settings_panel.bind(settings)
	column.add_child(settings_panel)
	credits_view = CreditsView.new()
	credits_view.focus_mode = Control.FOCUS_ALL
	column.add_child(credits_view)


func _open_window(heading: String, page: Control) -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	_last_focus = focused as Button if focused is Button else buttons[&"new_game"]
	window_title.text = heading
	settings_panel.visible = page == settings_panel
	credits_view.visible = page == credits_view
	scrim.show()
	window.show()
	UiKit.center_modal(window, WINDOW_SIZE)
	UiMotion.fade_in(window, UiMotion.FAST)


func _activate(entry: StringName) -> void:
	if window.visible:
		return
	match entry:
		&"new_game":
			new_game_requested.emit()
		&"continue":
			if save_available:
				continue_requested.emit()
		&"settings":
			open_settings()
		&"credits":
			open_credits()
		&"quit":
			quit_requested.emit()


func _refresh_continue() -> void:
	if not buttons.has(&"continue"):
		return
	buttons[&"continue"].disabled = not save_available
	buttons[&"continue"].focus_mode = Control.FOCUS_ALL if save_available else Control.FOCUS_NONE
	continue_note.text = "" if save_available else "      NO SAVED SESSION: SAVING IS NOT AVAILABLE YET"


func _apply_settings() -> void:
	# Freeze the existing diorama and its bound patrol/twinkle tweens immediately.
	# The menu interface is a sibling, so settings remain responsive.
	backdrop.process_mode = Node.PROCESS_MODE_DISABLED if settings.reduced_motion else Node.PROCESS_MODE_INHERIT
	layer.scale = Vector2(settings.ui_scale, settings.ui_scale)
	root.theme = settings.theme()
	var view: Vector2 = root.get_viewport_rect().size
	root.position = Vector2.ZERO
	root.size = view / settings.ui_scale
	scrim.color = settings.theme().get_color(&"scrim", UiKit.TOKENS)
	if window.visible:
		UiKit.center_modal(window, WINDOW_SIZE)


func _play_entrance() -> void:
	if UiMotion.reduced:
		return
	# Title first, then each entry in turn.
	for index: int in _entrance.size():
		var item: Control = _entrance[index]
		item.modulate.a = 0.0
		var tween: Tween = item.create_tween()
		tween.tween_interval(0.25 + 0.09 * index)
		tween.tween_property(item, "modulate:a", 1.0, 0.3)


static func _version_text() -> String:
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	return ("VERSION " + version if not version.is_empty() else "DEVELOPMENT BUILD") + "  /  PHASE 0.8F"
