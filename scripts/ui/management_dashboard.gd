class_name ManagementDashboard
extends PanelContainer
## Base Management dock: read-only telemetry from existing services. It adds no simulation
## and issues no equipment commands; operation stays at the habitat terminals. Buttons never
## take keyboard focus, so camera pan and zoom keep working while the dock is open.

signal database_requested

const CATEGORIES: Array[Array] = [
	[&"overview", &"habitat", "Base Overview"], [&"power", &"power", "Electrical Power"],
	[&"battery", &"battery", "Battery Storage"], [&"life_support", &"air", "Environmental Life Support"],
	[&"water", &"water", "Water and Recycling"], [&"greenhouse", &"greenhouse", "Greenhouse"],
	[&"storage", &"supply_tool", "Storage and Resources"], [&"equipment", &"gear", "Equipment Condition"],
	[&"maintenance", &"wrench", "Maintenance"], [&"research", &"research", "Research"],
	[&"mission", &"mission", "Current Mission"],
]
## Presentation metadata for the utility devices: category and the station that operates each.
const DEVICE_INFO: Dictionary[String, Array] = {
	"solar": ["Power generation", "Power distribution terminal"],
	"battery": ["Energy storage", "Power distribution terminal"],
	"distribution": ["Power distribution", "Power distribution terminal"],
	"ventilation": ["Life support", "Environmental control terminal"],
	"oxygen_supply": ["Life support", "Environmental control terminal"],
	"co2_removal": ["Life support", "Environmental control terminal"],
	"housekeeping": ["Habitat electronics", "Power distribution terminal"],
	"heating": ["Thermal control", "Environmental control terminal"],
	"thermal_control": ["Thermal control", "Environmental control terminal"],
	"dehumidifier": ["Humidity recovery", "Environmental control terminal"],
	"water_treatment": ["Water processing", "Water processing terminal"],
	"greenhouse_lights": ["Greenhouse", "Greenhouse station (tray lights)"],
}
const LIFE_SUPPORT_DEVICES: PackedStringArray = ["ventilation", "oxygen_supply", "co2_removal", "dehumidifier", "heating", "thermal_control"]

var utilities: UtilityService
var daily: DailyLife
var inventory: RuntimeInventory
var director: HabitatDirector
var tracker: ObjectiveTracker
var dialogue: ChiwisDialogue
var database: EquipmentDatabase
var current: StringName = &"overview"
var selected_device: String = "distribution"
var title: Label
var rail_buttons: Dictionary[StringName, Button] = {}
var device_buttons: Dictionary[String, Button] = {}
var pages: Dictionary[StringName, VBoxContainer] = {}
var database_button: Button
var _updaters: Dictionary[StringName, Array] = {}
var _rail_group := ButtonGroup.new()
var _device_group := ButtonGroup.new()
var _refresh_queued: bool = false
var _holder: VBoxContainer


func _init() -> void:
	name = "Dashboard"
	theme_type_variation = &"DockPanel"
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = -(GameHUD.DOCK_WIDTH + GameHUD.EDGE)
	offset_right = -GameHUD.EDGE
	offset_top = GameHUD.EDGE
	offset_bottom = -36
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Keep unconsumed scrolls inside the dock, including when its page cannot scroll.
	mouse_force_pass_scroll_events = false
	hide()
	var row := UiKit.hbox(6)
	add_child(row)
	var rail := UiKit.vbox(1)
	rail.name = "Rail"
	row.add_child(rail)
	for entry: Array in CATEGORIES:
		var button := Button.new()
		button.name = String(entry[0]).to_pascal_case()
		button.theme_type_variation = &"RailButton"
		button.toggle_mode = true
		button.button_group = _rail_group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(28, 22)
		button.tooltip_text = entry[2]
		button.pressed.connect(show_category.bind(entry[0]))
		var glyph: Control = UiKit.compact_icon(entry[1], 20)
		glyph.position = Vector2(5, 1)
		button.add_child(glyph)
		rail.add_child(button)
		rail_buttons[entry[0]] = button
	row.add_child(VSeparator.new())
	var content := UiKit.vbox(4)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(content)
	content.add_child(UiKit.label("BASE MANAGEMENT", &"CaptionLabel"))
	title = UiKit.wrapped("", &"SectionLabel")
	title.name = "Title"
	content.add_child(title)
	content.add_child(UiKit.separator())
	var scroll: ScrollContainer = UiKit.scroll()
	scroll.name = "Scroll"
	content.add_child(scroll)
	_holder = UiKit.vbox(0)
	_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_holder)
	for entry: Array in CATEGORIES:
		var page := UiKit.vbox(3)
		page.name = String(entry[0]).to_pascal_case()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.hide()
		_holder.add_child(page)
		pages[entry[0]] = page
		_updaters[entry[0]] = []
	var hint: Label = UiKit.label("", &"CaptionLabel")
	hint.name = "Hint"
	content.add_child(hint)
	_updaters[&"_hint"] = [func() -> void: hint.text = "[%s] / [%s] CATEGORY" % [InputHint.label(&"dashboard_previous").to_upper(), InputHint.label(&"dashboard_next").to_upper()]]


