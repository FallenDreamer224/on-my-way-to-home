extends SceneTree
## Full native outpost art, original terrain data, shared actor navigation and real airlock flow.
var checks: int=0
var failures: PackedStringArray=[]
var preview: Node
var main: Node
var capture: bool=false
const OUTPUT: String="res://tests/output/phase_0_8g2_base/captures/"
func _initialize() -> void: run.call_deferred()
func check(ok: bool, text: String) -> void:
	checks+=1
	if not ok: failures.append(text)
func settle() -> void:
	await physics_frame
	await process_frame
func release() -> void:
	for action: StringName in Astronaut.MOVEMENT_ACTIONS: Input.action_release(action)
func walk(goal: Vector2) -> void:
	var actor: Astronaut=main.astronaut
	var planner:=TerrainRoutePlanner.new(preview.ground,actor.footprint_half_extent)
	var route:=planner.route(actor.global_position,goal)
	check(not route.is_empty(),"Existing planner finds outdoor route")
	for waypoint: Vector2 in route:
		var count: int=0
		while actor.global_position.distance_to(waypoint)>2 and count<320:
			var d:=actor.global_position.direction_to(waypoint)
			Input.action_press(&"player_move_right",maxf(d.x,0))
			Input.action_press(&"player_move_left",maxf(-d.x,0))
			Input.action_press(&"player_move_down",maxf(d.y,0))
			Input.action_press(&"player_move_up",maxf(-d.y,0))
			await physics_frame
			count+=1
		check(actor.global_position.distance_to(waypoint)<3,"Real astronaut walks around assembled hulls")
		release()
	await physics_frame
func screenshot(name: String) -> void:
	if not capture:return
	main.game_ui.hide()
	preview.caption.show()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var im:=root.get_texture().get_image()
	check(im.get_size()==Vector2i(960,540),"Native close-up resolution")
	check(im.save_png(OUTPUT+name+".png")==OK,"Saved "+name)
	main.game_ui.show()
	preview.caption.hide()
func composite(terrain: bool, file: String) -> void:
	if not capture:return
	var stage: Node2D=main.get_node("World")
	var ground: Node2D=main.get_node("World/Terrain")
	var players: Node2D=main.get_node("World/Entities/Players")
	var dogs: Node2D=main.get_node("World/Entities/NPCs")
	var saved_player: Vector2=main.astronaut.global_position
	var saved_dog: Vector2=main.chiwis.global_position
	main.astronaut.global_position=IsometricGrid.tile_to_world(Vector2i(-17,10),preview.ground)
	main.chiwis.global_position=IsometricGrid.tile_to_world(Vector2i(-18,10),preview.ground)
	preview.occlusion_guard.set_physics_process(false)
	var saved_depth: Dictionary[int,int]={}
	for hull: Node2D in preview.assembly.hulls.values():
		saved_depth[hull.get_instance_id()]=hull.z_index
		hull.z_index=0
		hull.modulate.a=1
	ground.visible=terrain
	players.visible=terrain
	dogs.visible=terrain
	preview.director.exterior_entry.hide()
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(2688,1536)
	viewport.transparent_bg=true
	viewport.world_2d=root.world_2d
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	var camera:=Camera2D.new()
	camera.position=Vector2(0,-32)
	camera.zoom=Vector2.ONE
	viewport.add_child(camera)
	camera.make_current()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var im:=viewport.get_texture().get_image()
	check(im.get_size()==viewport.size,"Native full composition has no resampling")
	# Regression captures never overwrite delivered art. Explicit authoring is a separate command.
	var target: String=file if "--write-compositions" in OS.get_cmdline_user_args() else OUTPUT+file.get_file()
	check(im.save_png(target)==OK,"Full outpost image saved")
	check(im.save_png(OUTPUT+("full_outpost" if terrain else "transparent_outpost")+".png")==OK,"Full capture evidence saved")
	viewport.queue_free()
	ground.show();players.show();dogs.show();preview.director.exterior_entry.show()
	main.astronaut.global_position=saved_player;main.chiwis.global_position=saved_dog
	for hull: Node2D in preview.assembly.hulls.values():hull.z_index=saved_depth[hull.get_instance_id()]
	preview.occlusion_guard.set_physics_process(true)
	await settle()
	check(stage.visible,"Original exterior retained after composition")
