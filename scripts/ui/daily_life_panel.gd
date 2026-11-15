class_name DailyLifePanel
extends PanelContainer
var model: DailyLife
var session: PlayerSession
var station: String
var text: Label
var commands: HBoxContainer
var tray: OptionButton


func configure(source: DailyLife, gate: PlayerSession) -> void:
	model = source
	session = gate
	theme = load("res://resources/ui/development_theme.tres")
	position = Vector2(100, 80)
	size = Vector2(760, 390)
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color.a = 1
	add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	add_child(box)
	text = Label.new()
	text.add_theme_font_size_override("font_size", 14)
	text.custom_minimum_size = Vector2(720, 240)
	box.add_child(text)
	tray = OptionButton.new()
	for i: int in model.trays.size(): tray.add_item("Growing tray %d" % (i+1))
	tray.item_selected.connect(func(_index: int) -> void: refresh())
	box.add_child(tray)
	commands = HBoxContainer.new()
	box.add_child(commands)
	var close := Button.new()
	close.text = "Close [Esc]"
	close.pressed.connect(close_panel)
	box.add_child(close)
	model.changed.connect(refresh)
	hide()


func open_panel(id: String) -> void:
	station = id
	for child: Node in commands.get_children():
		commands.remove_child(child)
		child.queue_free()
	var choices: Dictionary = {
		"cargo":[["Collect supplies","resupply"]],
		"greenhouse":[["Plant seed","plant"],["Toggle light","light"],["Harvest","harvest"]],
		"galley":[["Prepare ration","prepare_food"],["Prepare greens","prepare_greens"],["Drink water","drink"]],
		"hygiene":[["Wash","hygiene"],["Seal waste","dispose"]],
		"sleep":[["Rest","sleep"]], "exercise":[["Exercise","exercise"]],
		"medical":[["Inspect","medical"]], "operations":[["Maintain workstation","maintenance"]],
		"science":[["Examine sample","science"]]}
	for pair: Array in choices.get(id, []):
		var button := Button.new()
		button.text = pair[0]
		var action: String = pair[1]
		button.pressed.connect(func() -> void:
			match action:
				"plant": model.plant(tray.selected)
				"harvest": model.harvest(tray.selected)
				"light":
					model.trays[tray.selected].light = not model.trays[tray.selected].light
					model.changed.emit()
				_: model.act(action)
		)
		commands.add_child(button)
	tray.visible = id == "greenhouse"
	session.set_inspection_blocked(true)
	show()
	refresh()


func close_panel() -> void:
	if not model.job.is_empty():
		model.job = {}
		model.message = "Activity interrupted. Allocated water is not refunded."
	hide()
	var focus: Control = get_viewport().gui_get_focus_owner()
	if focus != null and is_ancestor_of(focus): focus.release_focus()
	session.set_inspection_blocked(false)


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("game_pause") and not event.is_echo():
		close_panel()
		get_viewport().set_input_as_handled()


func refresh() -> void:
	if not visible: return
	var lines: PackedStringArray = [station.to_upper(), model.message]
	lines.append("Cargo reserves: %d seeds | %d dry rations" % [model.seed_stock, model.ration_stock])
	if station == "greenhouse":
		for i: int in model.trays.size():
			var t: Dictionary = model.trays[i]
			lines.append("Tray %d | %s | %.1f%% | light %s | yield %d" % [i+1,t.status,100*float(t.growth_s)/float(model.settings.crop.growth_s),t.light,t.remaining_yield])
		lines.append("Seeds: %d | nutrients: %.2f units | water: %.3f kg" % [model.inventory.get_quantity(&"greens_seed"),model.nutrients,model.utilities.model.resources.potable_kg])
		lines.append("Research crop: leafy greens. Supplemental portions; no oxygen credit.")
		lines.append("Growth multiplier: %.0fx (development setting)" % model.development_growth_multiplier)
	lines.append("Active activity: " + ("none" if model.job.is_empty() else "%s (%.0f s)" % [model.job.id,model.job.remaining_s]))
	lines.append("Loose waste: %d | sealed waste: %d" % [model.loose_waste,model.sealed_waste])
	text.text = "\n".join(lines)