func configure(utility_service: UtilityService, routines: DailyLife, items: RuntimeInventory, habitat: HabitatDirector,
		objectives: ObjectiveTracker, companion: ChiwisDialogue, reference: EquipmentDatabase) -> void:
	utilities = utility_service
	daily = routines
	inventory = items
	director = habitat
	tracker = objectives
	dialogue = companion
	database = reference
	_build_pages()
	if is_instance_valid(utilities):
		utilities.model.changed.connect(queue_refresh)
	if is_instance_valid(daily):
		daily.changed.connect(queue_refresh)
	if is_instance_valid(inventory):
		inventory.changed.connect(queue_refresh)
	if is_instance_valid(tracker):
		tracker.changed.connect(queue_refresh)
	if is_instance_valid(dialogue):
		dialogue.history_changed.connect(queue_refresh)
	if is_instance_valid(director):
		director.location_changed.connect(func(_location: StringName) -> void: queue_refresh())
	show_category(current)


func set_open(value: bool) -> void:
	if value == visible:
		return
	if value:
		refresh()
		UiMotion.fade_in(self, UiMotion.FAST)
	else:
		UiMotion.fade_out(self, UiMotion.FAST)


func show_category(category: StringName) -> void:
	if not pages.has(category):
		return
	current = category
	for id: StringName in pages:
		pages[id].visible = id == category
		rail_buttons[id].set_pressed_no_signal(id == category)
	title.text = String(CATEGORIES[_index(category)][2]).to_upper()
	refresh()


func step(direction: int) -> void:
	show_category(CATEGORIES[posmod(_index(current) + direction, CATEGORIES.size())][0])


func refresh_bindings() -> void:
	for updater: Callable in _updaters[&"_hint"]:
		updater.call()


## Several services report in the same frame; one deferred refresh covers them all.
func queue_refresh() -> void:
	if _refresh_queued or not visible:
		return
	_refresh_queued = true
	refresh.call_deferred()


func refresh() -> void:
	_refresh_queued = false
	for updater: Callable in _updaters[current]:
		updater.call()
	refresh_bindings()


func _index(category: StringName) -> int:
	for slot: int in CATEGORIES.size():
		if CATEGORIES[slot][0] == category:
			return slot
	return 0


# --- Page construction -----------------------------------------------------------------------

func _section(category: StringName, text: String) -> void:
	pages[category].add_child(UiKit.label(text, &"SectionLabel"))


func _note(category: StringName, text: String) -> void:
	pages[category].add_child(UiKit.wrapped(text, &"CaptionLabel", 200))


## Narrow dock readings wrap vertically instead of expanding beyond the viewport.
func _reading(category: StringName, caption: String) -> Label:
	var box := UiKit.vbox(1)
	box.add_child(UiKit.wrapped(caption, &"SecondaryLabel"))
	var value := UiKit.wrapped("")
	box.add_child(value)
	pages[category].add_child(box)
	return value


