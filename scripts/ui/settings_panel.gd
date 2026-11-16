class_name SettingsPanel
extends VBoxContainer
## Display, interface and keyboard preferences. Every change applies and saves at once.
## No audio options exist because the project has no audio.

const PAGES: PackedStringArray = ["Display", "Interface", "Controls"]

var settings: AppSettings
var tabs: TabBar
var window_mode: OptionButton
var window_size: OptionButton
var vsync: CheckButton
var ui_scale: OptionButton
var high_contrast: CheckButton
var reduced_motion: CheckButton
var binding_buttons: Dictionary[StringName, Button] = {}
var status: Label
var reset_controls: Button
var reset_everything: Button
var _pages: Array[Control] = []
var _capturing: StringName = &""
var _refreshing: bool = false


func _init() -> void:
	name = "Settings"
	add_theme_constant_override(&"separation", 6)
	tabs = TabBar.new()
	tabs.name = "Tabs"
	for title: String in PAGES:
		tabs.add_tab(title)
	tabs.tab_changed.connect(_show_page)
	add_child(tabs)
	_pages = [_display_page(), _interface_page(), _controls_page()]
	for page: Control in _pages:
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(page)
	var footer := UiKit.hbox(8)
	add_child(footer)
	status = UiKit.label("Settings are stored on this device.", &"CaptionLabel")
	status.name = "Status"
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer.add_child(status)
	reset_everything = UiKit.button("Restore defaults", &"", _reset_all)
	reset_everything.name = "RestoreDefaults"
	footer.add_child(reset_everything)
	_show_page(0)


func bind(source: AppSettings) -> void:
	if settings != null and settings.changed.is_connected(refresh):
		settings.changed.disconnect(refresh)
	settings = source
	settings.changed.connect(refresh)
	refresh()


func is_capturing() -> bool:
	return _capturing != &""


func refresh() -> void:
	if settings == null:
		return
	_refreshing = true
	window_mode.select(1 if settings.fullscreen else 0)
	window_size.select(AppSettings.WINDOW_SCALES.find(settings.window_scale))
	window_size.disabled = settings.fullscreen
	vsync.button_pressed = settings.vsync
	ui_scale.select(AppSettings.UI_SCALES.find(settings.ui_scale))
	high_contrast.button_pressed = settings.high_contrast
	reduced_motion.button_pressed = settings.reduced_motion
	for action: StringName in binding_buttons:
		binding_buttons[action].text = "Press a key..." if action == _capturing else InputHint.label(action)
	_refreshing = false


func _show_page(index: int) -> void:
	for slot: int in _pages.size():
		_pages[slot].visible = slot == index
	_cancel_capture()


func _grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 16)
	grid.add_theme_constant_override(&"v_separation", 6)
	return grid


