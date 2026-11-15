class_name UtilityPanel
extends PanelContainer
## Text-only modal; model owns all quantities. Updates from model signals, not UI polling.

var service: UtilityService
var session: PlayerSession
var _values: Label
var _equipment: Label
var _alarms: Label
var _selection: OptionButton
var _close: Button


func configure(source: UtilityService, player_session: PlayerSession) -> void:
	service = source
	session = player_session
	service.model.changed.connect(refresh)
	theme = load("res://resources/ui/development_theme.tres")
	var panel_style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel_style.bg_color.a = 1.0
	add_theme_stylebox_override("panel", panel_style)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	position = Vector2(100, 44)
	size = Vector2(760, 452)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	add_child(content)
	var title := Label.new()
	title.text = "HABITAT UTILITIES"
	content.add_child(title)
	var note := Label.new()
	note.text = "Tutorial model state / estimates. Scroll readings and alarms for more."
	note.add_theme_font_size_override("font_size", 12)
	content.add_child(note)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	var readings := ScrollContainer.new()
	readings.custom_minimum_size = Vector2(720, 180)
	readings.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(readings)
	readings.add_child(columns)
	_values = Label.new()
	_values.add_theme_font_size_override("font_size", 12)
	_values.custom_minimum_size.x = 310
	columns.add_child(_values)
	_equipment = Label.new()
	_equipment.add_theme_font_size_override("font_size", 12)
	columns.add_child(_equipment)
	_alarms = Label.new()
	_alarms.add_theme_font_size_override("font_size", 12)
	_alarms.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_alarms.custom_minimum_size.x = 700
	_alarms.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var alarm_view := ScrollContainer.new()
	alarm_view.custom_minimum_size = Vector2(720, 48)
	content.add_child(alarm_view)
	alarm_view.add_child(_alarms)
	_selection = OptionButton.new()
	for id: String in service.model.equipment:
		_selection.add_item(service.model.equipment[id].title)
		_selection.set_item_metadata(_selection.item_count - 1, id)
	_selection.item_selected.connect(func(_index: int) -> void: refresh())
	content.add_child(_selection)
	var buttons := HBoxContainer.new()
	content.add_child(buttons)
	for pair: Array in [["Toggle power", "toggle"], ["Test fault", "fault"], ["Start maintenance", "maintain"], ["Finish inspection", "complete"]]:
		var button := Button.new()
		button.text = pair[0]
		var command: String = pair[1]
		button.pressed.connect(func() -> void: service.model.equipment_command(String(_selection.get_item_metadata(_selection.selected)), command))
		buttons.add_child(button)
	var sunlight := Button.new()
	sunlight.text = "Sunlight 100% / 0%"
	sunlight.pressed.connect(func() -> void: service.model.set_solar_fraction(0 if service.model.solar_fraction > 0 else 1))
	buttons.add_child(sunlight)
	_close = Button.new()
	_close.text = "Close [Esc]"
	_close.pressed.connect(close_panel)
	content.add_child(_close)
	hide()


func open_panel(focus_id: String = "ventilation") -> void:
	for index: int in _selection.item_count:
		if _selection.get_item_metadata(index) == focus_id:
			_selection.select(index)
	session.set_inspection_blocked(true)
	show()
	refresh()
	_close.grab_focus()


func close_panel() -> void:
	if not visible:
		return
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