func _row(category: StringName, caption: String, getter: Callable) -> void:
	var value: Label = _reading(category, caption)
	_updaters[category].append(func() -> void:
		var reading: Variant = getter.call()
		if reading is Array:
			value.text = reading[0]
			value.theme_type_variation = UiKit.STATE_LABELS[reading[1]]
		else:
			value.text = str(reading))


func _gauge(category: StringName, caption: String, getter: Callable) -> void:
	var value: Label = _reading(category, caption)
	var bar: ProgressBar = UiKit.gauge()
	pages[category].add_child(bar)
	_updaters[category].append(func() -> void:
		var reading: Array = getter.call()
		bar.max_value = maxf(0.0001, float(reading[1]))
		bar.value = clampf(float(reading[0]), 0.0, bar.max_value)
		bar.theme_type_variation = UiKit.STATE_GAUGES[reading[3]]
		value.text = reading[2])


func _text(category: StringName, getter: Callable) -> void:
	var body: Label = UiKit.wrapped("", &"SecondaryLabel", 200)
	pages[category].add_child(body)
	_updaters[category].append(func() -> void:
		var reading: Variant = getter.call()
		if reading is Array:
			body.text = reading[0]
			body.theme_type_variation = UiKit.STATE_LABELS[reading[1]] if reading[1] != UiKit.State.NOMINAL else &"SecondaryLabel"
		else:
			body.text = str(reading))


