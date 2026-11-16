class_name AppSettings
extends RefCounted
## Player presentation and input preferences stored in a small ConfigFile.
## This is not a save-game system: no world, inventory or mission state is written.

signal changed

const DEFAULT_PATH: String = "user://settings.cfg"
const UI_SCALES: Array[float] = [1.0, 1.25, 1.5]
const WINDOW_SCALES: Array[int] = [1, 2, 3, 4]
const BASE_SIZE: Vector2i = Vector2i(960, 540)
## Actions offered for keyboard rebinding. Esc stays fixed so a panel can always be closed.
const REMAPPABLE: Array[StringName] = [
	&"player_move_up", &"player_move_down", &"player_move_left", &"player_move_right",
	&"interact_primary", &"inventory_toggle", &"mode_switch", &"hud_details", &"dialogue_advance",
	&"dashboard_previous", &"dashboard_next",
	&"player_run",
]
const ACTION_TITLES: Dictionary[StringName, String] = {
	&"player_move_up": "Move up", &"player_move_down": "Move down", &"player_move_left": "Move left",
	&"player_move_right": "Move right", &"interact_primary": "Interact", &"inventory_toggle": "Inventory",
	&"mode_switch": "Switch mode", &"hud_details": "Status details", &"dialogue_advance": "Dismiss message",
	&"dashboard_previous": "Dashboard: previous", &"dashboard_next": "Dashboard: next",
	&"player_run": "Hold to run",
}
const RESERVED_KEYS: Array[Key] = [KEY_ESCAPE, KEY_F11]
## Interface actions introduced with the Mission OS interface. project.godot declares them too;
## registering them here keeps the interface working if a stale project file omits them.
const INTERFACE_ACTIONS: Dictionary[StringName, Key] = {
	&"hud_details": KEY_H, &"dialogue_advance": KEY_SPACE,
	&"dashboard_previous": KEY_Z, &"dashboard_next": KEY_X,
}

static var _shared: AppSettings

var path: String = DEFAULT_PATH
var fullscreen: bool = false
var window_scale: int = 1
var vsync: bool = true
var ui_scale: float = 1.0
var high_contrast: bool = false
var reduced_motion: bool = false
## True once the player has chosen display values; launch flags such as --fullscreen win until then.
var display_customized: bool = false
## Last decorated window rectangle, independent of fullscreen and gameplay camera zoom.
var windowed_rect: Rect2i = Rect2i()
var _display_window: Window
var _display_revision: int = 0
var _changing_display: bool = false
var _last_window_rect: Rect2i = Rect2i()
var bindings: Dictionary[StringName, int] = {}
var _defaults: Dictionary[StringName, int] = {}


static func shared() -> AppSettings:
	if _shared == null:
		_shared = AppSettings.new()
		_shared.load_settings()
		_shared.apply_runtime()
	return _shared


## Replaces the process-wide instance; tests use an isolated file.
static func replace_shared(instance: AppSettings) -> void:
	if _shared != null:
		_shared.detach_window()
	_shared = instance
	if _shared != null:
		_shared.apply_runtime()


static func ensure_interface_actions() -> void:
	for action: StringName in INTERFACE_ACTIONS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var key := InputEventKey.new()
		key.physical_keycode = INTERFACE_ACTIONS[action]
		InputMap.action_add_event(action, key)
	if not InputMap.has_action(&"player_run"):
		InputMap.add_action(&"player_run")
		var run_key := InputEventKey.new()
		run_key.physical_keycode = KEY_SHIFT
		InputMap.action_add_event(&"player_run", run_key)
	if not InputMap.has_action(&"display_fullscreen_toggle"):
		InputMap.add_action(&"display_fullscreen_toggle")
		for code: Key in [KEY_F11, KEY_ENTER]:
			var toggle := InputEventKey.new()
			toggle.physical_keycode = code
			toggle.alt_pressed = code == KEY_ENTER
			InputMap.action_add_event(&"display_fullscreen_toggle", toggle)


