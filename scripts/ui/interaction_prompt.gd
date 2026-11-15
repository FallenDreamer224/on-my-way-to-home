class_name InteractionPrompt
extends Control

signal notice_requested(text: String)
var detector: InteractionDetector
@onready var prompt: Label = $PromptPanel/Text
@onready var panel: PanelContainer = $PromptPanel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clear_prompt()


func configure(source: InteractionDetector) -> void:
	detector = source
	detector.target_changed.connect(_target_changed)
	detector.attempted.connect(_attempted)
	detector.tree_exiting.connect(_clear_prompt)
	refresh_prompt()


func refresh_prompt() -> void:
	var target: Interactable = detector.target if is_instance_valid(detector) and is_instance_valid(detector.target) else null
	prompt.text = "[%s] %s %s" % [InputHint.label(&"interact_primary"), target.action_label, target.display_name] if target != null and detector.enabled else ""
	panel.visible = not prompt.text.is_empty()


func _target_changed(_target: Interactable) -> void:
	refresh_prompt()


func _attempted(_success: bool) -> void:
	if not detector.last_result_message.is_empty():
		notice_requested.emit(detector.last_result_message)


func _clear_prompt() -> void:
	prompt.text = ""
	panel.hide()
