extends Node
## Isolated development session. Existing director, actors, cameras and services are reused.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
var main: Node
var director: HabitatDirector
var daily: DailyLife
var library: Dictionary
var caption: Label
var ready_for_inspection: bool = false

func _ready() -> void:
	main = MAIN.instantiate()
	add_child(main)
	director = main.get_node("Systems/HabitatDirector")
	daily = main.get_node("Systems/Utilities/DailyLife")
	library = JSON.parse_string(FileAccess.get_file_as_string("res://resources/interiors/room_library.json"))
	for entry: Dictionary in library.rooms:
		var room: InteriorArtRoom = (load("res://" + String(entry.scene_path)) as PackedScene).instantiate()
		director.definitions[StringName(entry.id)] = entry.layout
		room.setup(entry.layout, director.states[StringName(entry.id)], director.request_action)
		room.hide()
		room.process_mode = Node.PROCESS_MODE_DISABLED
		main.get_node("HabitatInteriors").add_child(room)
		director.rooms[StringName(entry.id)] = room
		room.bind_services(daily, director)
	var overlay := CanvasLayer.new()
	overlay.layer = 30
	add_child(overlay)
	caption = Label.new()
	UiKit.style_world_label(caption)
	caption.position = Vector2(16, 12)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(caption)
	director.location_changed.connect(func(_location: StringName) -> void: refresh_caption())
	ready_for_inspection = true
	select_room(&"crew_airlock")
	main.game_ui.notify("Interior art preview: F1-F9 select rooms. Existing WASD, E, Tab and I controls remain available.", 8)

func refresh_caption(category: String = "") -> void:
	caption.text = "INTERIOR LIBRARY / " + (category if not category.is_empty() else director.location_title()).to_upper()
	caption.text += "\nF1-F9: rooms  |  WASD: walk  |  E: existing actions  |  Tab/I: existing mode/inventory"
	caption.text += "\nNative 1x / 64x32 grid / isolated session / final world assembly deferred"
	caption.visible = not main.game_ui.visible

func select_room(id: StringName) -> bool:
	if not ready_for_inspection or director.busy or main.gameplay_modes.modal_input_blocked or main.player_session.transition_blocked: return false
	if not director.rooms.has(id): return false
	if director.location != id: director._switch_space(id)
	main.astronaut.set_control_enabled(main.gameplay_modes.is_player_mode())
	main.chiwis.set_follow_enabled(main.gameplay_modes.is_player_mode())
	refresh_caption()
	return true

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	var index: int = event.keycode - KEY_F1
	if index >= 0 and index < library.rooms.size():
		if select_room(StringName(library.rooms[index].id)): get_viewport().set_input_as_handled()
