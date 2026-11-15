class_name CommsLogView
extends ScrollContainer
## Read-only history of companion messages for the current session.

var dialogue: ChiwisDialogue
var list: VBoxContainer
var empty: Label


func _init() -> void:
	name = "CommsLog"
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	list = UiKit.vbox(6)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(list)
	empty = UiKit.label("No messages yet.", &"MutedLabel")
	list.add_child(empty)
	visibility_changed.connect(refresh)


func bind(source: ChiwisDialogue) -> void:
	dialogue = source
	if is_instance_valid(dialogue):
		dialogue.history_changed.connect(refresh)
	refresh()


func refresh() -> void:
	if not is_visible_in_tree():
		return
	for child: Node in list.get_children():
		if child != empty:
			list.remove_child(child)
			child.queue_free()
	var entries: Array[Dictionary] = dialogue.history if is_instance_valid(dialogue) else []
	empty.visible = entries.is_empty()
	# Newest first: the latest instruction is what a returning player needs.
	for index: int in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[index]
		var row := UiKit.vbox(0)
		var seconds: int = int(entry.clock)
		var stamp: Label = UiKit.label("%s  T+%02d:%02d" % [ChiwisDialogue.SPEAKER.to_upper(), seconds / 60, seconds % 60], &"CaptionAccentLabel")
		row.add_child(stamp)
		var variation: StringName = &"WarningLabel" if int(entry.priority) >= ChiwisDialogue.Priority.WARNING else &"SecondaryLabel"
		row.add_child(UiKit.wrapped(entry.text, variation, 280))
		list.add_child(row)
