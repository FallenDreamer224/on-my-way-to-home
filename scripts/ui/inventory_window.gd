class_name InventoryWindow
extends Control
## Event-driven inventory display. Slot controls are allocated once per configuration;
## quantities and item identity remain in RuntimeInventory.

signal close_requested

const DESIGN_SIZE: Vector2 = Vector2(566, 322)
const SLOT_SIZE: Vector2 = Vector2(48, 48)
const COLUMNS: int = 5
## Tags that describe development status rather than a player-facing category.
const HIDDEN_TAGS: PackedStringArray = ["development"]

var inventory: RuntimeInventory
var slot_buttons: Array[Button] = []
var selected_slot: int = -1
var refresh_count: int = 0
var active_filter: String = ""
var window: MissionPanel
var summary: Label
var capacity_bar: ProgressBar
var capacity_note: Label
var filters: HBoxContainer
var details_icon: TextureRect
var details_name: Label
var details_tags: Label
var details_description: Label
var details_quantity: Label
var details_total: Label
var _grid: GridContainer
var _icons: Array[TextureRect] = []
var _frames: Array[Panel] = []
var _group := ButtonGroup.new()
var _filter_group := ButtonGroup.new()
var _filter_signature: String = "?"


func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_STOP
	window = MissionPanel.new()
	window.name = "Window"
	add_child(window)
	var column := UiKit.vbox(6)
	window.add_child(column)
	column.add_child(UiKit.window_header("ASTRONAUT INVENTORY", &"inventory", "Close", func() -> void: close_requested.emit()))
	var status := UiKit.hbox(8)
	column.add_child(status)
	summary = UiKit.label("", &"SecondaryLabel")
	summary.name = "Summary"
	status.add_child(summary)
	capacity_bar = UiKit.gauge(UiKit.State.NOMINAL, 90)
	capacity_bar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	status.add_child(capacity_bar)
	capacity_note = UiKit.label("", &"CaptionLabel")
	capacity_note.name = "CapacityNote"
	capacity_note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	status.add_child(capacity_note)
	status.add_child(UiKit.spacer())
	filters = UiKit.hbox(2)
	filters.name = "Filters"
	status.add_child(filters)
	var body := UiKit.hbox(12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var scroll: ScrollContainer = UiKit.scroll(Vector2(COLUMNS * SLOT_SIZE.x + (COLUMNS - 1) * 2 + 8, 4 * SLOT_SIZE.y + 6))
	scroll.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override(&"h_separation", 2)
	_grid.add_theme_constant_override(&"v_separation", 2)
	scroll.add_child(_grid)
	var detail_panel: PanelContainer = UiKit.panel(&"InsetPanel")
	detail_panel.name = "Details"
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail_panel)
	var detail := UiKit.vbox(4)
	detail_panel.add_child(detail)
	var heading := UiKit.hbox(8)
	detail.add_child(heading)
	details_icon = UiKit.texture_rect(null)
	details_icon.custom_minimum_size = Vector2(32, 32)
	heading.add_child(details_icon)
	var titles := UiKit.vbox(0)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(titles)
	details_name = UiKit.wrapped("", &"AccentLabel", 150)
	details_name.name = "ItemName"
	titles.add_child(details_name)
	details_tags = UiKit.label("", &"CaptionLabel")
	details_tags.name = "ItemTags"
	titles.add_child(details_tags)
	detail.add_child(UiKit.separator())
	details_quantity = UiKit.label("", &"SecondaryLabel")
	details_quantity.name = "ItemQuantity"
	detail.add_child(details_quantity)
	details_total = UiKit.label("", &"MutedLabel")
	details_total.name = "ItemTotal"
	detail.add_child(details_total)
	details_description = UiKit.wrapped("", &"", 200)
	details_description.name = "ItemDescription"
	details_description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_child(details_description)
	var help: Label = UiKit.label("Arrows / mouse: inspect slots   |   Inventory key / Esc: close", &"CaptionLabel")
	column.add_child(help)


func configure(items: RuntimeInventory) -> void:
	if is_instance_valid(inventory) and inventory.changed.is_connected(refresh):
		inventory.changed.disconnect(refresh)
	inventory = items
	for button: Button in slot_buttons:
		button.free()
	slot_buttons.clear()
	_icons.clear()
	_frames.clear()
	for index: int in inventory.slot_count():
		var button := Button.new()
		button.name = "Slot%d" % (index + 1)
		button.theme_type_variation = &"SlotButton"
		button.custom_minimum_size = SLOT_SIZE
		button.toggle_mode = true
		button.button_group = _group
		button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		button.clip_text = true
		button.pressed.connect(inspect_slot.bind(index))
		button.focus_entered.connect(inspect_slot.bind(index))
		# The icon is a native 32 x 32 canvas centered on the slot frame art.
		var icon: TextureRect = UiKit.texture_rect(null)
		icon.position = Vector2(8, 8)
		icon.size = Vector2(32, 32)
		button.add_child(icon)
		# Selection frame hugging the 26-pixel slot art inside the padded canvas.
		var frame := Panel.new()
		frame.name = "Selection"
		frame.theme_type_variation = &"SelectionFrame"
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.position = Vector2(8, 9)
		frame.size = Vector2(31, 30)
		frame.hide()
		button.add_child(frame)
		_frames.append(frame)
		_grid.add_child(button)
		slot_buttons.append(button)
		_icons.append(icon)
	inventory.changed.connect(refresh)
	refresh()


