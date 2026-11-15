class_name DailyLifePanel
extends MissionPanel
## Station window for cargo, greenhouse and routine activities. DailyLife owns all state;
## buttons forward its existing commands and closing interrupts an unfinished activity.

const DESIGN_SIZE: Vector2 = Vector2(600, 320)
const STATIONS: Dictionary[String, Array] = {
	"cargo": ["CARGO / SPARES", &"supply_tool"], "greenhouse": ["GREENHOUSE", &"greenhouse"],
	"galley": ["GALLEY", &"prepared_meal"], "hygiene": ["HYGIENE / WASTE", &"water"],
	"sleep": ["SLEEPING QUARTERS", &"sleep"], "exercise": ["EXERCISE", &"cardiac"],
	"medical": ["MEDICAL MONITORING", &"health"], "operations": ["MISSION OPERATIONS", &"gear"],
	"science": ["SCIENCE LAB", &"research"],
}
const COMMANDS: Dictionary[String, Array] = {
	"cargo": [["Collect supplies", "resupply"]],
	"greenhouse": [["Plant seed", "plant"], ["Toggle light", "light"], ["Harvest", "harvest"]],
	"galley": [["Prepare ration", "prepare_food"], ["Prepare greens", "prepare_greens"], ["Drink water", "drink"]],
	"hygiene": [["Wash", "hygiene"], ["Seal waste", "dispose"]],
	"sleep": [["Rest", "sleep"]], "exercise": [["Exercise", "exercise"]],
	"medical": [["Inspect", "medical"]], "operations": [["Maintain workstation", "maintenance"]],
	"science": [["Examine sample", "science"]],
}

var model: DailyLife
var session: PlayerSession
var station: String
var title: Label
var message: Label
var text: Label
var commands: HBoxContainer
var tray: OptionButton
var activity_bar: ProgressBar
var activity_label: Label
var _icon_holder: Control
var _close: Button


func configure(source: DailyLife, gate: PlayerSession) -> void:
	model = source
	session = gate
	name = "DailyLifePanel"
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = DESIGN_SIZE
	var box := UiKit.vbox(6)
	add_child(box)
	var header := UiKit.hbox(8)
	box.add_child(header)
	_icon_holder = Control.new()
	_icon_holder.custom_minimum_size = Vector2(22, 22)
	_icon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_icon_holder)
	title = UiKit.label("", &"WindowTitleLabel")
	title.name = "Title"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(title)
	_close = UiKit.button("Close [Esc]", &"", close_panel)
	_close.name = "Close"
	header.add_child(_close)
	var notice: PanelContainer = UiKit.panel(&"InsetPanel")
	box.add_child(notice)
	message = UiKit.wrapped("", &"AccentLabel", 540)
	message.name = "Message"
	notice.add_child(message)
	var scroll: ScrollContainer = UiKit.scroll(Vector2(0, 110))
	box.add_child(scroll)
	text = UiKit.wrapped("", &"SecondaryLabel", 540)
	text.name = "Status"
	scroll.add_child(text)
	var activity := UiKit.hbox(8)
	box.add_child(activity)
	activity_label = UiKit.label("", &"CaptionLabel")
	activity_label.custom_minimum_size.x = 200
	activity_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	activity.add_child(activity_label)
	activity_bar = UiKit.gauge(UiKit.State.NOMINAL, 120)
	activity.add_child(activity_bar)
	tray = OptionButton.new()
	tray.custom_minimum_size.x = 160
	tray.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	for i: int in model.trays.size():
		tray.add_item("Growing tray %d" % (i + 1))
	tray.item_selected.connect(func(_index: int) -> void: refresh())
	box.add_child(tray)
	commands = UiKit.hbox(6)
	commands.name = "Commands"
	box.add_child(commands)
	model.changed.connect(refresh)
	hide()


func open_panel(id: String) -> void:
	station = id
	for child: Node in commands.get_children():
		commands.remove_child(child)
		child.queue_free()
	for child: Node in _icon_holder.get_children():
		_icon_holder.remove_child(child)
		child.queue_free()
	var presentation: Array = STATIONS.get(id, [id.to_upper(), &"gear"])
	title.text = presentation[0]
	if UiIcons.has_icon(presentation[1]):
		_icon_holder.add_child(UiKit.compact_icon(presentation[1], 22))
	for pair: Array in COMMANDS.get(id, []):
		var action: String = pair[1]
		commands.add_child(UiKit.button(pair[0], &"", func() -> void:
			match action:
				"plant": model.plant(tray.selected)
				"harvest": model.harvest(tray.selected)
				"light":
					model.trays[tray.selected].light = not model.trays[tray.selected].light
					model.changed.emit()
				_: model.act(action)
		))
	tray.visible = id == "greenhouse"
	session.set_inspection_blocked(true)
	show()
	UiKit.center_modal(self, DESIGN_SIZE)
	refresh()
	UiMotion.fade_in(self, UiMotion.FAST)


func close_panel() -> void:
	if not model.job.is_empty():
		model.job = {}
		model.message = "Activity interrupted. Allocated water is not refunded."
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
	if not visible:
		return
	message.text = model.message
	var lines: PackedStringArray = []
	lines.append("Cargo reserves: %d seeds | %d dry rations" % [model.seed_stock, model.ration_stock])
	if station == "greenhouse":
		for i: int in model.trays.size():
			var t: Dictionary = model.trays[i]
			lines.append("Tray %d | %s | %.1f%% | light %s | yield %d" % [i + 1, t.status, 100 * float(t.growth_s) / float(model.settings.crop.growth_s), "on" if t.light else "off", t.remaining_yield])
		lines.append("Seeds: %d | nutrients: %.2f units | water: %.3f kg" % [model.inventory.get_quantity(&"greens_seed"), model.nutrients, model.utilities.model.resources.potable_kg])
		lines.append("Research crop: leafy greens. Supplemental portions; no oxygen credit.")
		if not is_equal_approx(model.development_growth_multiplier, 1.0):
			lines.append("Growth multiplier: %.0fx (development setting)" % model.development_growth_multiplier)
	lines.append("Loose waste: %d | sealed waste: %d" % [model.loose_waste, model.sealed_waste])
	text.text = "\n".join(lines)
	if model.job.is_empty():
		activity_label.text = "ACTIVE ACTIVITY: NONE"
		activity_bar.value = 0
	else:
		var total: float = float(model.settings.activities[model.job.id].duration_s)
		activity_label.text = "ACTIVE: %s (%.0f s LEFT)" % [String(model.job.id).to_upper(), model.job.remaining_s]
		activity_bar.max_value = maxf(0.001, total)
		activity_bar.value = total - float(model.job.remaining_s)
