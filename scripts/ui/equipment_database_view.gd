class_name EquipmentDatabaseView
extends HBoxContainer
## Reference browser for the generated equipment database. Text is shown exactly as recorded:
## evidence class first, then function, test setting, known limits and the game abstraction.

const FILTERS: Array[StringName] = [&"", &"operational", &"demonstrated", &"in_development", &"research"]
const STATUS_STATES: Dictionary[StringName, UiKit.State] = {
	&"operational": UiKit.State.OK, &"demonstrated": UiKit.State.NOMINAL,
	&"in_development": UiKit.State.WARNING, &"research": UiKit.State.OFFLINE,
}

var database: EquipmentDatabase
var filter: OptionButton
var list: VBoxContainer
var count_label: Label
var record_name: Label
var record_status: Label
var record_status_note: Label
var record_category: Label
var record_function: Label
var record_testing: Label
var record_limits: Label
var record_usage: Label
var record_source: Label
var footer: Label
var selected_id: StringName = &""
var _group := ButtonGroup.new()
var _detail: VBoxContainer


func _init() -> void:
	name = "EquipmentDatabase"
	add_theme_constant_override(&"separation", 10)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var left := UiKit.vbox(4)
	left.custom_minimum_size.x = 176
	add_child(left)
	filter = OptionButton.new()
	filter.name = "Filter"
	filter.add_item("All classes")
	for status: StringName in EquipmentRecord.STATUSES:
		filter.add_item(EquipmentDatabase.STATUS_TITLES[status])
	filter.item_selected.connect(func(_index: int) -> void: _rebuild_list())
	left.add_child(filter)
	count_label = UiKit.label("", &"CaptionLabel")
	left.add_child(count_label)
	var list_scroll: ScrollContainer = UiKit.scroll(Vector2(176, 120))
	left.add_child(list_scroll)
	list = UiKit.vbox(1)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(list)
	var detail_scroll: ScrollContainer = UiKit.scroll(Vector2(220, 120))
	add_child(detail_scroll)
	_detail = UiKit.vbox(4)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(_detail)
	record_name = UiKit.wrapped("", &"AccentLabel", 200)
	record_name.name = "RecordName"
	_detail.add_child(record_name)
	record_status = UiKit.label("", &"SectionLabel")
	record_status.name = "RecordStatus"
	_detail.add_child(record_status)
	record_status_note = UiKit.wrapped("", &"MutedLabel", 200)
	_detail.add_child(record_status_note)
	record_category = UiKit.wrapped("", &"CaptionLabel", 200)
	_detail.add_child(record_category)
	record_function = _block("FUNCTION")
	record_testing = _block("WHERE IT HAS BEEN USED OR TESTED")
	record_limits = _block("KNOWN LIMITATIONS")
	_detail.add_child(UiKit.label("IN THIS GAME", &"SectionLabel"))
	var usage_panel: PanelContainer = UiKit.panel(&"InsetPanel")
	_detail.add_child(usage_panel)
	record_usage = UiKit.wrapped("", &"", 190)
	record_usage.name = "RecordUsage"
	usage_panel.add_child(record_usage)
	record_source = _block("SOURCE")
	footer = UiKit.wrapped("", &"CaptionLabel", 200)
	footer.name = "Footer"
	_detail.add_child(footer)


func bind(source: EquipmentDatabase) -> void:
	database = source
	_rebuild_list()


func select(research_id: StringName) -> bool:
	if database == null or database.find(research_id) == null:
		return false
	selected_id = research_id
	_sync_selection()
	_show(database.find(research_id))
	return true


func _block(caption: String) -> Label:
	_detail.add_child(UiKit.label(caption, &"SectionLabel"))
	var body: Label = UiKit.wrapped("", &"SecondaryLabel", 200)
	_detail.add_child(body)
	return body


func _rebuild_list() -> void:
	for child: Node in list.get_children():
		list.remove_child(child)
		child.queue_free()
	if database == null:
		count_label.text = "DATABASE UNAVAILABLE"
		_show(null)
		return
	var status: StringName = FILTERS[clampi(filter.selected, 0, FILTERS.size() - 1)]
	var records: Array[EquipmentRecord] = database.with_status(status)
	count_label.text = "%d OF %d ENTRIES" % [records.size(), database.records.size()]
	var keep: EquipmentRecord = null
	for record: EquipmentRecord in records:
		var entry: Button = UiKit.button(record.official_name, &"ListButton", _pick.bind(record.research_id))
		entry.toggle_mode = true
		entry.button_group = _group
		entry.alignment = HORIZONTAL_ALIGNMENT_LEFT
		entry.clip_text = true
		entry.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		entry.tooltip_text = record.official_name
		entry.set_meta(&"research_id", record.research_id)
		list.add_child(entry)
		if record.research_id == selected_id:
			keep = record
	if keep == null and not records.is_empty():
		keep = records[0]
	selected_id = keep.research_id if keep != null else &""
	_sync_selection()
	_show(keep)


func _pick(research_id: StringName) -> void:
	selected_id = research_id
	_sync_selection()
	_show(database.find(research_id))


func _sync_selection() -> void:
	for child: Node in list.get_children():
		if child is Button and not child.is_queued_for_deletion():
			(child as Button).set_pressed_no_signal(child.get_meta(&"research_id", &"") == selected_id)


func _show(record: EquipmentRecord) -> void:
	_detail.visible = record != null
	if record == null:
		return
	record_name.text = record.official_name
	record_status.text = EquipmentDatabase.STATUS_TITLES[record.evidence_status].to_upper()
	record_status.add_theme_color_override(&"font_color", UiKit.state_color(self, STATUS_STATES[record.evidence_status]))
	record_status_note.text = EquipmentDatabase.STATUS_NOTES[record.evidence_status]
	record_category.text = record.category.to_upper()
	record_function.text = record.actual_function
	record_testing.text = record.testing_environment
	var limits: PackedStringArray = []
	for limit: String in record.limitations:
		limits.append("- " + limit)
	record_limits.text = "\n".join(limits) if not limits.is_empty() else "None recorded."
	record_usage.text = record.game_usage
	record_source.text = "%s\n%s\n%s" % [record.source_organization, record.reference_url, record.research_id]
	footer.text = "Registry %s, reviewed through %s. Reference only: no game value is derived from these entries, and NASA does not endorse this game." % [
		database.catalog_version, database.reviewed_through]
