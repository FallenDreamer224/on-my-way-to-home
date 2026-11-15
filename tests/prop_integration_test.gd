extends SceneTree
## Actual pickup composition and rendered native-size prop gallery, without gameplay additions.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
const PICKUP: PackedScene = preload("res://scenes/world/world_pickup.tscn")
const GALLERY: PackedScene = preload("res://scenes/development/prop_gallery.tscn")
const SAMPLE: ItemDefinition = preload("res://resources/items/lunar_sample.tres")
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/props_pack_b.json"))
	var gallery: Node2D = GALLERY.instantiate()
	root.add_child(gallery)
	await process_frame
	_check(gallery.get_node("Props").get_child_count() == 10, "All ten props have gallery instances")
	for record: Dictionary in manifest["assets"]:
		var prop_name: String = str(record["asset_id"]).trim_prefix("props_pack_b_")
		var prop: WorldProp = gallery.get_node("Props/" + prop_name)
		var anchor: Array = record["ground_anchor_px_from_image_top_left"]
		_check(prop.appearance.is_valid() and prop.sprite.visible, "Visible prop " + prop_name)
		_check(prop.sprite.texture.resource_path == "res://" + str(record["runtime_files"][0]), "Correct asset " + prop_name)
		_check(prop.sprite.texture.get_size() == Vector2(64, 64), "Native full canvas " + prop_name)
		_check(prop.appearance.ground_anchor == Vector2i(int(anchor[0]), int(anchor[1])), "Manifest anchor " + prop_name)
		_check(prop.sprite.to_global(prop.sprite.offset + Vector2(prop.appearance.ground_anchor)).is_equal_approx(prop.global_position), "Ground alignment " + prop_name)
		_check(prop.scale == Vector2.ONE and prop.sprite.scale == Vector2.ONE and not prop.sprite.centered, "No rescaling or centering drift " + prop_name)
		_check(prop.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and prop.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "Sharp nonrepeating art " + prop_name)
		_check(prop.get_child_count() == 1 and prop.get_child(0) is Sprite2D, "Presentation-only nonblocking prop " + prop_name)
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("phase_0_8A_prop_gallery")
		(gallery.get_node("Camera2D") as Camera2D).zoom = Vector2.ONE
		await _capture("phase_0_8A_prop_gallery_1x")
	gallery.queue_free()
	await process_frame
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	await _settle()
	var props: Node2D = main.get_node("World/Entities/Props")
	var actor: Astronaut = main.get_node("World/Entities/Players/Astronaut")
	var detector: InteractionDetector = actor.get_node("InteractionDetector")
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var original_cells: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	var modes: GameplayModeCoordinator = main.get_node("Systems/GameplayModes")
	var prompt: InteractionPrompt = main.get_node("UI/InteractionPrompt")
	var locations: Dictionary[String, Vector2] = {"LunarSampleA": Vector2(32, 16), "LunarSampleB": Vector2(64, 32), "MetalScrap": Vector2(-32, 48), "SupplyPack": Vector2(-64, -32)}
	_check(props.get_child_count() == 4, "Production layout retains four pickups")
	for child: Node in props.get_children():
		var pickup: WorldPickup = child as WorldPickup
		_check(pickup.visual.sprite.visible and pickup.visual.appearance == WorldPickup.ITEM_APPEARANCES[pickup.item.item_id], "Item resolves correct finished world art")
		_check(pickup.position == locations[str(pickup.name)], "Authored ground position unchanged")
		_check(pickup.interaction.position == Vector2.ZERO and pickup.visual.position == Vector2.ZERO, "Visual offset does not move interaction root")
		_check(pickup.interaction.collision_layer == 8 and pickup.interaction.collision_mask == 0, "Nonblocking detection layer unchanged")
	_check(detector.target == props.get_node("LunarSampleA/Interaction"), "Nearest target unchanged with large sprites")
	_check(prompt.prompt.text == "[E] Collect Lunar Sample", "Prompt still driven by item definition")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("phase_0_8A_player")
	modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
	await _settle()
	_check(modes.current_mode == GameplayModeCoordinator.Mode.BASE_MANAGEMENT, "Management mode still available")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("phase_0_8A_management")
	modes.request_mode(GameplayModeCoordinator.Mode.PLAYER)
	await _settle()
	# Finished visuals survive partial acceptance and capacity rejection without changes.
	var inventory := RuntimeInventory.new()
	inventory.slot_capacity = 1
	inventory.definitions.assign([SAMPLE])
	root.add_child(inventory)
	inventory.add_items(SAMPLE.item_id, 8)
	var partial: WorldPickup = PICKUP.instantiate()
	partial.item = SAMPLE
	partial.quantity = 5
	partial.position = Vector2(32, -16)
	partial.pickup_id = "art_partial_fixture"
	props.add_child(partial)
	await _settle()
	var original_texture: Texture2D = partial.visual.sprite.texture
	_check(partial.collect(inventory) == 2 and partial.quantity == 3, "Partial acceptance preserves exact world remainder")
	_check(not partial.is_queued_for_deletion() and partial.visual.sprite.visible and partial.visual.sprite.texture == original_texture, "Partial sprite remains visible and unchanged")
	_check(partial.collect(inventory) == 0 and partial.quantity == 3 and partial.visual.sprite.visible, "Full inventory leaves sprite and remainder intact")
	_check(inventory.get_quantity(SAMPLE.item_id) == 10, "Capacity still caps inventory stack")
	inventory.remove_items(SAMPLE.item_id, 3)
	_check(partial.collect(inventory) == 3 and partial.is_queued_for_deletion(), "Pickup removed only on final accepted remainder")
	await process_frame
	_check(not is_instance_valid(partial), "Finished sprite freed with fully collected pickup")
	_check(inventory.get_quantity(SAMPLE.item_id) == 10 and ground.terrain_cells == original_cells, "Conservation and terrain logic preserved")
	inventory.queue_free()
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d prop integration checks" % _checks)
		quit(0)
	else:
		for message: String in _failures:
			printerr("FAIL: " + message)
		quit(1)


func _settle() -> void:
	for index: int in 3:
		await physics_frame
	await process_frame


func _capture(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png("res://tests/output/" + filename + ".png") == OK, "Capture " + filename)


func _check(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures.append(label)
