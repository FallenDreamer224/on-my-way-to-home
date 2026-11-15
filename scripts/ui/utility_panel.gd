class_name UtilityPanel
extends MissionPanel
## Engineering terminal. The utility model owns every quantity; this window presents model
## signals and forwards the existing equipment commands. Fault and sunlight scenario controls
## are development tools and stay hidden outside development builds.

const DESIGN_SIZE: Vector2 = Vector2(664, 344)

var service: UtilityService
var session: PlayerSession
var development_controls: bool = false
var _values: Label
var _equipment: Label
var _alarms: Label
var _alarm_banner: PanelContainer
var _alarm_view: ScrollContainer
var _selection: OptionButton
var _close: Button
var _battery: ProgressBar
var _oxygen: ProgressBar
var _water: ProgressBar
var _battery_value: Label
var _oxygen_value: Label
var _water_value: Label
var _development_row: HBoxContainer


func configure(source: UtilityService, player_session: PlayerSession, show_development_controls: bool = OS.is_debug_build()) -> void:
	service = source
	session = player_session
	development_controls = show_development_controls
	service.model.changed.connect(refresh)
	name = "UtilityPanel"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = DESIGN_SIZE
	var content := UiKit.vbox(5)
	add_child(content)
	var header: HBoxContainer = UiKit.window_header("HABITAT UTILITIES", &"gear", "Close [Esc]", close_panel)
	_close = header.get_node("Close")
	content.add_child(header)
	content.add_child(UiKit.label("Tutorial model state and estimates. Not NASA ratings or medical limits.", &"CaptionLabel"))
	var gauges := UiKit.hbox(12)
	content.add_child(gauges)
	var battery: Array = _summary_gauge(gauges, &"battery", "BATTERY")
	_battery = battery[0]
	_battery_value = battery[1]
	var oxygen: Array = _summary_gauge(gauges, &"oxygen", "STORED OXYGEN")
	_oxygen = oxygen[0]
	_oxygen_value = oxygen[1]
	var water: Array = _summary_gauge(gauges, &"water", "POTABLE WATER")
	_water = water[0]
	_water_value = water[1]
	_alarm_banner = UiKit.panel(&"OkBanner")
	content.add_child(_alarm_banner)
	_alarm_view = UiKit.scroll(Vector2(0, 13))
	_alarm_view.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_alarm_banner.add_child(_alarm_view)
	_alarms = UiKit.wrapped("", &"", 560)
	_alarm_view.add_child(_alarms)
	var readings: ScrollContainer = UiKit.scroll(Vector2(0, 96))
	# A larger interface scale narrows the window; the full readout stays reachable.
	readings.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(readings)
	var columns := UiKit.hbox(18)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	readings.add_child(columns)
	_values = UiKit.label("", &"SecondaryLabel")
	_values.custom_minimum_size.x = 296
	columns.add_child(_values)
	_equipment = UiKit.label("", &"SecondaryLabel")
	columns.add_child(_equipment)
	var command_row := UiKit.hbox(6)
	content.add_child(command_row)
	_selection = OptionButton.new()
	_selection.custom_minimum_size.x = 190
	for id: String in service.model.equipment:
		_selection.add_item(service.model.equipment[id].title)
		_selection.set_item_metadata(_selection.item_count - 1, id)
	_selection.item_selected.connect(func(_index: int) -> void: refresh())
	command_row.add_child(_selection)
	for pair: Array in [["Toggle power", "toggle"], ["Start maintenance", "maintain"], ["Finish inspection", "complete"]]:
		command_row.add_child(_command_button(pair[0], pair[1]))
	_development_row = UiKit.hbox(6)
	_development_row.visible = development_controls
	content.add_child(_development_row)
	var tag: Label = UiKit.label("DEVELOPMENT SCENARIO", &"CaptionLabel")
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_development_row.add_child(tag)
	_development_row.add_child(_command_button("Test fault", "fault"))
	var sunlight: Button = UiKit.button("Sunlight 100% / 0%", &"", func() -> void:
		service.model.set_solar_fraction(0 if service.model.solar_fraction > 0 else 1))
	_development_row.add_child(sunlight)
	hide()


func open_panel(focus_id: String = "ventilation") -> void:
	for index: int in _selection.item_count:
		if _selection.get_item_metadata(index) == focus_id:
			_selection.select(index)
	session.set_inspection_blocked(true)
	show()
	UiKit.center_modal(self, DESIGN_SIZE)
	refresh()
	UiMotion.fade_in(self, UiMotion.FAST)
	_close.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	UiMotion.stop(self)
	hide()
	var focus: Control = get_viewport().gui_get_focus_owner()
	if focus != null and is_ancestor_of(focus):
		focus.release_focus()
	session.set_inspection_blocked(false)


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("game_pause") and not event.is_echo():
		close_panel()
		get_viewport().set_input_as_handled()


