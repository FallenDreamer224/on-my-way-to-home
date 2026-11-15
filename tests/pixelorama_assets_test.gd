extends SceneTree

var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/pixelorama_characters.json"))
	_check(manifest.sources.size() == 18, "All eighteen source projects audited")
	var seen: Dictionary[String, bool] = {}
	for record: Dictionary in manifest.sources:
		_check(record.canvas == [64.0, 64.0] or record.canvas == [64, 64], "Native 64 x 64 source canvas")
		_check(record.frame_audit.size() == record.source_frame_count, "Every source frame inspected")
		if not record.has("png"):
			_check(record.reference_only, "Character reference project excluded from walk clips")
			continue
		var key: String = record.character + "/" + record.direction
		_check(not seen.has(key), "No duplicate directional animation")
		seen[key] = true
		_check(record.status == "verified_exact_native_pixels", "Native source comparison completed")
		_check(FileAccess.get_sha256("res://" + record.png) == record.png_sha256, "PNG hash retained")
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path("res://" + record.png))
		_check(image.get_size() == Vector2i(64 * record.source_frame_count, 64), "PNG layout/count preserved")
		var profile: CharacterArtProfile = load("res://resources/characters/" + record.character + "_art.tres")
		_check(profile.frames.get_animation_names().size() == 24, "Eight distinct walk/idle clips preserved alongside eight run clips")
		var walk: StringName = StringName("walk_" + record.direction)
		var idle: StringName = StringName("idle_" + record.direction)
		_check(profile.frames.get_frame_count(walk) == record.source_frame_count, "Variable actual frame count")
		_check(profile.frames.get_frame_count(idle) == 1, "Provisional stationary idle")
		_check(is_equal_approx(profile.frames.get_animation_speed(walk), record.fps), "Original per-direction FPS")
		for index: int in record.frame_audit.size():
			var audit: Dictionary = record.frame_audit[index]
			_check(not audit.empty and audit.has_generation_provenance, "No empty or unreviewed reference animation frame")
			var atlas: AtlasTexture = profile.frames.get_frame_texture(walk, index) as AtlasTexture
			_check(atlas != null and atlas.atlas.resource_path == "res://" + record.png, "Real source PNG loaded")
			_check(atlas.region == Rect2(index * 64, 0, 64, 64), "Original order without rescaling")
			_check(is_equal_approx(profile.frames.get_frame_duration(walk, index), audit.duration_units), "Frame duration preserved")
			var anchor: Vector2 = profile.foot_anchors[walk][index]
			_check(anchor == Vector2(audit.foot_anchor_px[0], audit.foot_anchor_px[1]), "Measured frame anchor retained")
			var region: Image = image.get_region(Rect2i(index * 64, 0, 64, 64))
			var hash: HashingContext = HashingContext.new()
			hash.start(HashingContext.HASH_SHA256)
			hash.update(region.get_data())
			_check(hash.finish().hex_encode() == audit.rgba_sha256, "Exact independently verified RGBA pixels")
	_check(seen.size() == 16, "Eight unique directions per character")
	_finish()


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)


func _finish() -> void:
	if _failures.is_empty():
		print("PASS: %d Pixelorama asset checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)