func _init(settings_path: String = DEFAULT_PATH) -> void:
	path = settings_path
	ensure_interface_actions()
	for action: StringName in REMAPPABLE:
		_defaults[action] = _project_key(action)
		bindings[action] = _defaults[action]


func load_settings() -> bool:
	var file := ConfigFile.new()
	if file.load(path) != OK:
		return false
	display_customized = bool(file.get_value("display", "customized", false))
	fullscreen = bool(file.get_value("display", "fullscreen", false))
	var stored_scale: Variant = file.get_value("display", "window_scale", 1)
	window_scale = _nearest_int(int(stored_scale), WINDOW_SCALES) if stored_scale is int or stored_scale is float else 1
	var stored_rect: Variant = file.get_value("display", "windowed_rect", Rect2i())
	windowed_rect = stored_rect if stored_rect is Rect2i and stored_rect.size.x > 0 and stored_rect.size.y > 0 else Rect2i()
	vsync = bool(file.get_value("display", "vsync", true))
	var stored_ui: Variant = file.get_value("interface", "ui_scale", 1.0)
	ui_scale = _nearest_float(float(stored_ui), UI_SCALES) if stored_ui is int or stored_ui is float else 1.0
	high_contrast = bool(file.get_value("interface", "high_contrast", false))
	reduced_motion = bool(file.get_value("interface", "reduced_motion", false))
	for action: StringName in REMAPPABLE:
		var stored: Variant = file.get_value("input", String(action), _defaults[action])
		bindings[action] = int(stored) if (stored is int or stored is float) and _key_allowed(int(stored)) else _defaults[action]
	_resolve_duplicates()
	return true


func save_settings() -> bool:
	var file := ConfigFile.new()
	file.set_value("display", "customized", display_customized)
	file.set_value("display", "fullscreen", fullscreen)
	file.set_value("display", "window_scale", window_scale)
	file.set_value("display", "windowed_rect", windowed_rect)
	file.set_value("display", "vsync", vsync)
	file.set_value("interface", "ui_scale", ui_scale)
	file.set_value("interface", "high_contrast", high_contrast)
	file.set_value("interface", "reduced_motion", reduced_motion)
	for action: StringName in REMAPPABLE:
		file.set_value("input", String(action), bindings[action])
	return file.save(path) == OK


## Interface and input preferences. Display state is applied separately by apply_display().
func apply_runtime() -> void:
	UiMotion.reduced = reduced_motion
	for action: StringName in REMAPPABLE:
		_apply_binding(action)
	changed.emit()


func apply_display(window: Window) -> void:
	configure_window(window)
	if not display_customized or window == null or DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	var was_fullscreen: bool = window.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]
	if fullscreen and not was_fullscreen:
		remember_window(window)
	_changing_display = true
	_display_revision += 1
	var revision: int = _display_revision
	# Godot's non-exclusive fullscreen is the supported borderless mode, on this window's monitor.
	window.mode = Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
	if not fullscreen:
		window.borderless = false
		var usable: Rect2i = DisplayServer.screen_get_usable_rect(window.current_screen)
		var decoration: Vector2i = window.get_size_with_decorations() - window.size
		var decoration_offset: Vector2i = window.position - window.get_position_with_decorations()
		var wanted: Rect2i = windowed_rect
		if wanted.size == Vector2i.ZERO:
			wanted.size = BASE_SIZE * window_scale
			wanted.position = usable.position + (usable.size - wanted.size - decoration) / 2 + decoration_offset
		var fitted: Rect2i = fit_window_rect(wanted, usable, decoration, decoration_offset)
		window.size = fitted.size
		window.position = fitted.position
	_update_presentation()
	_finish_display.call_deferred(revision)


