class_name EquipmentRecord
extends Resource
## One reference card for the in-game equipment database. Factual fields are copied verbatim
## from the research registry by tools/research/build_equipment_database.gd; only `game_usage`
## and `game_system` are authored for the game. Never used for balancing or item definitions.

const STATUSES: Array[StringName] = [&"operational", &"demonstrated", &"in_development", &"research"]

@export var research_id: StringName
@export var official_name: String
@export var category: String
@export var evidence_status: StringName
@export_multiline var actual_function: String
@export_multiline var testing_environment: String
@export var limitations: PackedStringArray = []
@export var source_organization: String
@export var reference_url: String
@export var game_system: StringName
@export_multiline var game_usage: String


func is_valid_record() -> bool:
	return (not String(research_id).is_empty() and not official_name.strip_edges().is_empty()
		and evidence_status in STATUSES and not actual_function.strip_edges().is_empty()
		and not game_usage.strip_edges().is_empty())
