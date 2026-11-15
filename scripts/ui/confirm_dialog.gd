class_name ConfirmDialog
extends Control
## Small blocking confirmation. The caller supplies the consequence; Cancel is the default focus.

signal confirmed
signal cancelled

const DESIGN_SIZE: Vector2 = Vector2(360, 136)

var window: MissionPanel
var title: Label
var message: Label
var confirm_button: Button
var cancel_button: Button
var _on_confirm: Callable


func _init() -> void:
	name = "ConfirmDialog"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()
	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.45)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	window = MissionPanel.new()
	window.name = "Window"
	add_child(window)
	var column := UiKit.vbox(8)
	window.add_child(column)
	title = UiKit.label("", &"WindowTitleLabel")
	title.name = "Title"
	column.add_child(title)
	message = UiKit.wrapped("", &"SecondaryLabel", 300)
	message.name = "Message"
	message.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(message)
	var buttons := UiKit.hbox(8)
	buttons.alignment = BoxContainer.ALIGNMENT_END
	column.add_child(buttons)
	cancel_button = UiKit.button("Cancel", &"", cancel)
	cancel_button.name = "Cancel"
	buttons.add_child(cancel_button)
	confirm_button = UiKit.button("Confirm", &"DangerButton", _confirm)
	confirm_button.name = "Confirm"
	buttons.add_child(confirm_button)


func ask(heading: String, body: String, confirm_text: String, on_confirm: Callable = Callable()) -> void:
	title.text = heading
	message.text = body
	confirm_button.text = confirm_text
	_on_confirm = on_confirm
	show()
	UiKit.center_modal(window, DESIGN_SIZE)
	UiMotion.fade_in(window, UiMotion.FAST)
	cancel_button.grab_focus()


func cancel() -> void:
	if not visible:
		return
	hide()
	cancelled.emit()


func _confirm() -> void:
	hide()
	confirmed.emit()
	if _on_confirm.is_valid():
		_on_confirm.call()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"game_pause") and not event.is_echo():
		cancel()
		get_viewport().set_input_as_handled()