func _build_pages() -> void:
	if not is_instance_valid(utilities) or utilities.model.config == null:
		for entry: Array in CATEGORIES:
			_note(entry[0], "Habitat services are unavailable.")
		return
	var model: UtilityModel = utilities.model
	var cfg: Dictionary = model.config.data
	var alarm := func(ids: Array) -> UiKit.State:
		for id: String in ids:
			if id in model.alarms:
				return UiKit.State.CRITICAL
		return UiKit.State.OK
	var battery_reading := func() -> Array:
		return [model.battery_wh, float(cfg.battery_capacity_wh), "%.0f / %.0f Wh" % [model.battery_wh, float(cfg.battery_capacity_wh)],
			UiKit.State.WARNING if "battery_reserve_low" in model.alarms else UiKit.State.NOMINAL]
	var pool := func(key: String, state: UiKit.State = UiKit.State.NOMINAL) -> Array:
		return [model.resources[key], float(cfg.capacities_kg[key]), "%.2f / %.0f kg" % [model.resources[key], float(cfg.capacities_kg[key])], state]
	var device := func(id: String) -> Array:
		var item: UtilityEquipment = model.equipment[id]
		return [item.status.capitalize(), _device_state(item)]

	# Overview
	_section(&"overview", "SITE")
	_row(&"overview", "Astronaut location", func() -> String: return director.location_title() if is_instance_valid(director) else "Unknown")
	_row(&"overview", "Habitat model clock", func() -> String: return _clock(model.elapsed_s))
	_gauge(&"overview", "Battery", battery_reading)
	_row(&"overview", "Generation / load", func() -> String: return "%.0f W / %.0f W" % [model.last_power.generation_w, model.last_power.load_w])
	_row(&"overview", "Cabin pressure", func() -> Array: return ["%.1f kPa" % (model.pressure_pa() / 1000.0), alarm.call(["cabin_pressure_low", "cabin_pressure_high"])])
	_row(&"overview", "Cabin O2 / CO2", func() -> Array: return ["%.1f kPa / %.0f Pa" % [model.partial_pressure_pa("cabin_o2_kg") / 1000.0, model.partial_pressure_pa("cabin_co2_kg")],
		alarm.call(["cabin_oxygen_low", "cabin_oxygen_high", "cabin_co2_high"])])
	_row(&"overview", "Potable water", func() -> Array: return ["%.1f kg" % model.resources.potable_kg, alarm.call(["potable_water_low"])])
	if is_instance_valid(daily):
		_row(&"overview", "Greenhouse trays", func() -> String: return _tray_summary())
	_section(&"overview", "ALARMS")
	_text(&"overview", func() -> Array: return _alarm_text())

	# Electrical power
	_row(&"power", "Solar available", func() -> String: return "%.0f W at %.0f%% sunlight" % [float(cfg.solar_available_w), model.solar_fraction * 100.0])
	_row(&"power", "Generation", func() -> String: return "%.0f W" % model.last_power.generation_w)
	_row(&"power", "Load", func() -> String: return "%.0f W" % model.last_power.load_w)
	_row(&"power", "Curtailed", func() -> String: return "%.0f W" % model.last_power.curtailed_w)
	_row(&"power", "Bus capacity", func() -> String: return "%.0f W" % float(cfg.bus_capacity_w))
	_row(&"power", "Distribution", func() -> Array: return device.call("distribution"))
	_section(&"power", "LOADS BY PRIORITY")
	_text(&"power", func() -> String: return _load_list())
	_section(&"power", "ENERGY LEDGER")
	_row(&"power", "Generated", func() -> String: return "%.1f Wh" % model.ledger.generation_wh)
	_row(&"power", "Consumed", func() -> String: return "%.1f Wh" % model.ledger.load_wh)
	_row(&"power", "Curtailed", func() -> String: return "%.1f Wh" % model.ledger.curtailed_wh)
	_note(&"power", "Solar input is a configured scenario value. No array geometry or day-night cycle drives it.")

	# Battery storage
	_gauge(&"battery", "Stored energy", battery_reading)
	_row(&"battery", "Net flow", func() -> Array:
		var net: float = float(model.last_power.battery_w)
		return ["%+.0f W (%s)" % [net, "charging" if net > 0.5 else "discharging" if net < -0.5 else "steady"],
			UiKit.State.OK if net > 0.5 else UiKit.State.WARNING if net < -0.5 else UiKit.State.NOMINAL])
	_row(&"battery", "At the current rate", func() -> String:
		var net: float = float(model.last_power.battery_w)
		if net < -0.5:
			return "%.1f h to empty" % (model.battery_wh / -net)
		if net > 0.5:
			return "%.1f h to full" % ((float(cfg.battery_capacity_wh) - model.battery_wh) / net)
		return "No change")
	_row(&"battery", "Charge / discharge limit", func() -> String: return "%.0f W / %.0f W" % [float(cfg.max_charge_w), float(cfg.max_discharge_w)])
	_row(&"battery", "Charge / discharge efficiency", func() -> String: return "%.0f%% / %.0f%%" % [float(cfg.charge_efficiency) * 100.0, float(cfg.discharge_efficiency) * 100.0])
	_row(&"battery", "Reserve alarm below", func() -> String: return "%.0f Wh" % float(cfg.alarms.battery_reserve_wh))
	_row(&"battery", "Battery unit", func() -> Array: return device.call("battery"))
	_row(&"battery", "Conversion losses", func() -> String: return "%.1f Wh" % model.ledger.battery_loss_wh)
	_note(&"battery", "Capacity, limits and efficiencies are tutorial assumptions, not ratings of real hardware.")

	# Environmental life support
	_row(&"life_support", "Cabin", func() -> String: return "Occupied" if model.occupied else "Unoccupied")
	_row(&"life_support", "Pressure", func() -> Array: return ["%.2f kPa" % (model.pressure_pa() / 1000.0), alarm.call(["cabin_pressure_low", "cabin_pressure_high"])])
	_row(&"life_support", "Oxygen partial pressure", func() -> Array: return ["%.2f kPa" % (model.partial_pressure_pa("cabin_o2_kg") / 1000.0), alarm.call(["cabin_oxygen_low", "cabin_oxygen_high"])])
	_row(&"life_support", "Carbon dioxide", func() -> Array: return ["%.0f Pa" % model.partial_pressure_pa("cabin_co2_kg"), alarm.call(["cabin_co2_high"])])
	_row(&"life_support", "Humidity", func() -> Array: return ["%.1f g/m3" % model.humidity_g_m3(), alarm.call(["cabin_humidity_low", "cabin_humidity_high"])])
	_row(&"life_support", "Temperature", func() -> Array: return ["%.1f C" % (model.temperature_k() - 273.15), alarm.call(["cabin_temperature_low", "cabin_temperature_high"])])
	_gauge(&"life_support", "Stored oxygen", func() -> Array: return pool.call("oxygen_store_kg", UiKit.State.WARNING if "stored_oxygen_low" in model.alarms else UiKit.State.NOMINAL))
	_gauge(&"life_support", "Captured CO2", func() -> Array: return pool.call("captured_co2_kg"))
	_section(&"life_support", "EQUIPMENT")
	for id: String in LIFE_SUPPORT_DEVICES:
		_row(&"life_support", model.equipment[id].title, device.bind(id))
	_note(&"life_support", "One well-mixed cabin model. Stored oxygen is released through a valve; none is generated. Limits are tutorial alarm settings, not medical thresholds.")

	# Water and recycling
	_gauge(&"water", "Potable water", func() -> Array: return pool.call("potable_kg", UiKit.State.WARNING if "potable_water_low" in model.alarms else UiKit.State.NOMINAL))
	_gauge(&"water", "Wastewater", func() -> Array: return pool.call("wastewater_kg"))
	_gauge(&"water", "Reject (unrecovered)", func() -> Array: return pool.call("reject_kg"))
	_row(&"water", "Treated so far", func() -> String: return "%.2f kg" % model.ledger.water_treated_kg)
	_row(&"water", "Recovery fraction", func() -> String: return "%.0f%%" % (float(cfg.rates.water_recovery_fraction) * 100.0))
	_row(&"water", "Water treatment", func() -> Array: return device.call("water_treatment"))
	_row(&"water", "Humidity recovery", func() -> Array: return device.call("dehumidifier"))
	if is_instance_valid(daily):
		_row(&"water", "Crop and routine water", func() -> String: return "%.2f kg" % daily.water_used_kg)
	_note(&"water", "Recovery yield and rates are game assumptions. Purity and contaminant chemistry are not modelled.")

	# Greenhouse
	if is_instance_valid(daily):
		for index: int in daily.trays.size():
			_section(&"greenhouse", "TRAY %d" % (index + 1))
			_row(&"greenhouse", "State", func() -> Array:
				var tray: Dictionary = daily.trays[index]
				var state: UiKit.State = UiKit.State.OK if String(tray.status) in ["Growing", "Harvest ready"] else UiKit.State.WARNING if tray.planted else UiKit.State.OFFLINE
				return [String(tray.status), state])
			_gauge(&"greenhouse", "Growth", func() -> Array:
				var tray: Dictionary = daily.trays[index]
				var total: float = float(daily.settings.crop.growth_s)
				return [float(tray.growth_s), total, "%.0f%%" % (100.0 * float(tray.growth_s) / total), UiKit.State.OK])
			_row(&"greenhouse", "Light / ready portions", func() -> String:
				var tray: Dictionary = daily.trays[index]
				return "%s / %d" % ["On" if tray.light else "Off", int(tray.remaining_yield)])
		_section(&"greenhouse", "SUPPLIES")
		_row(&"greenhouse", "Crop", func() -> String: return String(daily.settings.crop.name))
		_row(&"greenhouse", "Nutrients", func() -> String: return "%.2f units" % daily.nutrients)
		_row(&"greenhouse", "Seeds carried / in cargo", func() -> String: return "%d / %d" % [inventory.get_quantity(&"greens_seed") if is_instance_valid(inventory) else 0, daily.seed_stock])
		_row(&"greenhouse", "Lights and pump", func() -> Array: return device.call("greenhouse_lights"))
		_row(&"greenhouse", "Portions harvested", func() -> String: return str(daily.harvested))
		_note(&"greenhouse", "Growth time is compressed for the tutorial. Portions are supplemental and plants credit no oxygen.")
	else:
		_note(&"greenhouse", "Greenhouse data is unavailable.")

	# Storage and resources
	_section(&"storage", "ASTRONAUT INVENTORY")
	_row(&"storage", "Slots used", func() -> Array:
		if not is_instance_valid(inventory):
			return ["Unavailable", UiKit.State.OFFLINE]
		var used: int = inventory.slot_count() - inventory.free_slot_count()
		return ["%d / %d" % [used, inventory.slot_count()], UiKit.State.WARNING if inventory.free_slot_count() == 0 else UiKit.State.NOMINAL])
	_text(&"storage", func() -> String: return _inventory_text())
	if is_instance_valid(daily):
		_section(&"storage", "CARGO RESERVES")
		_row(&"storage", "Seeds", func() -> String: return str(daily.seed_stock))
		_row(&"storage", "Dry rations", func() -> String: return str(daily.ration_stock))
		_section(&"storage", "WASTE")
		_row(&"storage", "Loose / sealed", func() -> String: return "%d / %d" % [daily.loose_waste, daily.sealed_waste])
	_note(&"storage", "Cargo reserves are finite deliveries. Collect them at the Cargo station.")

	# Equipment condition
	var listing := UiKit.vbox(1)
	pages[&"equipment"].add_child(listing)
	var states: Dictionary[String, Label] = {}
	for id: String in model.equipment:
		var line := UiKit.hbox(4)
		listing.add_child(line)
		var entry: Button = UiKit.button(model.equipment[id].title, &"ListButton", _select_device.bind(id))
		entry.name = id.to_pascal_case()
		entry.toggle_mode = true
		entry.button_group = _device_group
		entry.focus_mode = Control.FOCUS_NONE
		entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.clip_text = true
		entry.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		entry.tooltip_text = entry.text
		entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(entry)
		device_buttons[id] = entry
		var state: Label = UiKit.label("", &"CaptionLabel")
		state.custom_minimum_size.x = 74
		state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		state.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(state)
		states[id] = state
	_updaters[&"equipment"].append(func() -> void:
		for id: String in device_buttons:
			var item: UtilityEquipment = model.equipment[id]
			# The short state word fits the list; the detail block below gives the full status.
			states[id].text = item.status.split(":")[0].to_upper()
			states[id].add_theme_color_override(&"font_color", UiKit.state_color(self, _device_state(item)))
			device_buttons[id].set_pressed_no_signal(id == selected_device))
	pages[&"equipment"].add_child(UiKit.separator())
	_text(&"equipment", func() -> String: return _device_detail())

	# Maintenance
	_section(&"maintenance", "ATTENTION NEEDED")
	_text(&"maintenance", func() -> Array: return _attention_text())
	_section(&"maintenance", "INSPECTIONS COMPLETED")
	_text(&"maintenance", func() -> String: return _service_text())
	if is_instance_valid(daily):
		_row(&"maintenance", "Workstation upkeep logged", func() -> String: return str(int(daily.completed.get("maintenance", 0))))
	_note(&"maintenance", "Maintenance is started and finished at the Engineering terminals. It is a placeholder routine that uses no parts or resources.")

	# Research
	if is_instance_valid(daily):
		_row(&"research", "Sample examinations recorded", func() -> String: return str(int(daily.completed.get("science", 0))))
	_row(&"research", "Lunar Samples carried", func() -> String: return str(inventory.get_quantity(&"lunar_sample")) if is_instance_valid(inventory) else "0")
	_section(&"research", "EQUIPMENT DATABASE")
	_text(&"research", func() -> String: return _database_text())
	database_button = UiKit.button("Open equipment database", &"PrimaryButton", func() -> void: database_requested.emit())
	database_button.name = "OpenDatabase"
	database_button.focus_mode = Control.FOCUS_NONE
	database_button.disabled = database == null
	pages[&"research"].add_child(database_button)
	_note(&"research", "The database separates operational, demonstrated, in-development and research references. Examination results unlock nothing yet.")

	# Current mission
	_text(&"mission", func() -> String: return _mission_text())
	_section(&"mission", "OBJECTIVES")
	_text(&"mission", func() -> String: return _objective_text(false))
	_section(&"mission", "OPTIONAL")
	_text(&"mission", func() -> String: return _objective_text(true))
	_section(&"mission", "RECENT COMMS")
	_text(&"mission", func() -> String: return _comms_text())


