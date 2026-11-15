extends SceneTree
## Native resource/physics/sorting contracts plus optional 1x development captures.
const PREVIEW: PackedScene = preload("res://scenes/development/lunar_exterior_preview.tscn")
var checks: int = 0
var failures: PackedStringArray = []
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message)
func settle() -> void:
	await physics_frame
	await process_frame
func run() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/lunar_exterior_library.json"))
	check(catalog.assets.size() == 41 and not catalog.production_world_changed, "Complete isolated asset catalog")
	var ids: Dictionary[StringName, bool] = {}
	for record: Dictionary in catalog.assets:
		var definition: ExteriorAssetDefinition = load("res://" + record.resource_path)
		check(definition != null and definition.validation_errors().is_empty(), "Valid native metadata: " + record.asset_id)
		check(not ids.has(definition.asset_id), "Stable unique asset ID")
		ids[definition.asset_id] = true
		var prefab: Node2D = (load("res://" + record.scene_path) as PackedScene).instantiate()
		root.add_child(prefab)
		var sprite: Sprite2D = prefab.get_node("Sprite2D")
		check(prefab.scale == Vector2.ONE and sprite.scale == Vector2.ONE and sprite.rotation == 0, "Native scale/unrotated sprite: " + record.asset_id)
		check(prefab.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and not sprite.centered and sprite.offset == -Vector2(definition.ground_anchor), "Filtering and exact pivot: " + record.asset_id)
		check(prefab.get_node("GroundPivot").position == Vector2.ZERO and prefab.get_node("GridOrigin").position == Vector2(definition.grid_origin), "Ground/reference origins distinct")
		check(prefab.get_node("InteractionAnchor").position == Vector2(definition.interaction_anchor) and prefab.get_node("ServiceAnchor").position == Vector2(definition.service_anchor), "Prepared access/service points")
		check(not prefab is Interactable and prefab.get_script() == null, "Decorative native prefab has no invented gameplay script")
		if definition.collision_enabled:
			var body: StaticBody2D = prefab.get_node("Body")
			var shape: CollisionPolygon2D = body.get_node("CollisionPolygon2D")
			check(body.collision_layer == 1 and shape.polygon == definition.collision_polygon, "Shared native foot-collision layer")
			check(definition.navigation_reserved_cells.size() == (definition.footprint_size.x + 2) * (definition.footprint_size.y + 2), "Routing reservations include ground hardware clearance")
			await physics_frame
			var query := PhysicsPointQueryParameters2D.new()
			var center := Vector2.ZERO
			for vertex: Vector2 in definition.collision_polygon: center += vertex
			query.position = center / definition.collision_polygon.size()
			query.collision_mask = 1
			var hits: Array[Dictionary] = root.world_2d.direct_space_state.intersect_point(query)
			check(not hits.is_empty() and hits[0].collider == body, "Physics body lies on its declared ground envelope")
			query.position = Vector2(definition.interaction_anchor)
			check(root.world_2d.direct_space_state.intersect_point(query).is_empty(), "Access marker is outside blocked footprint")
		else:
			check(not prefab.has_node("Body"), "Ground/pickup/reference object adds no blocking body")
		if definition.supports_states:
			var indicator: ExteriorStateIndicator = prefab.get_node("StateIndicator")
			check(not indicator.visible, "State marker opt-in until bound to real equipment")
			var device := UtilityEquipment.new({"id":"preview_device", "name":"Preview device", "watts":0, "priority":0, "critical":false})
			device.enabled = true
			device.powered = true
			check(indicator.display_equipment(device) and indicator.state == ExteriorStateIndicator.State.OPERATIONAL, "Powered presentation")
			device.enabled = false
			indicator.display_equipment(device)
			check(indicator.state == ExteriorStateIndicator.State.DISABLED and not device.enabled, "Unpowered presentation changes no device state")
			device.maintenance = true
			indicator.display_equipment(device)
			check(indicator.state == ExteriorStateIndicator.State.MAINTENANCE, "Maintenance presentation")
			device.fault = true
			indicator.display_equipment(device)
			check(indicator.state == ExteriorStateIndicator.State.DAMAGED and device.maintenance, "Fault priority preserves source state")
		var source := Image.new()
		check(source.load_png_from_buffer(FileAccess.get_file_as_bytes("res://" + record.runtime_path)) == OK, "Runtime PNG decodes")
		source.convert(Image.FORMAT_RGBA8)
		var imported: Image = definition.texture.get_image()
		imported.convert(Image.FORMAT_RGBA8)
		check(source.get_data() == imported.get_data() and not imported.has_mipmaps(), "Exact unscaled imported pixels: " + record.asset_id)
		prefab.queue_free()
		await process_frame
	var preview: Node2D = PREVIEW.instantiate()
	root.add_child(preview)
	await settle()
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/app_root.tscn", "Normal startup preserved")
	check(preview.camera.zoom == Vector2.ONE and not preview.camera.position_smoothing_enabled, "Native unsmoothed preview camera")
	for item: Node2D in preview.entries.values():
		check(item.get_parent().y_sort_enabled, "Assets share an entity Y-sort parent")
		var floor_layer: TerrainLayer = item.get_parent().get_parent().get_child(0)
		var reference: Vector2 = item.get_node("GridOrigin").global_position
		var cell: Vector2i = IsometricGrid.world_to_tile(reference, floor_layer)
		check(reference == IsometricGrid.tile_to_world(cell, floor_layer), "Every prepared object reference snaps to native terrain grid")
	if "--capture" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/output/phase_0_8g1/captures"))
		for view: String in preview.VIEWS:
			check(preview.show_view(view), "Inspection bay selectable: " + view)
			await settle()
			await RenderingServer.frame_post_draw
			var image: Image = root.get_texture().get_image()
			check(image.get_size() == Vector2i(960, 540), "Native logical capture")
			check(image.save_png("res://tests/output/phase_0_8g1/captures/" + view + ".png") == OK, "Capture " + view)
		# Full atlas uses a separate native-resolution viewport, never downscales sprites.
		var atlas := SubViewport.new()
		atlas.size = Vector2i(1920, 2160)
		atlas.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(atlas)
		var full: Node2D = PREVIEW.instantiate()
		atlas.add_child(full)
		full.camera.position = Vector2(960, 1080)
		full.camera.force_update_scroll()
		await settle()
		await RenderingServer.frame_post_draw
		check(atlas.get_texture().get_image().save_png("res://tests/output/phase_0_8g1/captures/full_showcase.png") == OK, "Native 1920x2160 complete library showcase")
		atlas.queue_free()
	preview.queue_free()
	await process_frame
	for failure: String in failures: printerr("FAIL: " + failure)
	if failures.is_empty(): print("PASS: %d lunar exterior asset/physics/preview checks" % checks)
	quit(0 if failures.is_empty() else 1)