func use_action(id: StringName) -> void:
	var director: HabitatDirector=preview.director
	var action: HabitatAction=director.exterior_entry if director.location==&"outside" else director.rooms[director.location].actions[id]
	main.astronaut.set_physics_process(false)
	main.chiwis.set_physics_process(false)
	main.astronaut.global_position=action.global_position
	var floor_layer:=director.active_terrain()
	var at:=IsometricGrid.world_to_tile(action.global_position,floor_layer)
	for neighbor: Vector2i in IsometricGrid.neighbors(at):
		var point:=IsometricGrid.tile_to_world(neighbor,floor_layer)
		if main.chiwis.planner.walkability.is_position_walkable(point,main.chiwis.footprint_half_extent):main.chiwis.global_position=point;break
	await settle()
	check(director.request_action(action),"Existing validated interaction accepts "+String(id))
	var count: int=0
	while director.busy and count<120:await physics_frame;count+=1
	check(not director.busy and not (director.airlock.inner_open and director.airlock.outer_open),"Real interlock transaction completes safely")
func run() -> void:
	capture="--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name()!="headless"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/buildings/base_g2/compositions/"))
	var structure: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/base_structure.json"))
	for part: Dictionary in structure.assets:
		var path: String="res://"+String(part.runtime_files[0])
		var texture: Texture2D=load(path)
		var source:=Image.new()
		check(source.load_png_from_buffer(FileAccess.get_file_as_bytes(path))==OK,"Structural PNG decodes "+String(part.asset_id))
		source.convert(Image.FORMAT_RGBA8)
		var actual: Image=texture.get_image();actual.convert(Image.FORMAT_RGBA8)
		check(actual.get_data()==source.get_data(),"Structural RGBA survives Godot import "+String(part.asset_id))
	var library: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/lunar_base_art_library.json"))
	for record: Dictionary in library.assets:
		var spec: ExteriorAssetDefinition=load("res://"+String(record.resource_path))
		check(spec.validation_errors().is_empty(),"Valid exterior metadata "+String(record.asset_id))
		check(spec.texture.get_size()==Vector2(spec.native_size),"Native exterior canvas")
		var raw:=Image.new()
		raw.load_png_from_buffer(FileAccess.get_file_as_bytes("res://"+String(record.runtime_files[0])))
		raw.convert(Image.FORMAT_RGBA8)
		var imported:=spec.texture.get_image();imported.convert(Image.FORMAT_RGBA8)
		check(raw.get_data()==imported.get_data(),"Exact imported exterior pixels")
		var obj: Node2D=(load("res://"+String(record.scene_path)) as PackedScene).instantiate()
		check(obj.scale==Vector2.ONE and obj.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"Native unscaled prefab")
		if record.category=="modular_hull_composite":check(obj.get_node("Roof")!=null and obj.get_node("Body")!=null and obj.y_sort_enabled,"Split roof/wall sorting and real hull collision")
		obj.free()
	for mask: int in range(1,16):
		var im:=Image.new();im.load_png_from_buffer(FileAccess.get_file_as_bytes("res://assets/environment/interiors_g2/structure/cable_"+str(mask)+".png"))
		var tips: Array[Vector2i]=[Vector2i(16,8),Vector2i(48,8),Vector2i(48,24),Vector2i(16,24)]
		for i: int in 4:
			if mask&(1<<i):check(im.get_pixelv(tips[i]+Vector2i(2,2)).a==1,"Cable endpoint matches grid joint")
	preview=load("res://scenes/development/lunar_base_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	main=preview.main
	var assembly: LunarBaseAssembly=preview.assembly
	var ground: TerrainLayer=preview.ground
	check(ground.terrain_cells==preview.original_cells and ground.terrain_cells.size()==1600,"Copied 40x40 terrain layout and kinds unchanged")
	check(assembly.hulls.size()==9 and assembly.layout.routes.size()==8,"Nine connected native envelopes")
	for module: Dictionary in assembly.layout.modules:
		var room: InteriorArtRoom=preview.director.rooms[StringName(module.id)]
		check(room.region.size==LunarBaseAssembly.cell(module.size),"Interior fits exact native envelope "+String(module.id))
		var origin:=LunarBaseAssembly.cell(module.origin)
		var size:=LunarBaseAssembly.cell(module.size)
		for y: int in size.y:
			for x: int in size.x:
				var at:=origin+Vector2i(x,y)
				check(not ground.is_cell_walkable(at),"Hull occupancy reaches actual room dimensions")
	for route: Dictionary in assembly.layout.routes:
		check(not route.cells.is_empty(),"Pressure passage has actual cells")
		if route.cells.size()>=3:
			var vertical: bool=route.cells[0][0]==route.cells[1][0]
			var expected: String="pressure_passage_sw" if vertical else "pressure_passage"
			var straight_found: bool=false
			for part: Node2D in assembly.equipment.values():
				if part.get_meta("asset_id","")!=expected:continue
				for point: Array in route.cells:
					if part.get_meta("placement_cell")==LunarBaseAssembly.cell(point):straight_found=true
			check(straight_found,"Long pressure link uses a native straight section even when its route is reversed")
		for i: int in range(1,route.cells.size()):
			var a:=LunarBaseAssembly.cell(route.cells[i-1]);var b:=LunarBaseAssembly.cell(route.cells[i])
			check(absi(a.x-b.x)+absi(a.y-b.y)==1,"Passage parts join on shared grid edges")
	var actor: Astronaut=main.astronaut
	var dog: Chiwis=main.chiwis
	var inventory: RuntimeInventory=actor.get_node("Inventory")
	var identity: Array[int]=[actor.get_instance_id(),dog.get_instance_id(),inventory.get_instance_id()]
	check(actor.walkability.is_position_walkable(actor.global_position,actor.footprint_half_extent),"Safe exterior spawn")
	check(dog.planner.walkability.is_position_walkable(dog.global_position,dog.footprint_half_extent),"Safe exterior companion spawn")
	var entry:=IsometricGrid.tile_to_world(assembly.entry_cell(),ground)
	check(ground.is_cell_walkable(assembly.entry_cell()),"Usable visible airlock approach")
	await walk(IsometricGrid.tile_to_world(Vector2i(-18,-2),ground))
	await walk(entry)
	for i: int in 90:await physics_frame
	check(dog.global_position.distance_to(actor.global_position)<110,"Original companion follows around full base")
	check(dog.planner.walkability.is_position_walkable(dog.global_position,dog.footprint_half_extent),"Companion remains outside collision envelopes")
	check(preview.occlusion_guard.occluded_actor_count>0,"Entrance cutaway reveals actors otherwise hidden by large shells")
	var cutaway: bool=false
	for hull: Node2D in assembly.hulls.values():
		if hull.modulate.a<1:cutaway=true
	check(cutaway,"Occluded entrance has an actual visible cutaway")
	main.astronaut.set_physics_process(false);main.chiwis.set_physics_process(false)
	for view: Array in [["airlock",assembly.entry_cell()],["core",Vector2i(0,2)],["greenhouse_exterior",Vector2i(9,-6)],["power_utilities",Vector2i(-17,5)],["lander",Vector2i(-17,15)],["pressure_links",Vector2i(-10,-3)]]:
		preview.focus(view[1]);await settle();await screenshot(String(view[0]))
	preview.focus(assembly.entry_cell());await settle()
	check(preview.director.airlock.open_outer(),"Existing airlock owns exterior open state")
	preview.director.airlock_changed.emit()
	await screenshot("hatch_open")
	preview.director.airlock.outer_open=false
	preview.director.airlock_changed.emit()
	await screenshot("hatch_closed")
	await composite(false,"res://assets/buildings/base_g2/compositions/lunar_base_complete.png")
	await composite(true,"res://assets/buildings/base_g2/compositions/lunar_base_showcase.png")
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.PLAYER)
	inventory.add_items(&"lunar_sample",3)
	await use_action(&"enter")
	check(preview.director.location==&"crew_airlock","Unified outpost entrance uses existing chamber transition")
	await use_action(&"seal_outer")
	await use_action(&"inspection")
	preview.director.cycle_seconds=.02
	await use_action(&"cycle")
	await use_action(&"inner")
	check(preview.director.location==&"equipment_lock","Pressure inspection/matching enters prepared interior")
	check([actor.get_instance_id(),dog.get_instance_id(),inventory.get_instance_id()]==identity and inventory.get_quantity(&"lunar_sample")==3,"One actor/dog/inventory survives exterior/interior transition")
	release()
	preview.queue_free();await settle()
	if failures.is_empty():print("PASS: %d full lunar base art/navigation/transition checks"%checks)
	else:
		for failure: String in failures:printerr("FAIL: "+failure)
	quit(0 if failures.is_empty() else 1)