func set_open(value: bool) -> void:
	visible = value
	if value:
		UiKit.center_modal(window, DESIGN_SIZE)
		UiMotion.fade_in(window, UiMotion.FAST)
		if not slot_buttons.is_empty():
			slot_buttons[maxi(0, selected_slot)].grab_focus()
	else:
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused != null and is_ancestor_of(focused):
			focused.release_focus()


func refresh() -> void:
	refresh_count += 1
	var used: int = inventory.slot_count() - inventory.free_slot_count()
	var full: bool = inventory.slot_count() > 0 and inventory.free_slot_count() == 0
	summary.text = "%d / %d slots used" % [used, inventory.slot_count()]
	capacity_bar.max_value = maxi(1, inventory.slot_count())
	capacity_bar.value = used
	capacity_bar.theme_type_variation = UiKit.STATE_GAUGES[UiKit.State.WARNING if full else UiKit.State.NOMINAL]
	capacity_note.text = "FULL: NEW ITEMS STAY IN THE WORLD" if full else ""
	capacity_note.theme_type_variation = &"CaptionLabel"
	capacity_note.add_theme_color_override(&"font_color", UiKit.state_color(self, UiKit.State.WARNING))
	var tags: PackedStringArray = []
	for index: int in slot_buttons.size():
		var slot: Dictionary = inventory.slot_snapshot(index)
		var item: ItemDefinition = inventory.definition(slot.item_id)
		var button: Button = slot_buttons[index]
		_icons[index].texture = UiIcons.item_texture(item) if item != null else null
		button.text = "x%d" % slot.quantity if item != null else ""
		button.tooltip_text = item.display_name + "\n" + item.description if item != null else "Empty slot"
		if item != null:
			for tag: String in item.tags:
				if tag not in HIDDEN_TAGS and tag not in tags:
					tags.append(tag)
	_rebuild_filters(tags)
	_apply_filter()
	inspect_slot(selected_slot)


func inspect_slot(index: int) -> void:
	selected_slot = index
	var slot: Dictionary = inventory.slot_snapshot(index)
	var item: ItemDefinition = inventory.definition(slot.get("item_id", &""))
	for position_index: int in slot_buttons.size():
		slot_buttons[position_index].set_pressed_no_signal(position_index == index)
		_frames[position_index].visible = position_index == index
	details_icon.texture = UiIcons.item_texture(item) if item != null else null
	details_name.text = item.display_name if item != null else "Empty slot"
	details_tags.text = _tag_text(item)
	details_quantity.text = "Quantity: %d   |   Max stack: %d" % [slot.quantity, item.stack_limit()] if item != null else ""
	details_total.text = "Carried in total: %d" % inventory.get_quantity(item.item_id) if item != null else ""
	details_description.text = item.description if item != null else "Collect a nearby development pickup to fill an available slot."


func set_filter(tag: String) -> void:
	active_filter = tag
	_apply_filter()


static func _tag_text(item: ItemDefinition) -> String:
	if item == null:
		return ""
	var shown: PackedStringArray = []
	for tag: String in item.tags:
		if tag not in HIDDEN_TAGS:
			shown.append(tag.to_upper())
	return " / ".join(shown) if not shown.is_empty() else "SUPPLY"


## Filter chips exist only for tags carried right now; item data defines the categories.
func _rebuild_filters(tags: PackedStringArray) -> void:
	tags.sort()
	var signature: String = ",".join(tags)
	if signature == _filter_signature:
		return
	_filter_signature = signature
	for child: Node in filters.get_children():
		filters.remove_child(child)
		child.queue_free()
	if active_filter not in tags:
		active_filter = ""
	if tags.size() < 2:
		return
	for tag: String in PackedStringArray([""]) + tags:
		var chip: Button = UiKit.button("All" if tag.is_empty() else tag.capitalize(), &"GhostButton", set_filter.bind(tag))
		chip.toggle_mode = true
		chip.button_group = _filter_group
		chip.focus_mode = Control.FOCUS_NONE
		chip.set_pressed_no_signal(tag == active_filter)
		filters.add_child(chip)


func _apply_filter() -> void:
	for index: int in slot_buttons.size():
		var item: ItemDefinition = inventory.definition(inventory.slot_snapshot(index).item_id)
		var matches: bool = active_filter.is_empty() or (item != null and active_filter in item.tags)
		slot_buttons[index].modulate.a = 1.0 if matches else 0.3
