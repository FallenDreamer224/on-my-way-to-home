class_name NotificationArea
extends PanelContainer
## One bounded message slot; latest notice replaces the previous one. No gameplay state.

@export_range(1, 300) var maximum_characters: int = 180
@onready var message: Label = $Content/Message
@onready var expiry: Timer = $Expiry


func _ready() -> void:
	expiry.timeout.connect(clear_message)


func post_message(text: String, duration: float = 3.5) -> bool:
	var clean: String = text.strip_edges().replace("\n", " ").replace("\r", " ")
	if clean.is_empty() or not is_finite(duration) or duration <= 0:
		return false
	var limit: int = clampi(maximum_characters, 1, 300)
	message.text = clean.left(limit - 1) + "…" if clean.length() > limit else clean
	expiry.start(duration)
	return true


func clear_message() -> void:
	expiry.stop()
	message.text = "No new messages"
