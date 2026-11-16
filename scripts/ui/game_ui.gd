class_name GameUI
extends CanvasLayer
## Composition boundary for the passive HUD, the interaction prompt, modal windows, the Base
## Management dashboard and the mission menu. It applies player interface preferences
## (theme, scale) and routes the few interface-only shortcuts. Gameplay state stays in systems.

signal return_to_menu_requested
signal quit_requested

@onready var hud: GameHUD = $GameHUD
@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt
@onready var inventory_window: InventoryWindow = $InventoryWindow
var scrim: ColorRect
var dashboard: ManagementDashboard
var system_menu: SystemMenu
var settings: AppSettings
var session: PlayerSession
var modes: GameplayModeCoordinator
var director: HabitatDirector
var dialogue: ChiwisDialogue
## True when an application root handles returning to the main menu and quitting.
var hosted: bool = false:
	set(value):
		hosted = value
		if system_menu != null:
			system_menu.allow_return = value
var _modals: Array[Control] = []
var _paused_by_menu: bool = false


func _ready() -> void:
	# The mission menu pauses the session; the interface itself keeps responding.
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = AppSettings.shared()
	settings.configure_window(get_window())
	scrim = ColorRect.new()
	scrim.name = "Scrim"
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.hide()
	add_child(scrim)
	move_child(scrim, inventory_window.get_index())
	system_menu = SystemMenu.new()
	system_menu.allow_return = hosted
	system_menu.close_requested.connect(close_system_menu)
	system_menu.return_to_menu_requested.connect(_return_to_menu)
	system_menu.quit_requested.connect(_quit)
	add_child(system_menu)
	register_modal(inventory_window)
	register_modal(system_menu)
	settings.changed.connect(_apply_settings)
	get_viewport().size_changed.connect(_apply_settings)
	_apply_settings()


func configure(items: RuntimeInventory, detector: InteractionDetector, coordinator: GameplayModeCoordinator, camera: BaseManagementCameraRig, show_development: bool) -> void:
	modes = coordinator
	inventory_window.configure(items)
	interaction_prompt.configure(detector)
	interaction_prompt.notice_requested.connect(_interaction_notice)
	hud.configure(modes, camera, inventory_window, show_development)
	modes.mode_changed.connect(_mode_changed)


## Connects the presentation to session systems. Any argument may be null in reduced compositions.
func bind_systems(player_session: PlayerSession, habitat: HabitatDirector, utilities: UtilityService, safety: EvaSafetyMonitor,
		routines: DailyLife, tracker: ObjectiveTracker, companion: ChiwisDialogue, items: RuntimeInventory) -> void:
	session = player_session
	director = habitat
	dialogue = companion
	hud.bind_systems(habitat, utilities, safety, tracker, companion)
	var database: EquipmentDatabase = EquipmentDatabase.load_default()
	system_menu.bind(settings, companion, database)
	dashboard = ManagementDashboard.new()
	add_child(dashboard)
	move_child(dashboard, scrim.get_index())
	dashboard.theme = settings.theme()
	dashboard.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	dashboard.configure(utilities, routines, items, habitat, tracker, companion, database)
	dashboard.database_requested.connect(func() -> void: open_system_menu(&"database"))
	_mode_changed(modes.current_mode if is_instance_valid(modes) else GameplayModeCoordinator.Mode.PLAYER)


## Adds a modal window above the scrim and tracks its visibility for dimming and dialogue hold.
func register_modal(window: Control) -> void:
	if window.get_parent() == null:
		add_child(window)
	if window not in _modals:
		_modals.append(window)
		window.visibility_changed.connect(_modal_visibility_changed)
	window.theme = settings.theme()
	window.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fit(window)
	if is_instance_valid(system_menu) and system_menu.get_parent() == self:
		move_child(system_menu, get_child_count() - 1)


func notify(text: String, duration: float = 3.5, level: NotificationArea.Level = NotificationArea.Level.INFO) -> bool:
	return hud.notifications.post_message(text, duration, level)


