class_name UtilityEquipment
extends RefCounted
## Operational flags and counters, not item inventory or artwork state.

var id: String
var title: String
var watts: float
var priority: int
var critical: bool
var enabled: bool = true
var fault: bool = false
var maintenance: bool = false
var powered: bool = false
var runtime_s: float = 0.0
var service_count: int = 0
var status: String = "ready"


func _init(data: Dictionary) -> void:
	id = data.id
	title = data.name
	watts = float(data.watts)
	priority = int(data.priority)
	critical = bool(data.critical)
	enabled = bool(data.get("enabled", true))


func available() -> bool:
	return enabled and not fault and not maintenance


func snapshot() -> Dictionary:
	return {"enabled": enabled, "fault": fault, "maintenance": maintenance, "powered": powered,
		"runtime_s": runtime_s, "service_count": service_count, "status": status}