# --- Text helpers ----------------------------------------------------------------------------

func _select_device(id: String) -> void:
	selected_device = id
	refresh()


static func _device_state(item: UtilityEquipment) -> UiKit.State:
	if item.fault:
		return UiKit.State.CRITICAL
	if item.maintenance or not item.enabled or item.status.begins_with("blocked") or item.status == "unpowered":
		return UiKit.State.WARNING
	return UiKit.State.OK if item.powered else UiKit.State.OFFLINE


static func _clock(seconds: float) -> String:
	var total: int = int(seconds)
	@warning_ignore("integer_division")
	return "T+%02d:%02d:%02d" % [total / 3600, (total / 60) % 60, total % 60]


func _alarm_text() -> Array:
	var alarms: PackedStringArray = utilities.model.alarms
	if alarms.is_empty():
		return ["No active alarms.", UiKit.State.OK]
	var names: PackedStringArray = []
	for id: String in alarms:
		names.append("- " + UiKit.humanize(id))
	return ["\n".join(names), UiKit.State.CRITICAL]


func _tray_summary() -> String:
	var counts: Dictionary[String, int] = {}
	for tray: Dictionary in daily.trays:
		var key: String = "ready" if int(tray.remaining_yield) > 0 else "growing" if tray.planted and String(tray.status) == "Growing" else "paused" if tray.planted else "empty"
		counts[key] = int(counts.get(key, 0)) + 1
	var parts: PackedStringArray = []
	for key: String in ["ready", "growing", "paused", "empty"]:
		if counts.has(key):
			parts.append("%d %s" % [counts[key], key])
	return ", ".join(parts)


