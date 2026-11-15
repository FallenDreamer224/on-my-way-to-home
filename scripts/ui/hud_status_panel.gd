class_name HudStatusPanel
extends VBoxContainer
## Compact telemetry strip plus an expandable detail card. Every value comes from an existing
## system (EVA monitor, habitat director, utility model). Readouts whose mechanics are not
## implemented stay dimmed and say so; nothing is invented to fill the panel.

const NOT_SIMULATED: String = "Not simulated"
## Suit and physiology readouts the interface is prepared for. None has a data source yet.
const DEFERRED: Array[Array] = [
	[&"physical", &"health", "Physical condition"], [&"fatigue", &"fatigue", "Fatigue"],
	[&"sleep", &"sleep", "Sleep"], [&"suit_oxygen", &"oxygen", "Suit oxygen"],
	[&"suit_battery", &"battery", "Suit battery"], [&"radiation", &"radiation", "Radiation"],
]

var utilities: UtilityService
var safety: EvaSafetyMonitor
var director: HabitatDirector
var expanded: bool = false
var indicators: Dictionary[StringName, TelemetryIndicator] = {}
var strip: PanelContainer
var details: PanelContainer
var alarm_list: Label
var _strip_rows: VBoxContainer
var _detail_rows: VBoxContainer


func _init() -> void:
	name = "StatusPanel"
	add_theme_constant_override(&"separation", 4)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip = UiKit.panel(&"HudPanel")
	strip.name = "Strip"
	add_child(strip)
	_strip_rows = UiKit.vbox(3)
	strip.add_child(_strip_rows)
	for entry: Array in [[&"eva_range", &"location", "EVA range"], [&"airlock", &"pressure", "Airlock"],
			[&"cabin_oxygen", &"oxygen", "Cabin O2"], [&"cabin_co2", &"carbon_dioxide", "Cabin CO2"],
			[&"cabin_pressure", &"pressure", "Cabin pressure"], [&"habitat_battery", &"battery", "Habitat battery"],
			[&"alarms", &"warning", "Habitat alarms"]]:
		_strip_rows.add_child(_make(entry))
	details = UiKit.panel(&"HudPanel")
	details.name = "Details"
	details.hide()
	add_child(details)
	_detail_rows = UiKit.vbox(1)
	details.add_child(_detail_rows)
	_detail_rows.add_child(UiKit.label("ASTRONAUT", &"SectionLabel"))
	for entry: Array in DEFERRED:
		_detail_rows.add_child(_make(entry, true))
	_detail_rows.add_child(_make([&"co2_safety", &"carbon_dioxide", "CO2 safety"], true))
	_detail_rows.add_child(UiKit.separator())
	_detail_rows.add_child(UiKit.label("HABITAT CABIN", &"SectionLabel"))
	for entry: Array in [[&"cabin_temperature", &"temperature", "Temperature"], [&"cabin_humidity", &"water", "Humidity"]]:
		_detail_rows.add_child(_make(entry, true))
	alarm_list = UiKit.wrapped("", &"MutedLabel", 220)
	alarm_list.name = "AlarmList"
	_detail_rows.add_child(alarm_list)
	var note: Label = UiKit.wrapped("Dimmed rows are not simulated in this build. Cabin values are tutorial model estimates, not medical limits.", &"CaptionLabel", 220)
	_detail_rows.add_child(note)
	UiKit.make_passive(self)
	refresh()


func bind(utility_service: UtilityService, safety_monitor: EvaSafetyMonitor, habitat: HabitatDirector) -> void:
	utilities = utility_service
	safety = safety_monitor
	director = habitat
	if is_instance_valid(utilities):
		utilities.model.changed.connect(refresh)
		utilities.model.alarms_changed.connect(func(_active: PackedStringArray) -> void: refresh())
	if is_instance_valid(safety):
		safety.zone_changed.connect(func(_zone: EvaSafetyLimits.Zone) -> void: refresh())
	if is_instance_valid(director):
		director.location_changed.connect(func(_location: StringName) -> void: refresh())
		director.airlock_changed.connect(refresh)
	refresh()


func set_expanded(value: bool) -> void:
	if expanded == value:
		return
	expanded = value
	if expanded:
		refresh()
		UiMotion.fade_in(details, UiMotion.FAST)
	else:
		UiMotion.fade_out(details, UiMotion.FAST)


