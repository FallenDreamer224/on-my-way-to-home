class_name GameHUD
extends Control
## Passive screen-space presentation: location, mode, telemetry, objectives, notices,
## companion dialogue and control hints. Systems own every value shown here; the HUD only
## mirrors their signals and never takes pointer input or keyboard focus.

const NOTIFICATIONS: PackedScene = preload("res://scenes/ui/notification_area.tscn")
const EDGE: int = 8
const COLUMN_WIDTH: int = 252
const DOCK_WIDTH: int = 304

var modes: GameplayModeCoordinator
var management: BaseManagementCameraRig
var inventory_window: InventoryWindow
var director: HabitatDirector
var mode_label: Label
var controls_hint: Label
var development_badge: Label
var location_title: Label
var location_detail: Label
var inventory_hint: KeyHint
var mode_hint: KeyHint
var details_hint: KeyHint
var menu_hint: KeyHint
var notifications: NotificationArea
var status: HudStatusPanel
var objectives: ObjectivePanel
var dialogue: DialogueWindow
var _left: VBoxContainer


func _init() -> void:
	_left = UiKit.vbox(4)
	_left.name = "LeftColumn"
	_left.anchor_right = 1.0
	_left.offset_left = EDGE
	_left.offset_top = EDGE
	_left.offset_right = -(COLUMN_WIDTH + EDGE * 3)
	add_child(_left)
	# Chips wrap onto a second row when a larger UI scale leaves less width.
	var top := HFlowContainer.new()
	top.name = "TopBar"
	top.add_theme_constant_override(&"h_separation", 4)
	top.add_theme_constant_override(&"v_separation", 4)
	_left.add_child(top)
	var location_chip: PanelContainer = UiKit.panel(&"HudPanel")
	location_chip.name = "Location"
	top.add_child(location_chip)
	var location_row := UiKit.hbox(6)
	location_chip.add_child(location_row)
	location_row.add_child(UiKit.compact_icon(&"location", 20))
	var location_column := UiKit.vbox(0)
	location_row.add_child(location_column)
	location_title = UiKit.label("LUNAR SURFACE", &"SectionLabel")
	location_title.name = "Title"
	location_title.custom_minimum_size.x = 150
	location_title.clip_text = true
	location_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	location_column.add_child(location_title)
	location_detail = UiKit.label("Tutorial site", &"CaptionLabel")
	location_detail.name = "Detail"
	location_column.add_child(location_detail)
	var mode_chip: PanelContainer = UiKit.panel(&"HudPanel")
	mode_chip.name = "Content"
	top.add_child(mode_chip)
	var mode_column := UiKit.vbox(0)
	mode_column.name = "Mode"
	mode_chip.add_child(mode_column)
	mode_label = UiKit.label("PLAYER MODE", &"SectionLabel")
	mode_label.name = "ActiveMode"
	mode_column.add_child(mode_label)
	controls_hint = UiKit.label("", &"CaptionLabel")
	controls_hint.name = "Controls"
	mode_column.add_child(controls_hint)
	status = HudStatusPanel.new()
	status.custom_minimum_size.x = COLUMN_WIDTH
	status.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_left.add_child(status)
	notifications = NOTIFICATIONS.instantiate()
	notifications.custom_minimum_size.x = COLUMN_WIDTH
	notifications.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_left.add_child(notifications)
	objectives = ObjectivePanel.new()
	objectives.anchor_left = 1.0
	objectives.anchor_right = 1.0
	objectives.offset_left = -(COLUMN_WIDTH + EDGE)
	objectives.offset_right = -EDGE
	objectives.offset_top = EDGE
	objectives.offset_bottom = EDGE
	objectives.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	add_child(objectives)
	dialogue = DialogueWindow.new()
	dialogue.anchor_top = 1.0
	dialogue.anchor_bottom = 1.0
	dialogue.offset_left = EDGE
	dialogue.offset_right = EDGE + 330
	dialogue.offset_top = -146
	dialogue.offset_bottom = -36
	add_child(dialogue)
	var bottom: PanelContainer = UiKit.panel(&"HudPanel")
	bottom.name = "BottomBar"
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = EDGE
	bottom.offset_right = -EDGE
	bottom.offset_top = -30
	bottom.offset_bottom = -6
	bottom.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(bottom)
	var hints := UiKit.hbox(14)
	hints.name = "Content"
	bottom.add_child(hints)
	inventory_hint = KeyHint.new(&"inventory_toggle", "Inventory")
	inventory_hint.name = "InventoryHint"
	hints.add_child(inventory_hint)
	mode_hint = KeyHint.new(&"mode_switch", "Base management")
	mode_hint.name = "ModeHint"
	hints.add_child(mode_hint)
	details_hint = KeyHint.new(&"hud_details", "Status")
	details_hint.name = "DetailsHint"
	hints.add_child(details_hint)
	hints.add_child(UiKit.spacer())
	development_badge = UiKit.label("MOON / DEVELOPMENT", &"CaptionLabel")
	development_badge.name = "DevelopmentBadge"
	development_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hints.add_child(development_badge)
	menu_hint = KeyHint.new(&"game_pause", "Menu")
	menu_hint.name = "MenuHint"
	hints.add_child(menu_hint)


