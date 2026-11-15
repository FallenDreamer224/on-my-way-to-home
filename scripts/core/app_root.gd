class_name AppRoot
extends Node
## Application flow: title screen, one gameplay session at a time, and the way back.
## Sessions are built through GameEntry.new_game(); nothing is saved to or loaded from disk.

signal session_started(session: Node)
signal menu_shown(menu: MainMenu)

const MENU_SCENE: PackedScene = preload("res://scenes/menu/main_menu.tscn")
const FADE_SECONDS: float = 0.3

var settings: AppSettings
var menu: MainMenu
var session: Node
var fader: ColorRect
var busy: bool = false


func _ready() -> void:
	# The root keeps running while a session is paused by its mission menu.
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = AppSettings.shared()
	settings.apply_display(get_window())
	var overlay := CanvasLayer.new()
	overlay.name = "Transition"
	overlay.layer = 100
	add_child(overlay)
	fader = ColorRect.new()
	fader.name = "Fader"
	fader.color = Color.BLACK
	fader.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(fader)
	_show_menu()
	_fade(0.0)


## True only when a compatible saved session exists. Saving is not implemented.
func has_compatible_save() -> bool:
	return false


func start_new_game() -> bool:
	if busy or is_instance_valid(session):
		return false
	busy = true
	await _fade(1.0)
	_free_menu()
	session = GameEntry.new_game()
	if session == null:
		busy = false
		_show_menu()
		await _fade(0.0)
		return false
	# Only the session pauses; the root and its transition overlay keep processing.
	session.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(session)
	var ui: GameUI = session.get_node("UI")
	ui.hosted = true
	ui.return_to_menu_requested.connect(return_to_menu)
	ui.quit_requested.connect(quit_application)
	session_started.emit(session)
	await _fade(0.0)
	busy = false
	return true


func return_to_menu() -> bool:
	if busy or not is_instance_valid(session):
		return false
	busy = true
	await _fade(1.0)
	get_tree().paused = false
	session.queue_free()
	session = null
	await get_tree().process_frame
	_show_menu()
	await _fade(0.0)
	busy = false
	return true


func quit_application() -> void:
	get_tree().paused = false
	get_tree().quit()


func _show_menu() -> void:
	menu = MENU_SCENE.instantiate()
	add_child(menu)
	move_child(menu, 0)
	menu.save_available = has_compatible_save()
	menu.new_game_requested.connect(start_new_game)
	menu.quit_requested.connect(quit_application)
	menu_shown.emit(menu)


func _free_menu() -> void:
	if is_instance_valid(menu):
		menu.queue_free()
	menu = null


func _fade(target: float) -> void:
	fader.mouse_filter = Control.MOUSE_FILTER_STOP if target > 0.0 else Control.MOUSE_FILTER_IGNORE
	if UiMotion.reduced or not is_inside_tree():
		fader.modulate.a = target
		return
	var tween: Tween = fader.create_tween()
	tween.tween_property(fader, "modulate:a", target, FADE_SECONDS)
	await tween.finished