func refresh() -> void:
	if not visible or service == null:
		return
	var model: UtilityModel = service.model
	var r: Dictionary[String, float] = model.resources
	var capacity: Dictionary = model.config.data.capacities_kg
	_set_gauge(_battery, _battery_value, model.battery_wh, float(model.config.data.battery_capacity_wh), "%.0f Wh" % model.battery_wh, "battery_reserve_low" in model.alarms)
	_set_gauge(_oxygen, _oxygen_value, r.oxygen_store_kg, float(capacity.oxygen_store_kg), "%.2f kg" % r.oxygen_store_kg, "stored_oxygen_low" in model.alarms)
	_set_gauge(_water, _water_value, r.potable_kg, float(capacity.potable_kg), "%.1f kg" % r.potable_kg, "potable_water_low" in model.alarms)
	_values.text = ("MODEL STATE: t=%.0f s\nBattery: %.2f / %.0f Wh\nLast step: solar %.0f W | load %.0f W\nBattery net: %+.0f W | source: %.0f%%\nOxygen store: %.4f kg\nPotable: %.4f kg | wastewater: %.4f kg\nReject water: %.4f kg\nCabin O2: %.4f kg | N2: %.4f kg\nCabin CO2: %.5f kg | captured: %.5f kg\nSurrogate carbon feed: %.5f kg\n\nMODEL ESTIMATES\nCabin pressure: %.2f kPa | O2: %.2f kPa\nCabin CO2: %.1f Pa\nVapor: %.4f kg / %.2f g/m3\nTemperature: %.2f C" % [
		model.elapsed_s, model.battery_wh, model.config.data.battery_capacity_wh, model.last_power.generation_w,
		model.last_power.load_w, model.last_power.battery_w, model.solar_fraction * 100,
		r.oxygen_store_kg, r.potable_kg, r.wastewater_kg, r.reject_kg, r.cabin_o2_kg, r.cabin_n2_kg, r.cabin_co2_kg, r.captured_co2_kg, r.carbon_feed_kg,
		model.pressure_pa()/1000, model.partial_pressure_pa("cabin_o2_kg")/1000,
		model.partial_pressure_pa("cabin_co2_kg"), r.cabin_vapor_kg, model.humidity_g_m3(), model.temperature_k()-273.15])
	var lines: PackedStringArray = ["EQUIPMENT / MODEL STATUS"]
	for device: UtilityEquipment in model.equipment.values():
		lines.append(device.title + ": " + device.status)
	var selected: UtilityEquipment = model.equipment[String(_selection.get_item_metadata(_selection.selected))]
	lines.append("\nSelected runtime: %.1f s | inspections: %d" % [selected.runtime_s, selected.service_count])
	_equipment.text = "\n".join(lines)
	_alarms.text = "ALARMS: none" if model.alarms.is_empty() else "ALARMS: " + ", ".join(model.alarms).replace("_", " ").replace("/", ": ")
	_alarm_banner.theme_type_variation = &"OkBanner" if model.alarms.is_empty() else &"CriticalBanner"
	# One line while nominal; two scrollable lines when alarms need room.
	_alarm_view.custom_minimum_size.y = 13 if model.alarms.is_empty() else 28


func _command_button(caption: String, command: String) -> Button:
	return UiKit.button(caption, &"", func() -> void:
		service.model.equipment_command(String(_selection.get_item_metadata(_selection.selected)), command))


func _summary_gauge(parent: HBoxContainer, icon_name: StringName, caption: String) -> Array:
	var cell := UiKit.hbox(6)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(cell)
	cell.add_child(UiKit.compact_icon(icon_name, 20))
	var column := UiKit.vbox(1)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.add_child(column)
	var heading := UiKit.hbox(4)
	column.add_child(heading)
	var title: Label = UiKit.label(caption, &"CaptionLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	var value: Label = UiKit.label("", &"CaptionAccentLabel")
	heading.add_child(value)
	var bar: ProgressBar = UiKit.gauge()
	column.add_child(bar)
	return [bar, value]


static func _set_gauge(bar: ProgressBar, value: Label, amount: float, maximum: float, text: String, alarm: bool) -> void:
	bar.max_value = maxf(0.0001, maximum)
	bar.value = clampf(amount, 0.0, bar.max_value)
	bar.theme_type_variation = UiKit.STATE_GAUGES[UiKit.State.WARNING if alarm else UiKit.State.NOMINAL]
	value.text = text
