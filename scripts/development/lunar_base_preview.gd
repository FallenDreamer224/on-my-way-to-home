extends Node
## Fresh existing game session with isolated finished art placement and existing room services.
const MAIN: PackedScene=preload("res://scenes/main.tscn")
var main: Node
var assembly: LunarBaseAssembly
var ground: TerrainLayer
var original_cells: Dictionary[Vector2i,int]
var director: HabitatDirector
var caption: Label
var occlusion_guard: ExteriorOcclusionGuard

func _ready() -> void:
	main=MAIN.instantiate()
	main.integrate_lunar_base=false
	add_child(main)
	ground=main.get_node("World/Terrain/Ground")
	original_cells=ground.terrain_cells.duplicate()
	main.get_node("World/SiteLayout").hide()
	main.get_node("World/Entities/Props").hide()
	assembly=load("res://scenes/exterior/base_g2/lunar_base_assembly.tscn").instantiate()
	main.get_node("World/Entities/Buildings").add_child(assembly)
	var region:=ExteriorArtRegion.new()
	region.origin=ground.region.origin
	region.size=ground.region.size
	region.cells=original_cells.duplicate()
	region.blocked=assembly.occupied.duplicate()
	ground.region=region
	ground.rebuild()
	main.astronaut.global_position=IsometricGrid.tile_to_world(LunarBaseAssembly.cell(assembly.layout.spawn),ground)
	main.chiwis.global_position=IsometricGrid.tile_to_world(LunarBaseAssembly.cell(assembly.layout.companion_spawn),ground)
	main.astronaut.configure_terrain(ground)
	main.chiwis.configure_terrain(ground)
	main.chiwis.set_follow_target(main.astronaut)
	main.get_node("Systems/EvaSafety").suspended=true
	director=main.get_node("Systems/HabitatDirector")
	director.exterior_entry.position=IsometricGrid.tile_to_world(assembly.entry_cell(),ground)
	assembly.bind_airlock(director)
	occlusion_guard=ExteriorOcclusionGuard.new()
	add_child(occlusion_guard)
	occlusion_guard.configure(assembly,main.astronaut,main.chiwis)
	var library: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://resources/interiors/room_library.json"))
	var daily: DailyLife=main.get_node("Systems/Utilities/DailyLife")
	for entry: Dictionary in library.rooms:
		var room: InteriorArtRoom=(load("res://"+String(entry.scene_path)) as PackedScene).instantiate()
		director.definitions[StringName(entry.id)]=entry.layout
		room.setup(entry.layout,director.states[StringName(entry.id)],director.request_action)
		room.hide()
		room.process_mode=Node.PROCESS_MODE_DISABLED
		main.get_node("HabitatInteriors").add_child(room)
		director.rooms[StringName(entry.id)]=room
		room.bind_services(daily,director)
	var overlay:=CanvasLayer.new()
	overlay.layer=30
	add_child(overlay)
	caption=Label.new()
	UiKit.style_world_label(caption)
	caption.position=Vector2(16,12)
	caption.text="ASSEMBLED LUNAR OUTPOST / NATIVE 1X\nF1 entrance | F2 core | F3 greenhouse | F4 power | F5 lander\nE: existing airlock | Tab: existing camera modes | WASD/I unchanged"
	caption.mouse_filter=Control.MOUSE_FILTER_IGNORE
	caption.hide()
	overlay.add_child(caption)
	main.game_ui.notify("Base art preview: F1-F5 inspect zones. E enters through the existing interlocked airlock. Tab and I retain normal controls.",8)
	main.camera_rig.refresh_follow()

func focus(cell: Vector2i) -> bool:
	if director.location!=&"outside" or main.gameplay_modes.modal_input_blocked: return false
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
	main.management_camera.zoom_level=1
	main.management_camera.set_pan_position(IsometricGrid.tile_to_world(cell,ground))
	return true
func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	var cells: Array[Vector2i]=[assembly.entry_cell(),Vector2i(0,2),Vector2i(9,-6),Vector2i(-17,5),Vector2i(-17,15)]
	var index: int=event.keycode-KEY_F1
	if index>=0 and index<cells.size() and focus(cells[index]): get_viewport().set_input_as_handled()
