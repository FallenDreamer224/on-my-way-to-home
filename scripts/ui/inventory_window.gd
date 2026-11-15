class_name InventoryWindow
extends Control
## Event-driven display. Buttons are allocated once; quantities remain in the inventory.

signal close_requested
var inventory: RuntimeInventory
var slot_buttons: Array[Button] = []
var selected_slot: int = -1
var refresh_count: int = 0
var summary: Label
var details_name: Label
var details_description: Label
var details_quantity: Label
var _grid: GridContainer


func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.015, 0.025, 0.04, 0.78)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -392
	panel.offset_top = -194
	panel.offset_right = 392
	panel.offset_bottom = 194
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("15232c")
	style.border_color = Color("719caa")
	style.set_border_width_all(2)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var header: HBoxContainer = HBoxContainer.new()
	column.add_child(header)
	var title: Label = Label.new()
	title.text = "ASTRONAUT INVENTORY"
	title.add_theme_font_size_override("font_size", 20)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_button: Button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func() -> void: close_requested.emit())
	header.add_child(close_button)
	summary = Label.new()
	column.add_child(summary)
	var body: HBoxContainer = HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	column.add_child(body)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(434, 250)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 5
	_grid.add_theme_constant_override("h_separation", 5)
	_grid.add_theme_constant_override("v_separation", 5)
	scroll.add_child(_grid)
	var detail_column: VBoxContainer = VBoxContainer.new()
	detail_column.custom_minimum_size.x = 270
	detail_column.add_theme_constant_override("separation", 12)
	body.add_child(detail_column)
	details_name = Label.new()
	details_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_name.add_theme_font_size_override("font_size", 19)
	detail_column.add_child(details_name)
	details_quantity = Label.new()
	detail_column.add_child(details_quantity)
	details_description = Label.new()
	details_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_column.add_child(details_description)
	var help: Label = Label.new()
	help.text = "Arrows / mouse: inspect slots   |   Inventory key / Esc: close"
	help.add_theme_font_size_override("font_size", 13)
	column.add_child(help)


func configure(items: RuntimeInventory) -> void:
	if is_instance_valid(inventory) and inventory.changed.is_connected(refresh):
		inventory.changed.disconnect(refresh)
	inventory = items
	for button: Button in slot_buttons:
		button.free()
	slot_buttons.clear()
	for index: int in inventory.slot_count():
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(80, 58)
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(inspect_slot.bind(index))
		button.focus_entered.connect(inspect_slot.bind(index))
		_grid.add_child(button)
		slot_buttons.append(button)
	inventory.changed.connect(refresh)
	refresh()


func set_open(value: bool) -> void:
	visible = value
	if value and not slot_buttons.is_empty():
		slot_buttons[maxi(0, selected_slot)].grab_focus()
	elif not value:
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused != null and is_ancestor_of(focused):
			focused.release_focus()


func refresh() -> void:
	refresh_count += 1
	summary.text = "%d / %d slots used" % [inventory.slot_count() - inventory.free_slot_count(), inventory.slot_count()]
	for index: int in slot_buttons.size():
		var slot: Dictionary = inventory.slot_snapshot(index)
		var item: ItemDefinition = inventory.definition(slot.item_id)
		var button: Button = slot_buttons[index]
		button.icon = ItemPlaceholder.texture(item) if item != null else null
		button.text = "x%d" % slot.quantity if item != null else str(index + 1)
		button.tooltip_text = item.display_name + "\n" + item.description if item != null else "Empty slot"
	inspect_slot(selected_slot)


func inspect_slot(index: int) -> void:
	selected_slot = index
	var slot: Dictionary = inventory.slot_snapshot(index)
	var item: ItemDefinition = inventory.definition(slot.get("item_id", &""))
	details_name.text = item.display_name if item != null else "Empty slot"
	details_quantity.text = "Quantity: %d   |   Max stack: %d" % [slot.quantity, item.stack_limit()] if item != null else ""
	details_description.text = item.description if item != null else "Collect a nearby development pickup to fill an available slot."