## Always bind scaling, even before the first saved display preference or with launch flags.
func configure_window(window: Window) -> void:
	if window == null:
		return
	if _display_window != window:
		detach_window()
		_display_window = window
		_last_window_rect = Rect2i(window.position, window.size)
		window.size_changed.connect(_on_window_resized)
		window.get_tree().process_frame.connect(_watch_window)
		if not display_customized:
			fullscreen = window.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]
	window.content_scale_size = BASE_SIZE
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	window.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_update_presentation()


func detach_window() -> void:
	if is_instance_valid(_display_window) and _display_window.size_changed.is_connected(_on_window_resized):
		_display_window.size_changed.disconnect(_on_window_resized)
		if _display_window.get_tree().process_frame.is_connected(_watch_window):
			_display_window.get_tree().process_frame.disconnect(_watch_window)
	_display_window = null
	_display_revision += 1


static func integer_presentation(size: Vector2i) -> bool:
	var factor: float = minf(float(size.x) / BASE_SIZE.x, float(size.y) / BASE_SIZE.y)
	return factor >= 1.0 and is_equal_approx(factor, roundf(factor))


static func presentation_rect(size: Vector2i) -> Rect2:
	var factor: float = minf(float(size.x) / BASE_SIZE.x, float(size.y) / BASE_SIZE.y)
	var extent: Vector2 = (Vector2(BASE_SIZE) * maxf(0.0, factor)).floor()
	return Rect2(((Vector2(size) - extent) / 2.0).round(), extent)


static func fit_window_rect(wanted: Rect2i, usable: Rect2i, decoration: Vector2i = Vector2i.ZERO, decoration_offset: Vector2i = Vector2i.ZERO) -> Rect2i:
	var available: Vector2i = (usable.size - decoration.max(Vector2i.ZERO)).max(Vector2i.ONE)
	var extent: Vector2i = wanted.size.max(BASE_SIZE.min(available)).min(available)
	var minimum: Vector2i = usable.position + decoration_offset
	var maximum: Vector2i = minimum + available - extent
	var point := Vector2i(clampi(wanted.position.x, minimum.x, maximum.x), clampi(wanted.position.y, minimum.y, maximum.y))
	return Rect2i(point, extent)


func remember_window(window: Window) -> void:
	if is_instance_valid(window) and window.mode == Window.MODE_WINDOWED and not _changing_display:
		windowed_rect = Rect2i(window.position, window.size)


func toggle_fullscreen(window: Window) -> void:
	set_display(window.mode not in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN], window_scale, vsync, true)
	apply_display(window)
	save_settings()


func _update_presentation() -> void:
	if not is_instance_valid(_display_window):
		return
	var wanted: Window.ContentScaleStretch = Window.CONTENT_SCALE_STRETCH_INTEGER if integer_presentation(_display_window.size) else Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	if _display_window.content_scale_stretch != wanted:
		_display_window.content_scale_stretch = wanted


func _on_window_resized() -> void:
	_update_presentation()
	if _changing_display or not is_instance_valid(_display_window) or _display_window.mode != Window.MODE_WINDOWED:
		return
	remember_window(_display_window)
	display_customized = true
	_display_revision += 1
	_save_window_later(_display_revision)


func _watch_window() -> void:
	if not is_instance_valid(_display_window):
		return
	var rect := Rect2i(_display_window.position, _display_window.size)
	if rect != _last_window_rect:
		_last_window_rect = rect
		# Viewport.size_changed need not fire when only the native size changes and the
		# internal viewport stays 960x540. This cheap comparison also captures window moves.
		_on_window_resized()


func _save_window_later(revision: int) -> void:
	await _display_window.get_tree().create_timer(0.3, true).timeout
	if revision == _display_revision and is_instance_valid(_display_window) and not _changing_display:
		save_settings()


func _finish_display(revision: int) -> void:
	if not is_instance_valid(_display_window):
		return
	# Native size notifications can arrive after changing mode. Do not capture fullscreen bounds.
	for frame: int in 3:
		await _display_window.get_tree().process_frame
		if revision != _display_revision or not is_instance_valid(_display_window):
			return
	_changing_display = false
	_update_presentation()
	remember_window(_display_window)


