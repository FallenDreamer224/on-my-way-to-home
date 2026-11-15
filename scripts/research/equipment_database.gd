class_name EquipmentDatabase
extends Resource
## Generated, read-only reference set for the equipment database screen.
## The research registry itself stays outside the Godot resource scan.

const PATH: String = "res://resources/data/equipment_database.tres"
const STATUS_TITLES: Dictionary[StringName, String] = {
	&"operational": "Operational", &"demonstrated": "Demonstrated",
	&"in_development": "In development", &"research": "Research / reference",
}
const STATUS_NOTES: Dictionary[StringName, String] = {
	&"operational": "Documented operational use or flight heritage in the stated setting. It does not imply lunar deployment.",
	&"demonstrated": "A bounded test completed in the named environment. Scope and duration remain limited.",
	&"in_development": "Hardware, integration or capability still being developed or qualified.",
	&"research": "An evidence area, experiment, analog, standard or environmental reference; not an operational product.",
}

@export var catalog_version: String
@export var reviewed_through: String
@export var records: Array[EquipmentRecord] = []


static func load_default() -> EquipmentDatabase:
	return load(PATH) as EquipmentDatabase if ResourceLoader.exists(PATH) else null


func find(research_id: StringName) -> EquipmentRecord:
	for record: EquipmentRecord in records:
		if record.research_id == research_id:
			return record
	return null


func with_status(status: StringName) -> Array[EquipmentRecord]:
	var result: Array[EquipmentRecord] = []
	for record: EquipmentRecord in records:
		if status == &"" or record.evidence_status == status:
			result.append(record)
	return result


func count_by_status() -> Dictionary[StringName, int]:
	var result: Dictionary[StringName, int] = {}
	for status: StringName in EquipmentRecord.STATUSES:
		result[status] = 0
	for record: EquipmentRecord in records:
		result[record.evidence_status] = int(result.get(record.evidence_status, 0)) + 1
	return result