func _option(grid: GridContainer, caption: String, choices: PackedStringArray, on_selected: Callable) -> OptionButton:
	var title: Label = UiKit.label(caption, &"SecondaryLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(title)
	var option := OptionButton.new()
	option.custom_minimum_size.x = 170
	for choice: String in choices:
		option.add_item(choice)
	option.item_selected.connect(on_selected)
	grid.add_child(option)
	return option


func _switch(grid: GridContainer, caption: String, on_toggled: Callable) -> CheckButton:
	var title: Label = UiKit.label(caption, &"SecondaryLabel")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(title)
	var toggle := CheckButton.new()
	toggle.size_flags_horizontal = Control.SIZE_SHRINK_END
	toggle.toggled.connect(on_toggled)
	grid.add_child(toggle)
	return toggle


func _display_page() -> Control:
	var page := UiKit.vbox(8)
	page.name = "Display"
	var grid: GridContainer = _grid()
	page.add_child(grid)
	window_mode = _option(grid, "Window mode", ["Windowed", "Fullscreen (borderless)"], func(_index: int) -> void: _apply_display())
	var sizes: PackedStringArray = []
	for factor: int in AppSettings.WINDOW_SCALES:
		sizes.append("%d x %d  (%dx)" % [AppSettings.BASE_SIZE.x * factor, AppSettings.BASE_SIZE.y * factor, factor])
	window_size = _option(grid, "Window size", sizes, func(_index: int) -> void: _apply_display(true))
	vsync = _switch(grid, "Vertical sync", func(_pressed: bool) -> void: _apply_display())
	page.add_child(UiKit.wrapped("960 x 540 with nearest filtering. Exact multiples use integer pixels; other sizes fit the full view with nearest scaling. Other aspect ratios have bars. F11 or Alt+Enter toggles borderless fullscreen. Window size and position are restored.", &"MutedLabel", 300))
	return page


func _interface_page() -> Control:
	var page := UiKit.vbox(8)
	page.name = "Interface"
	var grid: GridContainer = _grid()
	page.add_child(grid)
	var scales: PackedStringArray = []
	for factor: float in AppSettings.UI_SCALES:
		scales.append("%d%%" % roundi(factor * 100.0))
	ui_scale = _option(grid, "Interface scale", scales, func(_index: int) -> void: _apply_interface())
	high_contrast = _switch(grid, "High contrast", func(_pressed: bool) -> void: _apply_interface())
	reduced_motion = _switch(grid, "Reduced motion", func(_pressed: bool) -> void: _apply_interface())
	page.add_child(UiKit.wrapped("100% keeps interface pixels exact. Larger scales enlarge every panel; fractional steps trade some pixel evenness for size. Reduced motion removes slides, fades and menu parallax.", &"MutedLabel", 300))
	return page


func _controls_page() -> Control:
	var page := UiKit.vbox(6)
	page.name = "Controls"
	var scroll: ScrollContainer = UiKit.scroll(Vector2(0, 150))
	page.add_child(scroll)
	var grid: GridContainer = _grid()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for action: StringName in AppSettings.REMAPPABLE:
		var title: Label = UiKit.label(AppSettings.ACTION_TITLES[action], &"SecondaryLabel")
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(title)
		var key: Button = UiKit.button("", &"", _begin_capture.bind(action))
		key.name = String(action)
		key.custom_minimum_size.x = 150
		grid.add_child(key)
		binding_buttons[action] = key
	var row := UiKit.hbox(8)
	page.add_child(row)
	var note: Label = UiKit.wrapped("Select an action, then press a key. Esc cancels and stays reserved. Arrow keys always pan; the mouse wheel zooms the overview.", &"MutedLabel", 220)
	row.add_child(note)
	reset_controls = UiKit.button("Reset controls", &"", _reset_controls)
	reset_controls.name = "ResetControls"
	reset_controls.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(reset_controls)
	return page


func _apply_display(resize_window: bool = false) -> void:
	if _refreshing or settings == null:
		return
	settings.set_display(window_mode.selected == 1, AppSettings.WINDOW_SCALES[maxi(0, window_size.selected)], vsync.button_pressed, not resize_window)
	settings.apply_display(get_window())
	_saved()


func _apply_interface() -> void:
	if _refreshing or settings == null:
		return
	settings.set_interface(AppSettings.UI_SCALES[maxi(0, ui_scale.selected)], high_contrast.button_pressed, reduced_motion.button_pressed)
	_saved()


func _begin_capture(action: StringName) -> void:
	_capturing = action
	status.text = "Press a key for: " + AppSettings.ACTION_TITLES[action]
	refresh()


func _cancel_capture() -> void:
	if _capturing == &"":
		return
	_capturing = &""
	if status != null:
		status.text = "Settings are stored on this device."
	refresh()


func _reset_controls() -> void:
	if settings == null:
		return
	_capturing = &""
	settings.reset_bindings()
	_saved()


func _reset_all() -> void:
	if settings == null:
		return
	_capturing = &""
	settings.reset_all()
	settings.set_display(false, 1, true)
	settings.apply_display(get_window())
	_saved()


func _saved() -> void:
	status.text = "Saved." if settings.save_settings() else "Could not write the settings file."
	refresh()


func _input(event: InputEvent) -> void:
	if _capturing == &"" or not is_visible_in_tree() or not event is InputEventKey or not event.pressed or event.is_echo():
		return
	var key := event as InputEventKey
	var code: int = key.physical_keycode if key.physical_keycode != 0 else key.keycode
	get_viewport().set_input_as_handled()
	if code == KEY_ESCAPE:
		_cancel_capture()
		return
	var action: StringName = _capturing
	_capturing = &""
	if settings != null and settings.rebind(action, code):
		_saved()
	else:
		status.text = "That key cannot be used."
		refresh()
