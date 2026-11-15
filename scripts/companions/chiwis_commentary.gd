class_name ChiwisCommentary
extends Node
## Turns existing gameplay signals into companion lines. It observes; it never changes
## inventory, rooms, utilities or objectives. Lines are English text only: no voice or audio.

const P = ChiwisDialogue.Priority
const GREETING_DELAY: float = 1.2
const ONCE: float = 1.0e9
## Rotating remarks avoid repeating one sentence for a repeated event.
const SAMPLE_REMARKS: PackedStringArray = [
	"Another one for the collection.",
	"Logged. The sample bag is filling up.",
	"Nice find. I'll keep count.",
]
const ROOM_LINES: Dictionary[StringName, String] = {
	&"hub": "This corridor links every compartment. Health and science is one of the side hatches.",
	&"living": "Living quarters: bunk, galley and hygiene. Not much, but it's ours.",
	&"engineering": "Engineering. Air, water and power all report to the terminals in here.",
	&"health_lab": "Health and science. The sample station is in this compartment.",
	&"greenhouse": "The growing trays. They need light, power, water and nutrients to make progress.",
	&"cargo": "Cargo hold. The delivered seeds and rations are stored here.",
	&"shelter": "The protected shelter. Good to know where it is.",
}

var dialogue: ChiwisDialogue
var inventory: RuntimeInventory
var director: HabitatDirector
var _safety: EvaSafetyMonitor
var _quantities: Dictionary[StringName, int] = {}
var _sample_remark: int = 0
var _greeting: Timer


func configure(target: ChiwisDialogue, items: RuntimeInventory, detector: InteractionDetector, habitat: HabitatDirector,
		safety: EvaSafetyMonitor, utilities: UtilityService, objectives: ObjectiveTracker, modes: GameplayModeCoordinator) -> void:
	dialogue = target
	inventory = items
	director = habitat
	if is_instance_valid(inventory):
		for id: StringName in [&"lunar_sample", &"metal_scrap", &"supply_pack"]:
			_quantities[id] = inventory.get_quantity(id)
		inventory.changed.connect(_inventory_changed)
	if is_instance_valid(detector):
		detector.target_changed.connect(_target_changed)
		detector.attempted.connect(_attempted.bind(detector))
	if is_instance_valid(director):
		director.location_changed.connect(_location_changed)
	_safety = safety
	if is_instance_valid(safety):
		safety.notice_requested.connect(_safety_notice)
	if is_instance_valid(utilities):
		utilities.critical_notice.connect(_utility_alarm)
	if is_instance_valid(objectives):
		objectives.objective_completed.connect(_objective_completed)
		objectives.mission_completed.connect(_mission_completed)
	if is_instance_valid(modes):
		modes.mode_changed.connect(_mode_changed)
	_greeting = Timer.new()
	_greeting.one_shot = true
	_greeting.timeout.connect(_greet)
	add_child(_greeting)
	_greeting.start(GREETING_DELAY)


## Called by the interface when a utility terminal opens.
func note_utility_terminal() -> void:
	dialogue.say(&"utility_terminal", "These readings come from the habitat model. Keep an eye on the battery and the alarm list.", P.TUTORIAL, 0.0, ONCE)


func _greet() -> void:
	dialogue.say(&"greeting", "Touchdown logged, and I'm right beside you. Let's find that sample marker first.", P.TUTORIAL, 0.0, ONCE)


func _inventory_changed() -> void:
	for id: StringName in _quantities:
		var now: int = inventory.get_quantity(id)
		var gained: bool = now > _quantities[id]
		_quantities[id] = now
		if not gained:
			continue
		match id:
			&"lunar_sample":
				if not dialogue.say(&"sample_first", "Sample secured. Good eye! The science station inside the outpost can examine it.", P.TUTORIAL, 0.0, ONCE):
					if dialogue.say(&"sample_more", SAMPLE_REMARKS[_sample_remark % SAMPLE_REMARKS.size()], P.REMARK, 0.0, 40.0):
						_sample_remark += 1
			&"metal_scrap":
				dialogue.say(&"metal_scrap", "Spare metal. Could be useful once we start fixing things.", P.REMARK, 0.0, ONCE)
			&"supply_pack":
				dialogue.say(&"supply_pack", "A sealed supply pack. I'd keep that one safe.", P.REMARK, 0.0, ONCE)


func _attempted(success: bool, detector: InteractionDetector) -> void:
	if not success and detector.last_result_message.begins_with("Inventory full") and is_instance_valid(inventory) and inventory.free_slot_count() == 0:
		dialogue.say(&"inventory_full", "Your pack is full. We'll have to leave the rest here for now.", P.TUTORIAL, 0.0, 60.0)


func _target_changed(target: Interactable) -> void:
	var action := target as HabitatAction
	if action == null:
		return
	if action.destination == &"facility":
		dialogue.say(StringName("station/" + String(action.action_id)), "That's the %s station. Have a look when you're ready." % _plain(action.display_name), P.REMARK, 0.0, ONCE)
	elif action.action_id == &"enter":
		dialogue.say(&"hatch_found", "There's the crew airlock hatch. In we go when you're ready.", P.TUTORIAL, 0.0, ONCE)


func _location_changed(location: StringName) -> void:
	match location:
		&"outside":
			dialogue.say(&"back_outside", "Back on the surface. Stay inside the marked area and we'll be fine.", P.REMARK, 0.0, 120.0)
		&"crew_airlock":
			dialogue.say(&"airlock_first", "Crew airlock. Outer hatch first, then the suit and dust check, then pressure. I'll stay close.", P.TUTORIAL, 0.0, ONCE)
		&"equipment_lock":
			dialogue.say(&"habitat_first", "Pressure is holding. Welcome inside; this is the clean side of the lock.", P.TUTORIAL, 0.0, ONCE)
		_:
			if ROOM_LINES.has(location):
				dialogue.say(StringName("room/" + String(location)), ROOM_LINES[location], P.REMARK, 0.0, ONCE)


func _safety_notice(text: String, duration: float) -> void:
	# The monitor prefixes its speaker; the dialogue window shows the name separately.
	var spoken: String = text.trim_prefix(ChiwisDialogue.SPEAKER + ": ")
	var boundary: bool = is_instance_valid(_safety) and _safety.current_zone == EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY
	dialogue.say(&"eva_boundary" if boundary else &"eva_warning", spoken, P.CRITICAL if boundary else P.WARNING, maxf(duration, ChiwisDialogue.reading_seconds(spoken)))


func _utility_alarm(_text: String) -> void:
	dialogue.say(&"utility_alarm", "That's a habitat alarm. Let's check a utility terminal in Engineering.", P.CRITICAL, 0.0, 30.0)


func _objective_completed(definition: ObjectiveDefinition) -> void:
	if definition.optional:
		dialogue.say(StringName("task/" + String(definition.objective_id)), "Checked off: %s." % definition.title.to_lower(), P.REMARK, 0.0, ONCE)


func _mission_completed() -> void:
	dialogue.say(&"mission_complete", "Examination recorded. That's our first sample in the mission log. Well done!", P.TUTORIAL, 0.0, ONCE)


func _mode_changed(mode: GameplayModeCoordinator.Mode) -> void:
	if mode == GameplayModeCoordinator.Mode.BASE_MANAGEMENT:
		dialogue.say(&"management_first", "Overview feed online. Pan and zoom to look over the site; I'll wait here.", P.REMARK, 0.0, ONCE)


static func _plain(title: String) -> String:
	# "Science lab / sample storage" reads better in a sentence as "science lab".
	return title.split("/")[0].strip_edges().to_lower()