func _load_list() -> String:
	var ordered: Array[UtilityEquipment] = []
	for item: UtilityEquipment in utilities.model.equipment.values():
		if item.id not in ["solar", "battery", "distribution"]:
			ordered.append(item)
	ordered.sort_custom(func(a: UtilityEquipment, b: UtilityEquipment) -> bool: return a.priority < b.priority or (a.priority == b.priority and a.id < b.id))
	var lines: PackedStringArray = []
	for item: UtilityEquipment in ordered:
		lines.append("%d  %s  %.0f W  %s" % [item.priority, item.title, item.watts, item.status])
	return "\n".join(lines)


func _inventory_text() -> String:
	if not is_instance_valid(inventory):
		return "Inventory unavailable."
	var totals: Dictionary[StringName, int] = {}
	for index: int in inventory.slot_count():
		var slot: Dictionary = inventory.slot_snapshot(index)
		if int(slot.quantity) > 0:
			totals[slot.item_id] = int(totals.get(slot.item_id, 0)) + int(slot.quantity)
	if totals.is_empty():
		return "Nothing carried."
	var lines: PackedStringArray = []
	for id: StringName in totals:
		var item: ItemDefinition = inventory.definition(id)
		lines.append("%s x%d" % [item.display_name if item != null else String(id), totals[id]])
	return "\n".join(lines)


