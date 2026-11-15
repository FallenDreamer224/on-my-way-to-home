extends SceneTree
## Generates resources/data/equipment_database.tres from the research registry and the curated
## map beside this script. Factual fields are copied verbatim; nothing is paraphrased or invented.
##   godot --headless --path . --script res://tools/research/build_equipment_database.gd
## Add `-- --check` to verify the committed resource without writing.

const REGISTRY: String = "res://resources/research/nasa_technology_catalog.json"
const MAP: String = "res://tools/research/equipment_database_map.json"
const OUTPUT: String = "res://resources/data/equipment_database.tres"
const SYSTEMS: Array[String] = ["habitat", "life_support", "water", "food", "power", "eva", "hazards", "health", "science", "environment"]


func _initialize() -> void:
	var registry: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY))
	var map: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAP))
	if not registry is Dictionary or not map is Dictionary:
		printerr("Cannot read the research registry or the equipment map.")
		quit(1)
		return
	var categories: Dictionary = {}
	for category: Dictionary in registry.categories:
		categories[category.id] = category.name
	var entries: Dictionary = {}
	for entry: Dictionary in registry.entries:
		entries[entry.id] = entry
	var database := EquipmentDatabase.new()
	database.catalog_version = String(registry.catalog_version)
	database.reviewed_through = String(registry.reviewed_through)
	var errors: PackedStringArray = []
	var seen: Dictionary = {}
	for choice: Dictionary in map.entries:
		var id: String = choice.get("id", "")
		if not entries.has(id):
			errors.append("Unknown research id: " + id)
			continue
		if seen.has(id):
			errors.append("Duplicate research id: " + id)
			continue
		seen[id] = true
		if String(choice.get("game_system", "")) not in SYSTEMS or String(choice.get("game_usage", "")).strip_edges().is_empty():
			errors.append("Missing game system/usage: " + id)
			continue
		var source: Dictionary = entries[id]
		var record := EquipmentRecord.new()
		record.research_id = StringName(id)
		record.official_name = source.official_name
		record.category = categories.get(source.category_id, source.category_id)
		record.evidence_status = StringName(source.evidence_status)
		record.actual_function = source.actual_function
		record.testing_environment = source.actual_testing_environment
		record.limitations = PackedStringArray(source.limitations_and_uncertainties)
		record.source_organization = source.source_organization
		record.reference_url = source.official_reference_url
		record.game_system = StringName(choice.game_system)
		record.game_usage = choice.game_usage
		if not record.is_valid_record():
			errors.append("Invalid generated record: " + id)
			continue
		database.records.append(record)
	if not errors.is_empty():
		for error: String in errors:
			printerr("ERROR: " + error)
		quit(1)
		return
	if "--check" in OS.get_cmdline_user_args():
		var committed: EquipmentDatabase = load(OUTPUT)
		var same: bool = committed != null and committed.records.size() == database.records.size() and committed.catalog_version == database.catalog_version
		if same:
			for index: int in database.records.size():
				for property: String in ["research_id", "official_name", "category", "evidence_status", "actual_function", "testing_environment",
						"limitations", "source_organization", "reference_url", "game_system", "game_usage"]:
					if committed.records[index].get(property) != database.records[index].get(property):
						same = false
		print("PASS: equipment database matches the registry (%d records)." % database.records.size() if same else "FAIL: equipment database differs from the registry.")
		quit(0 if same else 1)
		return
	var result: Error = ResourceSaver.save(database, OUTPUT)
	print("Saved %s: %d records, registry %s reviewed through %s (error %d)" % [OUTPUT, database.records.size(), database.catalog_version, database.reviewed_through, result])
	quit(0 if result == OK else 1)
