class_name UtilityService
extends Node
## Fixed simulation clock outside room/world process scopes; no artwork dependencies.

signal critical_notice(text: String)
signal before_step(seconds: float)
signal stepped(seconds: float)
var model := UtilityModel.new()
var accumulator_s: float = 0.0
var _announced_at: Dictionary[String, float] = {}
var _active_alarms: PackedStringArray = []
var _last_notice_s: float = -1000.0


func _ready() -> void:
	if not model.configure(UtilityConfig.load_default()):
		push_error("Invalid habitat utilities configuration.")
		set_physics_process(false)
		return
	model.alarms_changed.connect(_alarms_changed)
	# Composition finishes before this publishes any non-nominal startup state.
	_publish_initial_alarms.call_deferred()


func _publish_initial_alarms() -> void:
	_alarms_changed(model.alarms)


func _physics_process(delta: float) -> void:
	advance(delta)


func advance(seconds: float) -> void:
	if not is_finite(seconds) or seconds < 0 or model.config == null:
		return
	accumulator_s += seconds
	var step_s: float = float(model.config.data.fixed_step_s)
	var processed: int = 0
	# Retain catch-up debt rather than silently discard simulated time.
	while accumulator_s + 1e-9 >= step_s and processed < 8:
		before_step.emit(step_s)
		model.step(step_s)
		stepped.emit(step_s)
		accumulator_s = maxf(0, accumulator_s - step_s)
		processed += 1


func _alarms_changed(active: PackedStringArray) -> void:
	var new_alarms: Array[String] = []
	for id: String in active:
		if id not in _active_alarms and model.elapsed_s - _announced_at.get(id, -1000.0) >= 30:
			_announced_at[id] = model.elapsed_s
			new_alarms.append(id)
	_active_alarms = active.duplicate()
	# One failed bus can raise several dependent alarms on the next step.
	# Keep all alarms visible in the terminal, but coalesce HUD notices.
	if not new_alarms.is_empty() and model.elapsed_s - _last_notice_s >= 30:
		_last_notice_s = model.elapsed_s
		critical_notice.emit("Habitat alarm: " + new_alarms[0].replace("_", " ").replace("/", ": ") + ". Inspect a utility terminal.")


func capture_state() -> Dictionary:
	return {"schema_version": 1, "accumulator_s": accumulator_s, "model": model.capture_state()}


func restore_state(saved: Dictionary) -> bool:
	if (saved.get("schema_version") != 1 or not UtilityConfig.finite_number(saved.get("accumulator_s"))
			or float(saved.accumulator_s) < 0 or not saved.get("model") is Dictionary):
		return false
	if not model.restore_state(saved.model):
		return false
	accumulator_s = float(saved.accumulator_s)
	_active_alarms = model.alarms.duplicate()
	_announced_at.clear()
	_last_notice_s = model.elapsed_s
	return true