func _device_detail() -> String:
	var item: UtilityEquipment = utilities.model.equipment[selected_device]
	var info: Array = DEVICE_INFO.get(item.id, ["Habitat equipment", "Engineering terminals"])
	var flags: PackedStringArray = []
	flags.append("enabled" if item.enabled else "switched off")
	if item.fault:
		flags.append("fault")
	if item.maintenance:
		flags.append("in maintenance")
	var warnings: PackedStringArray = []
	for alarm: String in utilities.model.alarms:
		if alarm.ends_with("/" + item.id):
			warnings.append(UiKit.humanize(alarm))
	var lines: PackedStringArray = [
		item.title.to_upper(),
		"Category: " + String(info[0]),
		"Status: %s (%s)" % [item.status, ", ".join(flags)],
		"Rated load: %.0f W, priority %d%s" % [item.watts, item.priority, ", critical" if item.critical else ""],
		"Runtime: %s, inspections: %d" % [_clock(item.runtime_s), item.service_count],
		"Resources: " + _device_resources(item.id),
		"Operate at: " + String(info[1]),
		"Available there: toggle power, start maintenance, finish inspection.",
		"Warnings: " + (", ".join(warnings) if not warnings.is_empty() else "none"),
	]
	return "\n".join(lines)


func _device_resources(id: String) -> String:
	var model: UtilityModel = utilities.model
	match id:
		"solar":
			return "%.0f W generating" % model.last_power.generation_w
		"battery":
			return "%.0f Wh stored" % model.battery_wh
		"distribution":
			return "%.0f W delivered" % model.last_power.load_w
		"oxygen_supply":
			return "%.2f kg stored oxygen" % model.resources.oxygen_store_kg
		"co2_removal":
			return "%.3f kg captured CO2" % model.resources.captured_co2_kg
		"water_treatment":
			return "%.1f kg potable, %.1f kg wastewater" % [model.resources.potable_kg, model.resources.wastewater_kg]
		"dehumidifier":
			return "%.1f g/m3 cabin humidity" % model.humidity_g_m3()
		"heating", "thermal_control":
			return "%.1f C cabin" % (model.temperature_k() - 273.15)
		"ventilation":
			return "%.1f kPa cabin pressure" % (model.pressure_pa() / 1000.0)
		"greenhouse_lights":
			return _tray_summary() if is_instance_valid(daily) else "no tray data"
	return "habitat electronics bus"


