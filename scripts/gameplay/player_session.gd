class_name PlayerSession
extends Node
## Small input/modal handoff; inventory data and world simulation remain independent.

var actor: Astronaut
var modes: GameplayModeCoordinator
var detector: InteractionDetector
var window: InventoryWindow
var _inventory_key_down: bool = false
var transition_blocked: bool = false
var inspection_blocked: bool = false


func configure(player: Astronaut, coordinator: GameplayModeCoordinator, interaction: InteractionDetector, inventory_window: InventoryWindow) -> void:
	actor = player
	modes = coordinator
	detector = interaction
	window = inventory_window
	window.close_requested.connect(func() -> void: set_inventory_open(false))
	modes.mode_changed.connect(_mode_changed)
	apply_permissions()


func set_inventory_open(value: bool) -> bool:
	if value == window.visible:
		return false
	if transition_blocked or inspection_blocked:
		return false
	if value and (not is_instance_valid(actor) or not is_instance_valid(detector) or not modes.is_player_mode() or get_viewport().gui_get_focus_owner() != null):
		return false
	modes.modal_input_blocked = value or transition_blocked or inspection_blocked
	window.set_open(value)
	apply_permissions()
	return true


func apply_permissions() -> void:
	var enabled: bool = modes.is_player_mode() and not window.visible and not transition_blocked and not inspection_blocked
	if is_instance_valid(actor) and actor.control_enabled != enabled:
		actor.set_control_enabled(enabled)
	if is_instance_valid(detector):
		detector.set_enabled(enabled)


func set_transition_blocked(value: bool) -> void:
	transition_blocked = value
	modes.modal_input_blocked = value or window.visible or inspection_blocked
	apply_permissions()


func set_inspection_blocked(value: bool) -> void:
	inspection_blocked = value
	modes.modal_input_blocked = value or window.visible or transition_blocked
	apply_permissions()


func _mode_changed(_mode: GameplayModeCoordinator.Mode) -> void:
	apply_permissions()


func _input(event: InputEvent) -> void:
	if not is_instance_valid(window):
		return
	if event.is_action_released("inventory_toggle"):
		_inventory_key_down = false
	if event.is_action_pressed("inventory_toggle") and not event.is_echo() and not _inventory_key_down:
		_inventory_key_down = true
		if window.visible or get_viewport().gui_get_focus_owner() == null:
			set_inventory_open(not window.visible)
			get_viewport().set_input_as_handled()
	elif window.visible and event.is_action_pressed("game_pause") and not event.is_echo():
		set_inventory_open(false)
		get_viewport().set_input_as_handled()
	elif window.visible and event.is_action("mode_switch"):
		get_viewport().set_input_as_handled()
