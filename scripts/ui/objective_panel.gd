class_name ObjectivePanel
extends PanelContainer
## Mission card: current mission, active objective, guidance, progress and optional tasks.
## Reads an ObjectiveTracker; owns no progress itself.

var tracker: ObjectiveTracker
var mission_title: Label
var objective_title: Label
var guidance: Label
var progress_label: Label
var optional_label: Label
var _pips: HBoxContainer
var _marker: Control


func _init() -> void:
	name = "Objectives"
	theme_type_variation = &"NoticePanel"
	custom_minimum_size.x = 252
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var column := UiKit.vbox(3)
	add_child(column)
	var header := UiKit.hbox(6)
	column.add_child(header)
	_marker = UiKit.compact_icon(&"mission", 20)
	header.add_child(_marker)
	var titles := UiKit.vbox(0)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	titles.add_child(UiKit.label("CURRENT MISSION", &"CaptionLabel"))
	mission_title = UiKit.label("", &"SectionLabel")
	mission_title.name = "MissionTitle"
	titles.add_child(mission_title)
	objective_title = UiKit.wrapped("", &"", 220)
	objective_title.name = "ObjectiveTitle"
	column.add_child(objective_title)
	guidance = UiKit.wrapped("", &"MutedLabel", 220)
	guidance.name = "Guidance"
	column.add_child(guidance)
	var footer := UiKit.hbox(6)
	column.add_child(footer)
	_pips = UiKit.hbox(3)
	_pips.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer.add_child(_pips)
	progress_label = UiKit.label("", &"CaptionAccentLabel")
	progress_label.name = "Progress"
	footer.add_child(progress_label)
	footer.add_child(UiKit.spacer())
	optional_label = UiKit.label("", &"CaptionLabel")
	optional_label.name = "Optional"
	footer.add_child(optional_label)
	UiKit.make_passive(self)
	refresh()


func bind(source: ObjectiveTracker) -> void:
	tracker = source
	if is_instance_valid(tracker):
		tracker.changed.connect(_tracker_changed)
	refresh()


func refresh() -> void:
	if not is_instance_valid(tracker) or tracker.mission == null:
		mission_title.text = "NO ACTIVE MISSION"
		objective_title.text = "Explore the landing site."
		guidance.text = ""
		guidance.hide()
		progress_label.text = ""
		optional_label.text = ""
		_set_pips(0, 0)
		return
	mission_title.text = tracker.mission.title.to_upper()
	var active: ObjectiveDefinition = tracker.active_objective()
	var progress: Vector2i = tracker.progress()
	if active == null:
		objective_title.text = "All tutorial objectives recorded."
		objective_title.theme_type_variation = &"OkLabel"
		guidance.text = "Keep exploring the outpost; the session continues."
	else:
		objective_title.text = active.title
		objective_title.theme_type_variation = &""
		guidance.text = active.guidance
	guidance.visible = not guidance.text.is_empty()
	progress_label.text = "%d / %d" % [progress.x, progress.y]
	var optional: Vector2i = tracker.optional_progress()
	optional_label.text = "OPTIONAL %d / %d" % [optional.x, optional.y] if optional.y > 0 else ""
	_set_pips(progress.x, progress.y)


func _tracker_changed() -> void:
	refresh()
	UiMotion.flash(self, Color(1.4, 1.4, 1.4))


func _set_pips(done: int, total: int) -> void:
	while _pips.get_child_count() > total:
		var extra: Node = _pips.get_child(_pips.get_child_count() - 1)
		_pips.remove_child(extra)
		extra.free()
	while _pips.get_child_count() < total:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(10, 4)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pips.add_child(pip)
	for index: int in _pips.get_child_count():
		(_pips.get_child(index) as ColorRect).color = UiKit.color(self, &"ok" if index < done else &"divider")


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and _pips != null and is_instance_valid(tracker):
		var progress: Vector2i = tracker.progress()
		_set_pips(progress.x, progress.y)