func refresh_bindings() -> void:
	hud.refresh_bindings()
	interaction_prompt.refresh_prompt()
	system_menu.refresh_bindings()
	if dashboard != null:
		dashboard.refresh_bindings()


func is_modal_open() -> bool:
	for window: Control in _modals:
		if is_instance_valid(window) and window.visible:
			return true
	return false


func open_system_menu(page: StringName = &"overview") -> bool:
	if system_menu.visible or is_modal_open():
		return false
	# Hatch and pressure transactions finish first; they are never frozen half-way.
	if is_instance_valid(session) and session.transition_blocked:
		return false
	if is_instance_valid(director) and director.busy:
		return false
	if is_instance_valid(session):
		session.set_inspection_blocked(true)
	_paused_by_menu = not get_tree().paused
	get_tree().paused = true
	system_menu.open(page)
	return true


func close_system_menu() -> void:
	if not system_menu.visible:
		return
	system_menu.close()
	if _paused_by_menu:
		get_tree().paused = false
	_paused_by_menu = false
	if is_instance_valid(session):
		session.set_inspection_blocked(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed(&"game_pause"):
		if system_menu.visible:
			system_menu.handle_back()
			get_viewport().set_input_as_handled()
		elif open_system_menu():
			get_viewport().set_input_as_handled()
		return
	if is_modal_open() or get_viewport().gui_get_focus_owner() != null:
		return
	if event.is_action_pressed(&"hud_details"):
		hud.toggle_details()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"dialogue_advance") and is_instance_valid(dialogue) and dialogue.is_speaking():
		dialogue.dismiss()
		get_viewport().set_input_as_handled()
	elif dashboard != null and dashboard.visible:
		if event.is_action_pressed(&"dashboard_next"):
			dashboard.step(1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(&"dashboard_previous"):
			dashboard.step(-1)
			get_viewport().set_input_as_handled()


func _mode_changed(mode: GameplayModeCoordinator.Mode) -> void:
	if dashboard != null:
		dashboard.set_open(mode == GameplayModeCoordinator.Mode.BASE_MANAGEMENT)


func _modal_visibility_changed() -> void:
	var open: bool = is_modal_open()
	if open and not scrim.visible:
		UiMotion.fade_in(scrim, UiMotion.FAST)
	elif not open and scrim.visible:
		UiMotion.stop(scrim)
		scrim.hide()
	# A companion line should not expire unread behind a window.
	if is_instance_valid(dialogue):
		dialogue.hold = open


func _apply_settings() -> void:
	var active: Theme = settings.theme()
	scale = Vector2(settings.ui_scale, settings.ui_scale)
	for child: Node in get_children():
		if child is Control:
			_fit(child)
			if child != scrim:
				(child as Control).theme = active
	scrim.color = active.get_color(&"scrim", UiKit.TOKENS)
	if is_node_ready():
		refresh_bindings()


## Anchors are fractions of the viewport. Dividing the authored anchors by the layer scale
## keeps every anchored control on screen at any interface scale; offsets stay as authored.
func _fit(control: Control) -> void:
	if not control.has_meta(&"authored_anchors"):
		control.set_meta(&"authored_anchors", [control.anchor_left, control.anchor_top, control.anchor_right, control.anchor_bottom])
	var authored: Array = control.get_meta(&"authored_anchors")
	var factor: float = 1.0 / settings.ui_scale
	control.anchor_left = float(authored[0]) * factor
	control.anchor_top = float(authored[1]) * factor
	control.anchor_right = float(authored[2]) * factor
	control.anchor_bottom = float(authored[3]) * factor


func _interaction_notice(text: String) -> void:
	notify(text)


func _return_to_menu() -> void:
	close_system_menu()
	return_to_menu_requested.emit()


func _quit() -> void:
	close_system_menu()
	if hosted:
		quit_requested.emit()
	else:
		get_tree().quit()