func _ready() -> void:
	UiKit.make_passive(self)


func configure(coordinator: GameplayModeCoordinator, camera: BaseManagementCameraRig, window: InventoryWindow, show_development: bool) -> void:
	modes = coordinator
	management = camera
	inventory_window = window
	development_badge.visible = show_development
	modes.mode_changed.connect(_mode_changed)
	management.zoom_changed.connect(_zoom_changed)
	inventory_window.visibility_changed.connect(refresh_bindings)
	refresh_bindings()


## Optional system bindings. Each may be absent in a reduced test composition.
func bind_systems(habitat: HabitatDirector, utilities: UtilityService, safety: EvaSafetyMonitor,
		tracker: ObjectiveTracker, companion: ChiwisDialogue) -> void:
	director = habitat
	if is_instance_valid(director):
		director.location_changed.connect(func(_location: StringName) -> void: _refresh_location())
		director.airlock_changed.connect(_refresh_location)
	status.bind(utilities, safety, director)
	objectives.bind(tracker)
	dialogue.bind(companion)
	_refresh_location()


func refresh_bindings() -> void:
	if not is_instance_valid(modes) or not is_instance_valid(inventory_window):
		return
	var player: bool = modes.is_player_mode()
	var modal: bool = inventory_window.visible
	var movement: String = "%s%s%s%s / arrows" % [InputHint.label(&"player_move_up"), InputHint.label(&"player_move_left"),
		InputHint.label(&"player_move_down"), InputHint.label(&"player_move_right")]
	mode_label.text = "PLAYER MODE" if player else "BASE MANAGEMENT MODE"
	controls_hint.text = ("Inventory open" if modal else movement + ": walk") if player else movement + ": pan  |  Wheel: zoom %dx" % management.zoom_level
	inventory_hint.caption = ("Close inventory" if modal else "Inventory") + ("" if player else "  /  Player Mode only")
	mode_hint.caption = "Close inventory to change mode" if modal else ("Base management" if player else "Player Mode")
	details_hint.caption = "Hide status" if status.expanded else "Status"
	for hint: KeyHint in [inventory_hint, mode_hint, details_hint, menu_hint]:
		hint.refresh()
	dialogue.refresh_bindings()
	# The management dashboard occupies the right column and carries its own mission tab.
	objectives.visible = player
	_left.offset_right = -((COLUMN_WIDTH if player else DOCK_WIDTH) + EDGE * 3)


func set_details_expanded(value: bool) -> void:
	status.set_expanded(value)
	details_hint.caption = "Hide status" if status.expanded else "Status"


func toggle_details() -> void:
	set_details_expanded(not status.expanded)


func _refresh_location() -> void:
	if not is_instance_valid(director) or director.location == &"outside":
		location_title.text = "LUNAR SURFACE"
		location_detail.text = "Tutorial site / EVA"
		return
	location_title.text = director.location_title().to_upper()
	location_detail.text = director.airlock_summary() if director.location == &"crew_airlock" else "Pressurized habitat"


func _mode_changed(_mode: GameplayModeCoordinator.Mode) -> void:
	refresh_bindings()


func _zoom_changed(_zoom: int) -> void:
	refresh_bindings()
