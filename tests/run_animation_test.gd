extends SceneTree
## Native import integrity and isolated selector checks; live running is covered separately.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
const FINGERPRINT = preload("res://tools/pixelorama/animation_fingerprint.gd")
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/pixelorama_runs.json"))
	_check(manifest.sources.size() == 16 and manifest.walk_source_inventory.size() == 16, "All current run/walk source projects inspected")
	_check(manifest.preserved_walk_idle_fingerprints.size() == 32, "All legacy clips fingerprinted before additive merge")
	for record: Dictionary in manifest.walk_source_inventory:
		_check(record.native_pixels_match_existing_walk and record.frame_audit.size() == record.source_frame_count, "Current walk files verified against preserved PNGs without replacement")
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var astronaut: Astronaut = main.get_node("World/Entities/Players/Astronaut")
	var dog: Chiwis = main.get_node("World/Entities/NPCs/Chiwis")
	var actors: Dictionary[String, Node2D] = {"astronaut": astronaut, "chiwis": dog}
	_check(astronaut.walk_speed == 80 and dog.movement_speed == 90, "Normal movement speeds unchanged")
	_check(InputMap.has_action("player_run") and not InputMap.has_action("sprint") and not InputMap.has_action("player_sprint"), "One authoritative hold-to-run action; no duplicate sprint actions")
	var original_actor: Vector2 = astronaut.global_position
	var original_dog: Vector2 = dog.global_position
	# Freeze body physics only inside the test so controllers cannot replace preview states.
	astronaut.set_physics_process(false)
	dog.set_physics_process(false)
	astronaut.global_position = Vector2(-48, 0)
	dog.global_position = Vector2(48, 0)
	for key: String in manifest.preserved_walk_idle_fingerprints:
		var profile: CharacterArtProfile = (actors[key.get_slice("/", 0)].get_node("AnimatedSprite2D") as AstronautAnimation).art_profile
		_check(FINGERPRINT.clip(profile, StringName(key.get_slice("/", 1))) == manifest.preserved_walk_idle_fingerprints[key], "Original walk/idle frames, timing, order, loop and anchors unchanged")
	var seen: Dictionary[String, bool] = {}
	for record: Dictionary in manifest.sources:
		var key: String = record.character + "/" + record.direction
		_check(not seen.has(key) and record.animation_type == "run", "Exactly one run per character/direction")
		seen[key] = true
		_check(record.status == "verified_exact_native_pixels" and record.source_frame_count == record.frame_audit.size(), "All native run frames verified")
		_check(FileAccess.get_sha256("res://" + record.png) == record.png_sha256, "Run PNG hash unchanged since original source comparison")
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path("res://" + record.png))
		_check(image.get_size() == Vector2i(64 * record.source_frame_count, 64), "Native transparent 64 x 64 frames")
		var body: Node2D = actors[record.character]
		var visual: AstronautAnimation = body.get_node("AnimatedSprite2D")
		var frames: SpriteFrames = visual.sprite_frames
		var clip: StringName = StringName("run_" + record.direction)
		_check(frames.get_animation_names().size() == 24 and frames.get_frame_count(clip) == record.source_frame_count, "Eight run clips added alongside sixteen legacy states")
		_check(is_equal_approx(frames.get_animation_speed(clip), record.fps) and frames.get_animation_loop(clip), "Actual source FPS and looping preserved")
		_check(body.scale == Vector2.ONE and visual.scale == Vector2.ONE and not visual.flip_h and not visual.flip_v, "Native character proportions and actual directional art")
		var config: ConfigFile = ConfigFile.new()
		_check(config.load("res://" + record.png + ".import") == OK, "Native import sidecar exists")
		for rule: Array in [["compress/mode", 0], ["mipmaps/generate", false], ["process/fix_alpha_border", false], ["process/size_limit", 0], ["process/premult_alpha", false]]:
			_check(config.get_value("params", rule[0]) == rule[1], "Pixel-preserving run import rule")
		visual.select_state(&"run", StringName(record.direction))
		visual.pause()
		_check(visual.animation == clip and visual.facing == StringName(record.direction), "Run selector maps direction without flipping")
		var position_before: Vector2 = body.global_position
		for index: int in record.frame_audit.size():
			var audit: Dictionary = record.frame_audit[index]
			_check(not audit.empty and audit.has_generation_provenance and audit.transparency != Image.ALPHA_NONE, "Nonempty completed nonguide run frame with transparency")
			var atlas: AtlasTexture = frames.get_frame_texture(clip, index) as AtlasTexture
			_check(atlas.atlas.resource_path == "res://" + record.png and atlas.region == Rect2(index * 64, 0, 64, 64), "Source frame order and actual texture mapping")
			_check(is_equal_approx(frames.get_frame_duration(clip, index), audit.duration_units), "Per-frame duration preserved")
			var region: Image = atlas.get_image()
			var hash: HashingContext = HashingContext.new()
			hash.start(HashingContext.HASH_SHA256)
			hash.update(region.get_data())
			_check(hash.finish().hex_encode() == audit.rgba_sha256, "Actual imported frame RGBA equals source audit")
			visual.set_frame_and_progress(index, 0)
			await process_frame
			await process_frame
			var anchor: Vector2 = visual.get_frame_anchor()
			_check(anchor == Vector2(audit.foot_anchor_px[0], audit.foot_anchor_px[1]) and anchor.y == region.get_used_rect().end.y, "Measured per-frame foot anchor retained")
			var canvas: Transform2D = body.get_canvas_transform()
			var actual: Vector2 = canvas * (visual.global_position + anchor)
			_check(actual.is_equal_approx((canvas * body.global_position).round()), "Ground contact stays at snapped body root through every run frame")
			_check(body.global_position == position_before, "Animation never moves the body or collider")
	_check(seen.size() == 16, "All sixteen distinct run directions covered")
	# Let the native clock advance and verify repeated requests do not restart playback.
	for body: Node2D in actors.values():
		var visual: AstronautAnimation = body.get_node("AnimatedSprite2D")
		visual.select_state(&"run", &"n")
		visual.play()
		visual.set_frame_and_progress(0, 0)
		await create_timer(0.37).timeout
		_check(visual.frame > 0 and visual.is_playing(), "Native run clock advances through source frames")
		visual.pause()
		visual.set_frame_and_progress(1, 0.35)
		visual.select_state(&"run", &"n")
		_check(visual.frame == 1 and is_equal_approx(visual.frame_progress, 0.35), "Repeated run state request does not restart clip")
		visual.select_state(&"walk", &"n")
		_check(visual.animation == &"walk_n", "Run can return to preserved walk state")
		visual.select_state(&"idle", &"n")
		_check(visual.animation == &"idle_n" and visual.sprite_frames.get_frame_count(&"idle_n") == 1, "Run can return to unchanged provisional idle")
	if "--capture" in OS.get_cmdline_user_args():
		for facing: StringName in AstronautDirections.NAMES:
			for body: Node2D in actors.values():
				var visual: AstronautAnimation = body.get_node("AnimatedSprite2D")
				visual.select_state(&"run", facing)
				visual.pause()
				visual.set_frame_and_progress(1, 0)
			await process_frame
			await RenderingServer.frame_post_draw
			_check(root.get_texture().get_image().save_png("res://tests/output/run_" + facing + ".png") == OK, "Capture run facing " + facing)
	astronaut.global_position = original_actor
	dog.global_position = original_dog
	astronaut.set_physics_process(true)
	dog.set_physics_process(true)
	await physics_frame
	await physics_frame
	await process_frame
	_check(astronaut.visual.state == &"idle" and dog.visual.state == &"idle", "Normal controllers resume idle when stationary after preview")
	_check(dog.follow_enabled and astronaut.control_enabled, "Player and companion behavior preserved after preview")
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d run animation checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _check(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures.append(label)