func _attention_text() -> Array:
	var lines: PackedStringArray = []
	for item: UtilityEquipment in utilities.model.equipment.values():
		if item.fault or item.maintenance or not item.enabled:
			lines.append("- %s: %s" % [item.title, "fault" if item.fault else "in maintenance" if item.maintenance else "switched off"])
	if lines.is_empty():
		return ["All equipment is available.", UiKit.State.OK]
	return ["\n".join(lines), UiKit.State.WARNING]


func _service_text() -> String:
	var lines: PackedStringArray = []
	for item: UtilityEquipment in utilities.model.equipment.values():
		if item.service_count > 0:
			lines.append("%s: %d" % [item.title, item.service_count])
	return "\n".join(lines) if not lines.is_empty() else "None recorded this session."


func _database_text() -> String:
	if database == null:
		return "Equipment database unavailable."
	var counts: Dictionary[StringName, int] = database.count_by_status()
	var lines: PackedStringArray = ["%d reference entries" % database.records.size()]
	for status: StringName in EquipmentRecord.STATUSES:
		lines.append("%s: %d" % [EquipmentDatabase.STATUS_TITLES[status], counts[status]])
	return "\n".join(lines)


func _mission_text() -> String:
	if not is_instance_valid(tracker) or tracker.mission == null:
		return "No active mission."
	var progress: Vector2i = tracker.progress()
	return "%s\n%s\nProgress: %d of %d%s" % [tracker.mission.title.to_upper(), tracker.mission.summary, progress.x, progress.y,
		"  (complete)" if tracker.mission_complete else ""]


func _objective_text(optional: bool) -> String:
	if not is_instance_valid(tracker) or tracker.mission == null:
		return "-"
	var entries: Array[ObjectiveDefinition] = tracker.mission.optional_tasks if optional else tracker.mission.objectives
	var active: ObjectiveDefinition = tracker.active_objective()
	var lines: PackedStringArray = []
	for entry: ObjectiveDefinition in entries:
		var mark: String = "[x]" if tracker.is_complete(entry.objective_id) else "[>]" if entry == active else "[ ]"
		lines.append("%s %s" % [mark, entry.title])
	return "\n".join(lines) if not lines.is_empty() else "None."


func _comms_text() -> String:
	if not is_instance_valid(dialogue) or dialogue.history.is_empty():
		return "No messages yet."
	var lines: PackedStringArray = []
	for index: int in range(dialogue.history.size() - 1, maxi(-1, dialogue.history.size() - 4), -1):
		lines.append("- " + String(dialogue.history[index].text))
	return "\n".join(lines)
