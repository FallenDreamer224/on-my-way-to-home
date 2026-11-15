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
]
const ACTION_TITLES: Dictionary[StringName, String] = {
	&"player_move_up": "Move up", &"player_move_down": "Move down", &"player_move_left": "Move left",
	&"player_move_right": "Move right", &"interact_primary": "Interact", &"inventory_toggle": "Inventory",
	&"mode_switch": "Switch mode", &"hud_details": "Status details", &"dialogue_advance": "Dismiss message",
	&"dashboard_previous": "Dashboard: previous", &"dashboard_next": "Dashboard: next",
}
const RESERVED_KEYS: Array[Key] = [KEY_ESCAPE]
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
	window_scale = _nearest_int(int(file.get_value("display", "window_scale", 1)), WINDOW_SCALES)
	vsync = bool(file.get_value("display", "vsync", true))
	ui_scale = _nearest_float(float(file.get_value("interface", "ui_scale", 1.0)), UI_SCALES)
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
	if not display_customized or window == null or DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	var want_fullscreen: bool = fullscreen
	var is_fullscreen: bool = window.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]
	if want_fullscreen != is_fullscreen:
		window.mode = Window.MODE_FULLSCREEN if want_fullscreen else Window.MODE_WINDOWED
	if not want_fullscreen:
		var target: Vector2i = BASE_SIZE * window_scale
		var screen: Rect2i = DisplayServer.screen_get_usable_rect(window.current_screen)
		# Never request a window larger than the usable desktop area.
		while target.x > screen.size.x or target.y > screen.size.y:
			if target == BASE_SIZE:
				break
			target -= BASE_SIZE
		if window.size != target:
			window.size = target
			window.position = screen.position + Vector2i(Vector2(screen.size - target) * 0.5)


func set_display(use_fullscreen: bool, scale: int, use_vsync: bool) -> void:
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
	for action: StringName in REMAPPABLE:
		if used.has(bindings[action]):
			bindings[action] = _defaults[action]
		used[bindings[action]] = true


static func _nearest_int(value: int, allowed: Array[int]) -> int:
	return value if value in allowed else allowed[0]


static func _nearest_float(value: float, allowed: Array[float]) -> float:
	for option: float in allowed:
		if is_equal_approx(option, value):
			return option
	return allowed[0]
