class_name GameHUD
extends Control
## Passive screen-space presentation. Systems own mode, inventory and future status data.

var modes: GameplayModeCoordinator
var management: BaseManagementCameraRig
var inventory_window: InventoryWindow
@onready var mode_label: Label = $TopBar/Content/Mode/ActiveMode
@onready var controls_hint: Label = $TopBar/Content/Mode/Controls
@onready var inventory_hint: Label = $BottomBar/Content/InventoryHint
@onready var mode_hint: Label = $BottomBar/Content/ModeHint
@onready var development_badge: Label = $TopBar/Content/Identity/DevelopmentBadge
@onready var notifications: NotificationArea = $Notifications


func _ready() -> void:
	_make_pass_through(self)


func configure(coordinator: GameplayModeCoordinator, camera: BaseManagementCameraRig, window: InventoryWindow, show_development: bool) -> void:
	modes = coordinator
	management = camera
	inventory_window = window
	development_badge.visible = show_development
	modes.mode_changed.connect(_mode_changed)
	management.zoom_changed.connect(_zoom_changed)
	inventory_window.visibility_changed.connect(refresh_bindings)
	refresh_bindings()


func refresh_bindings() -> void:
	if not is_instance_valid(modes) or not is_instance_valid(inventory_window):
		return
	var player: bool = modes.is_player_mode()
	var modal: bool = inventory_window.visible
	mode_label.text = "PLAYER MODE" if player else "BASE MANAGEMENT MODE"
	controls_hint.text = ("Inventory open" if modal else "WASD / arrows: walk") if player else "WASD / arrows: pan  |  Wheel: zoom %dx" % management.zoom_level
	inventory_hint.text = "[%s] %s" % [InputHint.label(&"inventory_toggle"), "Close inventory" if modal else "Inventory"]
	if not player:
		inventory_hint.text += "  /  Player Mode only"
	mode_hint.text = ("Close inventory to change mode" if modal else "[%s] %s" % [InputHint.label(&"mode_switch"), "Base management" if player else "Player Mode"])


func _mode_changed(_mode: GameplayModeCoordinator.Mode) -> void:
	refresh_bindings()


func _zoom_changed(_zoom: int) -> void:
	refresh_bindings()


func _make_pass_through(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.focus_mode = Control.FOCUS_NONE
	for child: Node in node.get_children():
		_make_pass_through(child)
