class_name SystemMenu
extends Control
## Mission menu opened with the pause action: controls reference, settings, companion log
## and the equipment database. The owner pauses and resumes the session around it.

signal close_requested
signal return_to_menu_requested
signal quit_requested

const DESIGN_SIZE: Vector2 = Vector2(620, 344)
const PAGES: Array[Array] = [
	[&"overview", "Mission menu"], [&"settings", "Settings"],
	[&"comms", "Comms log"], [&"database", "Equipment database"],
]
const CONTROL_ROWS: Array[Array] = [
	[&"player_move_up", "Move / pan (with left, down, right)"], [&"interact_primary", "Interact with the nearest object"],
	[&"inventory_toggle", "Open or close the inventory"], [&"mode_switch", "Switch Player / Base Management view"],
	[&"hud_details", "Show or hide status details"], [&"dialogue_advance", "Dismiss a companion message"],
	[&"dashboard_previous", "Previous dashboard category"], [&"dashboard_next", "Next dashboard category"],
	[&"game_pause", "Close a panel / open this menu"],
]

var window: MissionPanel
var title: Label
var settings_panel: SettingsPanel
var comms_view: CommsLogView
var database_view: EquipmentDatabaseView
var confirm: ConfirmDialog
var resume_button: Button
var return_button: Button
var quit_button: Button
var page_buttons: Dictionary[StringName, Button] = {}
var pages: Dictionary[StringName, Control] = {}
var current_page: StringName = &"overview"
## Offered only when a host scene (the application root) can show the main menu.
var allow_return: bool = false:
	set(value):
		allow_return = value
		if return_button != null:
			return_button.visible = value
var _hints: Array[KeyHint] = []
var _group := ButtonGroup.new()


func _init() -> void:
	name = "SystemMenu"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	window = MissionPanel.new()
	window.name = "Window"
	add_child(window)
	var column := UiKit.vbox(8)
	window.add_child(column)
	var header: HBoxContainer = UiKit.window_header("MISSION MENU", &"gear", "Resume [Esc]", func() -> void: close_requested.emit())
	title = header.get_node("Title")
	resume_button = header.get_node("Close")
	resume_button.theme_type_variation = &"PrimaryButton"
	column.add_child(header)
	var body := UiKit.hbox(12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var nav := UiKit.vbox(2)
	nav.name = "Navigation"
	nav.custom_minimum_size.x = 150
	body.add_child(nav)
	for entry: Array in PAGES:
		var button: Button = UiKit.button(entry[1], &"ListButton", show_page.bind(entry[0]))
		button.name = String(entry[0]).to_pascal_case()
		button.toggle_mode = true
		button.button_group = _group
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		nav.add_child(button)
		page_buttons[entry[0]] = button
	var filler := Control.new()
	filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav.add_child(filler)
	return_button = UiKit.button("Return to main menu", &"", _ask_return)
	return_button.name = "ReturnToMenu"
	return_button.visible = allow_return
	nav.add_child(return_button)
	quit_button = UiKit.button("Quit to desktop", &"", _ask_quit)
	quit_button.name = "Quit"
	nav.add_child(quit_button)
	body.add_child(VSeparator.new())
	var content := Control.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.clip_contents = true
	body.add_child(content)
	pages[&"overview"] = _overview_page()
	settings_panel = SettingsPanel.new()
	pages[&"settings"] = settings_panel
	comms_view = CommsLogView.new()
	pages[&"comms"] = comms_view
	database_view = EquipmentDatabaseView.new()
	pages[&"database"] = database_view
	for id: StringName in pages:
		pages[id].set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		pages[id].hide()
		content.add_child(pages[id])
	confirm = ConfirmDialog.new()
	add_child(confirm)


func bind(settings: AppSettings, dialogue: ChiwisDialogue, database: EquipmentDatabase) -> void:
	settings_panel.bind(settings)
	comms_view.bind(dialogue)
	database_view.bind(database)


func open(page: StringName = &"overview") -> void:
	show()
	UiKit.center_modal(window, DESIGN_SIZE)
	show_page(page)
	refresh_bindings()
	UiMotion.fade_in(window, UiMotion.FAST)
	page_buttons[current_page].grab_focus()


func close() -> void:
	confirm.cancel()
	hide()
	var focused: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	if focused != null and is_ancestor_of(focused):
		focused.release_focus()


func show_page(page: StringName) -> void:
	if not pages.has(page):
		return
	current_page = page
	for id: StringName in pages:
		pages[id].visible = id == page
		page_buttons[id].set_pressed_no_signal(id == page)
	title.text = "MISSION MENU" if page == &"overview" else String(PAGES[_index(page)][1]).to_upper()
	if page == &"settings":
		settings_panel.refresh()


func refresh_bindings() -> void:
	for hint: KeyHint in _hints:
		hint.refresh()
	settings_panel.refresh()


## Esc inside the menu: cancel a pending key capture or confirmation first, then close.
func handle_back() -> bool:
	if not visible:
		return false
	if settings_panel.is_capturing() or confirm.visible:
		return true
	close_requested.emit()
	return true


func _overview_page() -> Control:
	var page := UiKit.vbox(4)
	page.name = "Overview"
	page.add_child(UiKit.label("SESSION", &"SectionLabel"))
	page.add_child(UiKit.wrapped("The session is paused while this menu is open. Progress is not saved to disk: returning to the main menu or quitting ends the current session.", &"SecondaryLabel", 300))
	page.add_child(UiKit.separator())
	page.add_child(UiKit.label("CONTROLS", &"SectionLabel"))
	var scroll: ScrollContainer = UiKit.scroll(Vector2(0, 100))
	page.add_child(scroll)
	var rows := UiKit.vbox(3)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(rows)
	for entry: Array in CONTROL_ROWS:
		var hint := KeyHint.new(entry[0], entry[1])
		_hints.append(hint)
		rows.add_child(hint)
	rows.add_child(UiKit.wrapped("Arrow keys: pan the overview.  Mouse wheel: zoom.  Left click: interact.", &"MutedLabel", 280))
	return page


func _ask_return() -> void:
	confirm.ask("RETURN TO MAIN MENU", "The current session is not saved and will end.", "End session",
		func() -> void: return_to_menu_requested.emit())


func _ask_quit() -> void:
	confirm.ask("QUIT TO DESKTOP", "The current session is not saved and will end.", "Quit",
		func() -> void: quit_requested.emit())


func _index(page: StringName) -> int:
	for slot: int in PAGES.size():
		if PAGES[slot][0] == page:
			return slot
	return 0