func refresh() -> void:
	var location: StringName = director.location if is_instance_valid(director) else &"outside"
	var outside: bool = location == &"outside"
	var in_airlock: bool = location == &"crew_airlock"
	var in_cabin: bool = not outside and not in_airlock
	_refresh_eva(outside)
	_refresh_airlock(in_airlock)
	var has_model: bool = is_instance_valid(utilities) and utilities.model.config != null
	for id: StringName in [&"cabin_oxygen", &"cabin_co2", &"cabin_pressure"]:
		indicators[id].visible = in_cabin and has_model
	indicators[&"habitat_battery"].visible = has_model
	if not has_model:
		indicators[&"alarms"].hide()
		for id: StringName in [&"co2_safety", &"cabin_temperature", &"cabin_humidity"]:
			indicators[id].set_unavailable("No habitat data")
		alarm_list.text = ""
		return
	var model: UtilityModel = utilities.model
	var alarms: PackedStringArray = model.alarms
	var oxygen_alarm: bool = "cabin_oxygen_low" in alarms or "cabin_oxygen_high" in alarms
	var pressure_alarm: bool = "cabin_pressure_low" in alarms or "cabin_pressure_high" in alarms
	var co2_alarm: bool = "cabin_co2_high" in alarms
	indicators[&"cabin_oxygen"].set_reading("%.1f kPa" % (model.partial_pressure_pa("cabin_o2_kg") / 1000.0), _alarm_state(oxygen_alarm))
	indicators[&"cabin_co2"].set_reading("%.0f Pa" % model.partial_pressure_pa("cabin_co2_kg"), _alarm_state(co2_alarm))
	indicators[&"cabin_pressure"].set_reading("%.1f kPa" % (model.pressure_pa() / 1000.0), _alarm_state(pressure_alarm))
	var capacity: float = float(model.config.data.battery_capacity_wh)
	var net: float = float(model.last_power.battery_w)
	indicators[&"habitat_battery"].set_reading("%d%%  %+.0f W" % [roundi(100.0 * model.battery_wh / capacity), net],
		UiKit.State.WARNING if "battery_reserve_low" in alarms else UiKit.State.NOMINAL)
	indicators[&"alarms"].visible = not alarms.is_empty()
	if not alarms.is_empty():
		indicators[&"alarms"].set_reading("%d active" % alarms.size(), UiKit.State.CRITICAL)
	if not expanded:
		return
	# The astronaut breathes cabin air only inside the pressurized habitat.
	if in_cabin:
		indicators[&"co2_safety"].set_reading("High: alarm active" if co2_alarm else "Within cabin limit", _alarm_state(co2_alarm))
	else:
		indicators[&"co2_safety"].set_unavailable("Suit air: not simulated")
	var temperature_alarm: bool = "cabin_temperature_low" in alarms or "cabin_temperature_high" in alarms
	var humidity_alarm: bool = "cabin_humidity_low" in alarms or "cabin_humidity_high" in alarms
	indicators[&"cabin_temperature"].set_reading("%.1f C" % (model.temperature_k() - 273.15), _alarm_state(temperature_alarm))
	indicators[&"cabin_humidity"].set_reading("%.1f g/m3" % model.humidity_g_m3(), _alarm_state(humidity_alarm))
	var names: PackedStringArray = []
	for alarm: String in alarms:
		names.append(UiKit.humanize(alarm))
	alarm_list.text = "Alarms: none" if names.is_empty() else "Alarms: " + ", ".join(names)
	alarm_list.theme_type_variation = &"MutedLabel" if names.is_empty() else &"CriticalLabel"


func _refresh_eva(outside: bool) -> void:
	var indicator: TelemetryIndicator = indicators[&"eva_range"]
	indicator.visible = outside
	if not outside:
		return
	if not is_instance_valid(safety) or safety.limits == null:
		indicator.set_unavailable("No mission area")
		return
	match safety.current_zone:
		EvaSafetyLimits.Zone.WARNING:
			indicator.set_reading("Near mission limit", UiKit.State.WARNING)
		EvaSafetyLimits.Zone.RESTRICTED_BOUNDARY:
			indicator.set_reading("At mission boundary", UiKit.State.CRITICAL)
		_:
			indicator.set_reading("Inside mission area", UiKit.State.OK)


func _refresh_airlock(in_airlock: bool) -> void:
	var indicator: TelemetryIndicator = indicators[&"airlock"]
	indicator.visible = in_airlock
	if not in_airlock or not is_instance_valid(director):
		return
	var chamber: HabitatAirlock = director.airlock
	var text: String = ["Vacuum", "Habitat pressure", "Cycling"][chamber.pressure]
	indicator.set_reading(text, UiKit.State.WARNING if chamber.pressure == HabitatAirlock.Pressure.CYCLING else UiKit.State.NOMINAL)


func _make(entry: Array, inline: bool = false) -> TelemetryIndicator:
	var indicator := TelemetryIndicator.new(entry[0], entry[1], entry[2], inline)
	indicators[entry[0]] = indicator
	return indicator


static func _alarm_state(alarm: bool) -> UiKit.State:
	return UiKit.State.CRITICAL if alarm else UiKit.State.OK
