extends SceneTree
## Real Area2D broadphase and input events, independent from any physical keyboard session.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
const PICKUP: PackedScene = preload("res://scenes/world/world_pickup.tscn")
const SAMPLE: ItemDefinition = preload("res://resources/items/lunar_sample.tres")
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	var actor: Astronaut = main.get_node("World/Entities/Players/Astronaut")
	var dog: Chiwis = main.get_node("World/Entities/NPCs/Chiwis")
	var inventory: RuntimeInventory = actor.get_node("Inventory")
	var detector: InteractionDetector = actor.get_node("InteractionDetector")
	var modes: GameplayModeCoordinator = main.get_node("Systems/GameplayModes")
	var session: PlayerSession = main.get_node("Systems/PlayerSession")
	var window: InventoryWindow = main.get_node("UI/InventoryWindow")
	var hud: InteractionPrompt = main.get_node("UI/InteractionPrompt")
	var props: Node2D = main.get_node("World/Entities/Props")
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var world_id: int = main.get_node("World").get_instance_id()
	var inventory_id: int = inventory.get_instance_id()
	var saved_terrain: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	await _settle()
	_check(props.get_child_count() == 4 and inventory.slot_count() == 20, "Small pickup fixture and astronaut-owned default inventory")
	for child: Node in props.get_children():
		var pickup: WorldPickup = child as WorldPickup
		_check(pickup != null and actor.walkability.is_position_walkable(pickup.global_position, actor.footprint_half_extent), "Pickup valid full-foot terrain placement")
		_check(pickup.global_position.distance_to(actor.global_position) > 10 and pickup.global_position.distance_to(dog.global_position) > 8, "No initial character/pickup overlap")
		_check(pickup.interaction.collision_layer == 8 and pickup.interaction.collision_mask == 0, "Detection layer separate from actor/obstacle layers")
	_check(detector.target == props.get_node("LunarSampleA/Interaction"), "Native area detection picks nearby sample")
	_check(hud.prompt.text == "[E] Collect Lunar Sample", "Contextual remappable prompt")
	_check((dog.collision_layer & 8) == 0 and not dog.has_node("Interaction"), "Companion never treated as collectible")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("interaction_prompt")
	# Actual input collects once; repeats/held keys cannot collect a new neighboring pickup.
	_send(KEY_E, true)
	await _settle()
	_check(inventory.get_quantity(SAMPLE.item_id) == 6 and props.get_child_count() == 3, "E collects quantity and removes completed pickup")
	var second: WorldPickup = props.get_node("LunarSampleB")
	second.position = Vector2(32, 16)
	await _settle()
	_send(KEY_E, true, true)
	await _settle()
	_check(inventory.get_quantity(SAMPLE.item_id) == 6 and second.quantity == 8, "Held key/echo does not repeat collection")
	_send(KEY_E, false)
	await _press(KEY_E)
	_check(inventory.get_quantity(SAMPLE.item_id) == 14 and inventory.slot_snapshot(0).quantity == 10 and inventory.slot_snapshot(1).quantity == 4, "Fresh press combines multiple pickups into capped stacks")
	_check(props.get_child_count() == 2, "Collected object stays removed")
	_check(window.slot_buttons[0].text == "x10" and window.slot_buttons[1].text == "x4", "UI updates from inventory event while closed")
	# Live broadphase candidates with deterministic ties, changing availability and removal.
	var a: WorldPickup = _spawn(props, Vector2(24, 0), "tie_a")
	var b: WorldPickup = _spawn(props, Vector2(-24, 0), "tie_b")
	await _settle()
	_check(detector.target == a.interaction, "Equal-distance targets use stable lexical identifier")
	b.position = Vector2(-12, 0)
	await _settle()
	_check(detector.target == b.interaction, "Nearest valid target preferred")
	b.interaction.available = false
	await _settle()
	_check(detector.target == a.interaction, "Unavailable target excluded")
	a.queue_free()
	await _settle()
	_check(detector.target == null and not detector.interact(), "Removed targets safely cleared")
	b.queue_free()
	await _settle()
	var distant: WorldPickup = _spawn(props, Vector2(49, 0), "range")
	await _settle()
	_check(detector.target == null and not detector.interact(), "Exact world range excludes broadphase margin overlap")
	detector.interaction_range = 56
	await _settle()
	_check(detector.target == distant.interaction, "Configurable range updates native detection shape")
	detector.interaction_range = 48
	distant.position = Vector2(48, 0)
	await _settle()
	_check(detector.target == distant.interaction, "Range boundary included")
	distant.position = Vector2(200, 0)
	await _settle()
	_check(detector.target == null and hud.prompt.text.is_empty(), "Prompt clears after target leaves range")
	distant.queue_free()
	await _settle()
	# Sparse diagonal-only terrain must not permit reaching through the hole.
	var across: WorldPickup = _spawn(props, Vector2(0, 32), "across_gap")
	ground.terrain_cells.clear()
	ground.terrain_cells[Vector2i.ZERO] = 0
	ground.terrain_cells[Vector2i(1, 1)] = 0
	await _settle()
	_check(detector.target == null and not detector.interact(), "Interaction cannot cross invalid diagonal terrain")
	ground.terrain_cells = saved_terrain.duplicate()
	across.queue_free()
	await _settle()
	# Partial/full collection uses a genuinely full inventory. Remaining world quantity is exact.
	var small: RuntimeInventory = RuntimeInventory.new()
	small.slot_capacity = 1
	small.definitions.assign([SAMPLE])
	root.add_child(small)
	small.add_items(SAMPLE.item_id, 8)
	var partial: WorldPickup = _spawn(props, Vector2(32, 16), "partial", 5)
	await _settle()
	_check(partial.collect(small) == 2 and partial.quantity == 3 and not partial.is_queued_for_deletion(), "Partial collection leaves world remainder")
	_check(partial.collect(small) == 0 and partial.quantity == 3, "Full inventory does not destroy remainder")
	small.remove_items(SAMPLE.item_id, 5)
	_check(partial.collect(small) == 3 and partial.is_queued_for_deletion(), "Final remainder collection removes pickup")
	small.free()
	await _settle()
	var invalid_pickup: WorldPickup = PICKUP.instantiate()
	props.add_child(invalid_pickup)
	_check(not invalid_pickup.is_available() and invalid_pickup.collect(inventory) == 0, "Missing item definition safely unavailable")
	invalid_pickup.item = SAMPLE
	invalid_pickup.quantity = -1
	_check(not invalid_pickup.is_available(), "Nonpositive pickup quantity unavailable")
	invalid_pickup.quantity = 1
	invalid_pickup.item = SAMPLE.duplicate()
	_check(invalid_pickup.collect(inventory) == 0 and invalid_pickup.quantity == 1, "Unregistered definition reference cannot spoof an identifier")
	invalid_pickup.queue_free()
	# Modal: real I opens, immediate stop, UI selection, no movement/interact/Tab/pan/zoom.
	actor.global_position = Vector2.ZERO
	var modal_pickup: WorldPickup = _spawn(props, Vector2(32, 16), "modal", 1)
	await _settle()
	_send(KEY_D, true)
	await _settle(4)
	_check(actor.velocity.length() > 0, "Movement active before modal")
	await _press(KEY_I)
	var modal_position: Vector2 = actor.global_position
	var original_quantity: int = inventory.get_quantity(SAMPLE.item_id)
	var management: BaseManagementCameraRig = main.get_node("BaseManagementCameraRig")
	var original_pan: Vector2 = management.pan_position
	_check(window.visible and not actor.control_enabled and actor.velocity == Vector2.ZERO, "Inventory opens and immediately stops astronaut")
	_check(hud.prompt.text.is_empty() and modes.modal_input_blocked and not detector.interact(), "Modal hides prompt and blocks interactions")
	window.inspect_slot(0)
	_check(window.details_name.text == "Lunar Sample" and window.details_description.text == SAMPLE.description and "10" in window.details_quantity.text, "Selected slot shows name, description and stack quantity")
	var updates: int = window.refresh_count
	await _settle(8)
	_check(window.refresh_count == updates, "Inventory UI not rebuilt/refreshed every frame")
	_check(actor.global_position == modal_position and actor.visual.state == &"idle", "Held movement cannot move astronaut through modal")
	_check(not paused and dog.follow_enabled, "Inventory leaves world and autonomous companion simulation running")
	await _press(KEY_E)
	await _press(KEY_TAB)
	modes.route_pan(Vector2.RIGHT, 0.5)
	_check(inventory.get_quantity(SAMPLE.item_id) == original_quantity and modal_pickup.quantity == 1, "Inventory blocks actual interaction input")
	_check(modes.is_player_mode() and not modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT) and management.pan_position == original_pan, "Modal blocks keyboard and API mode changes/pan")
	# Inspection and keyboard focus are separate APIs; start navigation from a known slot.
	window.slot_buttons[0].grab_focus()
	await _settle(1)
	_check(root.gui_get_focus_owner() == window.slot_buttons[0], "Keyboard navigation fixture starts on a focused slot")
	var old_selection: int = window.selected_slot
	_send(KEY_RIGHT, true)
	await _settle()
	_send(KEY_RIGHT, false)
	_check(window.selected_slot != old_selection and root.gui_get_focus_owner() != null, "Keyboard arrows change selected slot and keep UI focus (before %d, after %d)" % [old_selection, window.selected_slot])
	# Updating while open refreshes one transaction immediately.
	inventory.add_items(&"metal_scrap", 2)
	await _click(window.slot_buttons[2])
	_check(window.details_name.text == "Metal Scrap" and "spare metal" in window.details_description.text, "Mouse/button selection inspects another item")
	_check(window.refresh_count == updates + 1, "Open UI updates only on actual inventory change")
	_check(inventory.get_quantity(SAMPLE.item_id) == original_quantity and modal_pickup.quantity == 1, "Inventory mouse click cannot leak to primary world interaction")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("inventory_open")
	await _press(KEY_ESCAPE)
	_check(not window.visible and actor.control_enabled and root.gui_get_focus_owner() == null, "Esc closes inventory and releases focus")
	await _settle(3)
	_check(actor.global_position == modal_position, "Held movement remains gated after closing")
	_send(KEY_D, false)
	await _settle()
	_send(KEY_D, true)
	await _settle(3)
	_send(KEY_D, false)
	_check(actor.global_position.x > modal_position.x, "Fresh movement resumes after neutral input")
	await _press(KEY_I)
	await _press(KEY_I)
	_check(not window.visible, "Inventory action also closes window")
	# Focused external controls do not leak interaction or open inventory.
	var edit: LineEdit = LineEdit.new()
	main.get_node("UI").add_child(edit)
	edit.grab_focus()
	await _press(KEY_E)
	await _press(KEY_I)
	_check(not window.visible and inventory.get_quantity(SAMPLE.item_id) == original_quantity, "External keyboard focus respected")
	edit.release_focus()
	edit.queue_free()
	await _settle()
	# Management preservation and stale interaction: held E across both handoffs is ignored.
	_send(KEY_E, true)
	await _settle()
	var collected: int = inventory.get_quantity(SAMPLE.item_id)
	var stable_pickup: WorldPickup = _spawn(props, actor.global_position + Vector2(24, 0), "mode_hold", 2)
	await _press(KEY_TAB)
	var dog_position: Vector2 = dog.global_position
	var actor_position: Vector2 = actor.global_position
	_check(modes.is_management_mode() and not detector.enabled and hud.prompt.text.is_empty(), "Management disables interactions/prompt")
	await _press(KEY_I)
	_check(not window.visible, "Inventory opening restricted to Player Mode")
	await _settle(4)
	_check(dog.global_position == dog_position and actor.global_position == actor_position, "Both actors preserve positions in management")
	_check(inventory.get_instance_id() == inventory_id and inventory.get_quantity(SAMPLE.item_id) == collected, "Same runtime inventory survives mode switch")
	_check(main.get_node("World").get_instance_id() == world_id and not props.has_node("LunarSampleA") and not props.has_node("LunarSampleB"), "Same world and collected-object state preserved")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("inventory_management")
	await _press(KEY_TAB)
	_send(KEY_E, true, true)
	await _settle()
	_check(inventory.get_quantity(SAMPLE.item_id) == collected and stable_pickup.quantity == 2, "Held interaction cannot leak across modes")
	_send(KEY_E, false)
	await _press(KEY_E)
	_check(inventory.get_quantity(SAMPLE.item_id) == collected + 2, "Fresh interaction resumes after release")
	_check(dog.follow_enabled and main.get_node("World/Entities/NPCs").get_child_count() == 1, "Existing single companion remains functional")
	_check(actor.visual.art_profile != null and dog.visual.art_profile != null and actor.visual.sprite_frames.get_animation_names().size() == 24, "Real character artwork and additive run animation contract preserved")
	_check(ground.terrain_cells == saved_terrain and ground.get_used_cells().size() == ground.region.size.x * ground.region.size.y, "Pickup/modal activity does not rebuild terrain")
	# Phase 0.8 acceptance: collect all item types through E and the actual GameUI.
	# Start a fresh test world so acceptance captures show the authored pickup totals.
	main.queue_free()
	await process_frame
	main = MAIN.instantiate()
	root.add_child(main)
	actor = main.get_node("World/Entities/Players/Astronaut")
	dog = main.get_node("World/Entities/NPCs/Chiwis")
	inventory = actor.get_node("Inventory")
	detector = actor.get_node("InteractionDetector")
	modes = main.get_node("Systems/GameplayModes")
	window = main.get_node("UI/InventoryWindow")
	hud = main.get_node("UI/InteractionPrompt")
	props = main.get_node("World/Entities/Props")
	ground = main.get_node("World/Terrain/Ground")
	world_id = main.get_node("World").get_instance_id()
	inventory_id = inventory.get_instance_id()
	var game_ui: GameUI = main.get_node("UI")
	await _settle()
	_check(inventory.free_slot_count() == 20 and props.get_child_count() == 4, "Fresh acceptance fixture starts with empty inventory and four authored pickups")
	await _press(KEY_E)
	_check(inventory.get_quantity(SAMPLE.item_id) == 6, "Authored initial sample collected through E")
	actor.global_position = Vector2(32, 16)
	await _settle()
	await _press(KEY_E)
	_check(inventory.get_quantity(SAMPLE.item_id) == 14 and not props.has_node("LunarSampleA") and not props.has_node("LunarSampleB"), "Both authored sample pickups collected into capped stacks")
	var scrap_before: int = inventory.get_quantity(&"metal_scrap")
	actor.global_position = Vector2(0, 32)
	await _settle()
	_check(detector.target == props.get_node("MetalScrap/Interaction"), "Existing Metal Scrap world pickup selected")
	await _press(KEY_E)
	_check(inventory.get_quantity(&"metal_scrap") == scrap_before + 3 and not props.has_node("MetalScrap"), "E collects authored Metal Scrap quantity")
	actor.global_position = Vector2(-48, -32)
	await _settle()
	_check(detector.target == props.get_node("SupplyPack/Interaction"), "Existing Supply Pack world pickup selected")
	await _press(KEY_E)
	_check(inventory.get_quantity(&"supply_pack") == 1 and not props.has_node("SupplyPack"), "E collects authored nonstackable Supply Pack")
	_check(inventory.get_quantity(SAMPLE.item_id) == 14, "Collecting other types preserves sample stacks")
	await _press(KEY_I)
	window.slot_buttons[3].grab_focus()
	window.inspect_slot(3)
	_check(window.visible and window.details_name.text == "Supply Pack" and window.details_description.text == inventory.definition(&"supply_pack").description, "Current UI inspects collected Supply Pack definition")
	_check(window.slot_buttons[0].text == "x10" and window.slot_buttons[1].text == "x4" and window.slot_buttons[2].text == "x3" and window.slot_buttons[3].text == "x1", "All three item types display correct capped stacks")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("phase_0_8_inventory")
	await _press(KEY_ESCAPE)
	# Fill the real 20-slot player inventory through its public API, not a substitute model.
	for item_id: StringName in [&"lunar_sample", &"metal_scrap", &"supply_pack"]:
		inventory.remove_items(item_id, inventory.get_quantity(item_id))
	_check(inventory.free_slot_count() == 20, "Removal API frees all runtime slots")
	_check(inventory.add_items(&"supply_pack", 19) == 19 and inventory.add_items(SAMPLE.item_id, 8) == 8, "Real inventory fixture fills nineteen nonstackable slots and one partial stack")
	_check(inventory.free_slot_count() == 0 and inventory.available_quantity_capacity(SAMPLE.item_id) == 2, "Occupied slots retain exactly two matching item spaces")
	var capacity_pickup: WorldPickup = _spawn(props, actor.global_position + Vector2(24, 0), "phase_0_8_capacity", 5)
	var capacity_id: int = capacity_pickup.get_instance_id()
	await _settle()
	_check(detector.target == capacity_pickup.interaction and hud.prompt.text == "[E] Collect Lunar Sample", "Actual nearby capacity-test pickup reaches existing prompt")
	await _press(KEY_E)
	_check(inventory.get_quantity(SAMPLE.item_id) == 10 and capacity_pickup.quantity == 3 and not capacity_pickup.is_queued_for_deletion(), "Real E accepts only two and leaves three in the world")
	_check(game_ui.hud.notifications.message.text == "Collected", "Partial collection reports success through current notification area")
	var refresh_before_full: int = window.refresh_count
	await _press(KEY_E)
	_check(inventory.get_quantity(SAMPLE.item_id) == 10 and capacity_pickup.quantity == 3, "Real E with full inventory preserves both quantities")
	_check(game_ui.hud.notifications.message.text == "Inventory full or item unavailable", "Full collection failure visible through GameUI")
	_check(window.refresh_count == refresh_before_full, "Rejected pickup emits no false inventory transaction")
	await _press(KEY_I)
	window.slot_buttons[19].grab_focus()
	window.inspect_slot(19)
	_check(window.summary.text == "20 / 20 slots used" and window.slot_buttons[19].text == "x10", "Full inventory window displays exact capacity and final stack")
	_check(not actor.control_enabled and actor.velocity == Vector2.ZERO and hud.prompt.text.is_empty(), "Full inventory modal still blocks movement and interaction")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("phase_0_8_full_inventory")
	await _press(KEY_ESCAPE)
	await _press(KEY_TAB)
	var capacity_actor_position: Vector2 = actor.global_position
	var capacity_dog_position: Vector2 = dog.global_position
	await _settle(4)
	_check(modes.is_management_mode() and not detector.enabled and game_ui.hud.mode_label.text == "BASE MANAGEMENT MODE", "Capacity case preserves management UI and interaction policy")
	_check(inventory.get_instance_id() == inventory_id and main.get_node("World").get_instance_id() == world_id, "Capacity case retains same inventory and world instances")
	_check(capacity_pickup.get_instance_id() == capacity_id and capacity_pickup.quantity == 3 and inventory.get_quantity(SAMPLE.item_id) == 10 and inventory.get_quantity(&"supply_pack") == 19, "Partial world remainder and full inventory survive camera switch")
	_check(actor.global_position == capacity_actor_position and dog.global_position == capacity_dog_position, "Both actors remain stationary in management")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("phase_0_8_management")
	await _press(KEY_TAB)
	var removed_quantity: int = inventory.remove_items(SAMPLE.item_id, 3)
	_check(removed_quantity == 3 and inventory.available_quantity_capacity(SAMPLE.item_id) == 3, "Removal restores matching-stack space after mode return")
	await _press(KEY_E)
	_check(not is_instance_valid(capacity_pickup) and inventory.get_quantity(SAMPLE.item_id) == 10, "Fresh E collects remainder and removes only fully collected pickup")
	_check(inventory.get_quantity(SAMPLE.item_id) + removed_quantity == 8 + 5, "Item conservation across partial, full-rejected and remainder collection")
	_check(dog.follow_enabled and actor.control_enabled and props.get_child_count() == 0, "Companion/player resume and authored pickups stay collected")
	_check(ground.terrain_cells == saved_terrain and ground.get_used_cells().size() == ground.region.size.x * ground.region.size.y, "Full-capacity flow leaves production terrain unchanged")
	main.queue_free()
	await process_frame
	_finish()


func _spawn(parent: Node, location: Vector2, identifier: String, quantity: int = 1) -> WorldPickup:
	var pickup: WorldPickup = PICKUP.instantiate()
	pickup.item = SAMPLE
	pickup.quantity = quantity
	pickup.pickup_id = identifier
	pickup.position = location
	parent.add_child(pickup)
	return pickup


func _settle(count: int = 3) -> void:
	for index: int in count:
		await physics_frame
	await process_frame


func _send(code: Key, pressed: bool, echo: bool = false) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _press(code: Key) -> void:
	_send(code, true)
	await _settle(1)
	_send(code, false)
	await _settle(1)


func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png("res://tests/output/" + filename + ".png") == OK, "Capture " + filename)


func _click(control: Control) -> void:
	await process_frame
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = control.get_global_rect().get_center()
	event.global_position = event.position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _settle(1)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _settle(1)


func _check(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures.append(label)


func _finish() -> void:
	if _failures.is_empty():
		print("PASS: %d interaction/inventory integration checks" % _checks)
		quit(0)
	else:
		for label: String in _failures:
			printerr("FAIL: " + label)
		quit(1)