func set_display(use_fullscreen: bool, scale: int, use_vsync: bool, preserve_window: bool = false) -> void:
	remember_window(_display_window)
	if not preserve_window or _nearest_int(scale, WINDOW_SCALES) != window_scale:
		windowed_rect = Rect2i()
	fullscreen = use_fullscreen
	window_scale = _nearest_int(scale, WINDOW_SCALES)
	vsync = use_vsync
	display_customized = true
	changed.emit()


func set_interface(scale: float, contrast: bool, reduce_motion: bool) -> void:
	ui_scale = _nearest_float(scale, UI_SCALES)
	high_contrast = contrast
	reduced_motion = reduce_motion
	UiMotion.reduced = reduced_motion
	changed.emit()


## Rebinds one action's keyboard key. A key already used by another remappable action is swapped.
func rebind(action: StringName, physical_keycode: int) -> bool:
	if action not in REMAPPABLE or not _key_allowed(physical_keycode):
		return false
	var previous: int = bindings[action]
	for other: StringName in REMAPPABLE:
		if other != action and bindings[other] == physical_keycode:
			bindings[other] = previous
			_apply_binding(other)
	bindings[action] = physical_keycode
	_apply_binding(action)
	changed.emit()
	return true


func reset_bindings() -> void:
	for action: StringName in REMAPPABLE:
		bindings[action] = _defaults[action]
		_apply_binding(action)
	changed.emit()


func reset_all() -> void:
	fullscreen = false
	windowed_rect = Rect2i()
	window_scale = 1
	vsync = true
	display_customized = false
	ui_scale = 1.0
	high_contrast = false
	reduced_motion = false
	UiMotion.reduced = false
	reset_bindings()


func default_key(action: StringName) -> int:
	return _defaults.get(action, KEY_NONE)


func theme() -> Theme:
	return UiKit.theme(high_contrast)


func _apply_binding(action: StringName) -> void:
	if not InputMap.has_action(action):
		return
	var replaced: bool = false
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			if event.physical_keycode == bindings[action]:
				return
			InputMap.action_erase_event(action, event)
			replaced = true
			break
	if replaced or bindings[action] != KEY_NONE:
		var key := InputEventKey.new()
		key.physical_keycode = bindings[action] as Key
		InputMap.action_add_event(action, key)


func _project_key(action: StringName) -> int:
	# Defaults always come from project.godot, never from a previously remapped InputMap.
	var setting: Variant = ProjectSettings.get_setting("input/" + String(action))
	if setting is Dictionary:
		for event: Variant in setting.get("events", []):
			if event is InputEventKey:
				return event.physical_keycode if event.physical_keycode != 0 else event.keycode
	return INTERFACE_ACTIONS.get(action, KEY_NONE)


func _key_allowed(code: int) -> bool:
	return code > 0 and code not in RESERVED_KEYS and not OS.get_keycode_string(code as Key).is_empty()


func _resolve_duplicates() -> void:
	var used: Dictionary[int, bool] = {}
	var pending: Array[StringName] = []
	for action: StringName in REMAPPABLE:
		if used.has(bindings[action]):
			pending.append(action)
			continue
		used[bindings[action]] = true
	for action: StringName in pending:
		var replacement: int = _defaults[action]
		if used.has(replacement):
			for candidate: int in _defaults.values():
				if not used.has(candidate):
					replacement = candidate
					break
		bindings[action] = replacement
		used[replacement] = true


static func _nearest_int(value: int, allowed: Array[int]) -> int:
	return value if value in allowed else allowed[0]


static func _nearest_float(value: float, allowed: Array[float]) -> float:
	for option: float in allowed:
		if is_equal_approx(option, value):
			return option
	return allowed[0]
