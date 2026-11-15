class_name NotificationArea
extends PanelContainer
## One bounded system-notice card. The latest notice replaces the previous one, except that a
## more severe notice stays up until it expires and the newest lesser notice follows it.
## Hidden while idle. No gameplay state.

enum Level { INFO, WARNING, CRITICAL }

const IDLE_TEXT: String = "No new messages"
const TITLES: Dictionary[Level, String] = {Level.INFO: "SYSTEM NOTICE", Level.WARNING: "WARNING", Level.CRITICAL: "ALERT"}
const STATES: Dictionary[Level, UiKit.State] = {
	Level.INFO: UiKit.State.NOMINAL, Level.WARNING: UiKit.State.WARNING, Level.CRITICAL: UiKit.State.CRITICAL,
}

@export_range(1, 300) var maximum_characters: int = 180
var level: Level = Level.INFO
var _pending: Dictionary = {}
@onready var title: Label = $Content/Title
@onready var message: Label = $Content/Message
@onready var expiry: Timer = $Expiry


func _ready() -> void:
	expiry.timeout.connect(_expired)
	hide()


func post_message(text: String, duration: float = 3.5, severity: Level = Level.INFO) -> bool:
	var clean: String = text.strip_edges().replace("\n", " ").replace("\r", " ")
	if clean.is_empty() or not is_finite(duration) or duration <= 0:
		return false
	if not expiry.is_stopped() and severity < level:
		_pending = {"text": clean, "duration": duration, "severity": severity}
		return true
	_show(clean, duration, severity)
	return true


func clear_message() -> void:
	expiry.stop()
	_pending = {}
	message.text = IDLE_TEXT
	level = Level.INFO
	UiMotion.stop(self)
	hide()


func is_active() -> bool:
	return not expiry.is_stopped()


func _show(clean: String, duration: float, severity: Level) -> void:
	var limit: int = clampi(maximum_characters, 1, 300)
	message.text = clean.left(limit - 1) + "…" if clean.length() > limit else clean
	level = severity
	title.text = TITLES[severity]
	title.add_theme_color_override(&"font_color", UiKit.state_color(self, STATES[severity]))
	expiry.start(duration)
	if not visible:
		UiMotion.fade_in(self, UiMotion.FAST)
	else:
		UiMotion.flash(self, Color(1.35, 1.35, 1.35), UiMotion.NORMAL)


func _expired() -> void:
	if not _pending.is_empty():
		var next: Dictionary = _pending
		_pending = {}
		_show(next.text, next.duration, next.severity)
		return
	message.text = IDLE_TEXT
	level = Level.INFO
	UiMotion.fade_out(self)
