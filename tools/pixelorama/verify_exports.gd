extends SceneTree
## Verify CLI output against independently reconstructed original cel pixels, then build resources.

const INSPECT = preload("res://tools/pixelorama/inspect_pxo.gd")
const FINGERPRINT = preload("res://tools/pixelorama/animation_fingerprint.gd")
const ORDER: Array[String] = ["n", "ne", "e", "se", "s", "sw", "w", "nw"]

func _initialize() -> void:
	var source_root: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("assets")
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	var animation_type: String = "run"
	var type_option: int = arguments.find("--animation-type")
	if type_option >= 0 and type_option + 1 < arguments.size():
		animation_type = arguments[type_option + 1]
	assert(animation_type in ["walk", "run"])
	var manifest_path: String = "res://art/imports/pixelorama_runs.json" if animation_type == "run" else "res://art/imports/pixelorama_characters.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var source_option: int = arguments.find("--source-root")
	if source_option >= 0 and source_option + 1 < arguments.size():
		source_root = arguments[source_option + 1]
	var frames_by_character: Dictionary = {}
	var anchors_by_character: Dictionary = {}
	var sheets: Dictionary = {}
	var profiles: Dictionary[String, CharacterArtProfile] = {}
	var preserved: Dictionary[String, String] = {}
	for character: String in ["astronaut", "chiwis"]:
		var profile: CharacterArtProfile = load("res://resources/characters/" + character + "_art.tres")
		profiles[character] = profile
		var frames: SpriteFrames = profile.frames
		if animation_type == "run":
			for clip: StringName in frames.get_animation_names():
				if String(clip).begins_with("idle_") or String(clip).begins_with("walk_"):
					preserved[character + "/" + clip] = FINGERPRINT.clip(profile, clip)
		frames_by_character[character] = frames
		anchors_by_character[character] = profile.foot_anchors
		var contact: Image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
		contact.fill(Color("27313b"))
		sheets[character] = contact
	for record: Dictionary in manifest.sources:
		var path: String = source_root.path_join(record.source)
		assert(FileAccess.get_sha256(path) == record.sha256, "Source changed; reinspect: " + path)
		var zip: ZIPReader = ZIPReader.new()
		assert(zip.open(path) == OK)
		var data: Dictionary = JSON.parse_string(zip.read_file("data.json").get_string_from_utf8())
		record["asset_id"] = String(record.source).trim_suffix(".pxo").replace("/", "_")
		record["standards_version"] = manifest.standards_version
		record["category"] = "directional_character_animation" if record.has("png") else "character_reference"
		record["source_provider"] = "User-supplied Pixelorama project; existing cel provenance retained in external original"
		record["source_files"] = [record.source]
		record["runtime_files"] = [record.png] if record.has("png") else []
		record["usage_terms"] = "User-supplied for integration into On My Way to Home; no third-party redistribution license inferred"
		record["native_canvas_size_px"] = [64, 64]
		record["physical_scale_intent"] = "Native pixel density, unit sprite scale; canvas padding does not determine physical size"
		record["review_status"] = "Inspected source layers, frame content, direction and exact exported pixels"
		record["exception"] = null
		record["source_reference_images_count"] = data.reference_images.size()
		record["reference_frame_policy"] = "Character sheets excluded; all animation frames reviewed as completed nonguide art"
		record["source_generation_requests"] = "Not created in this phase; original provenance metadata remains in source PXO"
		if record.has("png"):
			record["animation_name"] = animation_type + "_" + record.direction
			record["animation_type"] = animation_type
			record["frame_size_px"] = [64, 64]
			record["rows"] = 1
			record["columns"] = data.frames.size()
			record["margin_px"] = 0
			record["separation_px"] = 0
			record["loop"] = true
			record["frame_order"] = record.source_frame_indices
			record["direction_space"] = "screen_facing"
			record["direction_coverage"] = [String(record.direction).to_upper()]
			record["direction_order"] = record.direction_coverage
			record["provider_direction_mapping"] = {String(record.source).get_file().trim_suffix(".pxo").get_slice("_" + animation_type + "_", 1): record.direction}
		record["frame_audit"] = []
		var sheet: Image
		var texture: Texture2D
		var frames: SpriteFrames
		var anchors: PackedVector2Array = []
		var clip: String = animation_type + "_" + String(record.get("direction", ""))
		if record.has("png"):
			sheet = Image.load_from_file(ProjectSettings.globalize_path("res://" + record.png))
			assert(sheet.get_size() == Vector2i(64 * data.frames.size(), 64), "Unexpected CLI sheet layout")
			texture = load("res://" + record.png)
			assert(texture != null)
			frames = frames_by_character[record.character]
			if frames.has_animation(clip):
				frames.remove_animation(clip)
			frames.add_animation(clip)
			frames.set_animation_speed(clip, data.fps)
			if animation_type == "walk":
				if frames.has_animation("idle_" + record.direction):
					frames.remove_animation("idle_" + record.direction)
				frames.add_animation("idle_" + record.direction)
				frames.set_animation_speed("idle_" + record.direction, data.fps)
		for index: int in data.frames.size():
			var expected: Image = INSPECT.composite(zip, data, index)
			assert(not expected.is_invisible(), "Empty source frame: " + path)
			var bounds: Rect2i = expected.get_used_rect()
			var generated: bool = false
			for cel: Dictionary in data.frames[index].cels:
				if cel.get("metadata", {}).has("pixellab_v3_drawn"):
					generated = true
			var hash: HashingContext = HashingContext.new()
			hash.start(HashingContext.HASH_SHA256)
			hash.update(expected.get_data())
			var audit: Dictionary = {"source_frame": index + 1, "duration_units": data.frames[index].duration, "duration_seconds": data.frames[index].duration / data.fps, "bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "empty": false, "has_generation_provenance": generated, "transparency": expected.detect_alpha(), "rgba_sha256": hash.finish().hex_encode()}
			audit["visible_height_px"] = bounds.size.y
			record.frame_audit.append(audit)
			if record.has("png"):
				assert(generated, "Unreviewed reference/incomplete animation frame: " + path)
				var actual: Image = sheet.get_region(Rect2i(index * 64, 0, 64, 64))
				assert(actual.get_data() == expected.get_data(), "CLI pixels differ from source; skeleton/blend/order check failed")
				var anchor: Vector2 = Vector2(32, bounds.end.y)
				anchors.append(anchor)
				audit["foot_anchor_px"] = [anchor.x, anchor.y]
				var atlas: AtlasTexture = AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(index * 64, 0, 64, 64)
				frames.add_frame(clip, atlas, data.frames[index].duration)
				if index == 0 and animation_type == "walk":
					frames.add_frame("idle_" + record.direction, atlas)
				var contact: Image = sheets[record.character]
				contact.blend_rect(expected, Rect2i(0, 0, 64, 64), Vector2i(index * 64, ORDER.find(record.direction) * 64))
		if record.has("png"):
			var map: Dictionary = anchors_by_character[record.character]
			map[StringName(clip)] = anchors
			if animation_type == "walk":
				map[StringName("idle_" + record.direction)] = PackedVector2Array([anchors[0]])
			record.status = "verified_exact_native_pixels"
			record["rendered_frame_count"] = data.frames.size()
			record["anchor_policy"] = "Source canvas X=32; measured lowest opaque foot row+1 per frame, applied only as visual offset"
			record["png_sha256"] = FileAccess.get_sha256("res://" + record.png)
		zip.close()
	DirAccess.make_dir_recursive_absolute("res://resources/characters")
	for character: String in ["astronaut", "chiwis"]:
		var frames: SpriteFrames = frames_by_character[character]
		assert(frames.get_animation_names().size() == (24 if frames.has_animation(&"run_n") else 16))
		assert(ResourceSaver.save(frames, "res://resources/characters/" + character + "_frames.tres") == OK)
		frames.take_over_path("res://resources/characters/" + character + "_frames.tres")
		var profile: CharacterArtProfile = profiles[character]
		profile.frames = frames
		var map: Dictionary = anchors_by_character[character]
		for clip: StringName in map:
			profile.foot_anchors[clip] = map[clip]
		if animation_type == "walk":
			profile.default_anchor = profile.foot_anchors[&"idle_s"][0]
		if animation_type == "run":
			for legacy: StringName in frames.get_animation_names():
				var key: String = character + "/" + legacy
				if preserved.has(key):
					assert(FINGERPRINT.clip(profile, legacy) == preserved[key], "Walk/idle changed during run integration")
		assert(ResourceSaver.save(profile, "res://resources/characters/" + character + "_art.tres") == OK)
		var contact: Image = sheets[character]
		var contact_name: String = character + ("_run" if animation_type == "run" else "") + "_source_contact.png"
		assert(contact.save_png("res://tests/output/" + contact_name) == OK)
	if animation_type == "run":
		assert(preserved.size() == 32)
		manifest["preserved_walk_idle_fingerprints"] = preserved
		_audit_walk_sources(manifest, source_root)
	manifest["verification"] = "All listed originals hash-checked; 16 CLI sheets match original nonguide RGBA pixels and ordering exactly; no resizing/recoloring; resources merged additively"
	var output: FileAccess = FileAccess.open(manifest_path, FileAccess.WRITE)
	output.store_string(JSON.stringify(manifest, "  "))
	print("Verified 16 native %s sheets; merged both SpriteFrames/art profiles while preserving other states." % animation_type)
	quit()


func _audit_walk_sources(manifest: Dictionary, source_root: String) -> void:
	for record: Dictionary in manifest.walk_source_inventory:
		var path: String = source_root.path_join(record.source)
		assert(FileAccess.get_sha256(path) == record.sha256, "Walk source changed during audit")
		var zip: ZIPReader = ZIPReader.new()
		assert(zip.open(path) == OK)
		var data: Dictionary = JSON.parse_string(zip.read_file("data.json").get_string_from_utf8())
		var existing: Image = Image.load_from_file(ProjectSettings.globalize_path("res://" + record.existing_png))
		var same: bool = existing.get_size() == Vector2i(64 * data.frames.size(), 64)
		record["frame_audit"] = []
		for index: int in data.frames.size():
			var image: Image = INSPECT.composite(zip, data, index)
			var bounds: Rect2i = image.get_used_rect()
			assert(not image.is_invisible(), "Empty current walk source frame")
			if same and existing.get_region(Rect2i(index * 64, 0, 64, 64)).get_data() != image.get_data():
				same = false
			record.frame_audit.append({"source_frame": index + 1, "bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "transparency": image.detect_alpha(), "empty": false})
		record["native_pixels_match_existing_walk"] = same
		print("Audited %s: current pixels match preserved walk = %s; no walk export performed" % [record.source, same])
		zip.close()
