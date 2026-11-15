class_name ChiwisDialogue
extends Node
## Companion message queue: priority, per-topic cooldown, dismissal and a bounded history.
## Presentation only. No voice, audio or gameplay state is involved.

enum Priority { REMARK, TUTORIAL, WARNING, CRITICAL }

signal line_started(line: Dictionary)
signal line_finished
signal history_changed

const SPEAKER: String = "Chiwis"
const MAX_QUEUE: int = 6
const MAX_HISTORY: int = 40
const MAX_CHARACTERS: int = 240
const MIN_SECONDS: float = 3.0
const MAX_SECONDS: float = 10.0

## Current line: topic, text, priority, duration and remaining seconds. Empty when silent.
var current: Dictionary = {}
var history: Array[Dictionary] = []
## While held (a modal window is open) the visible line does not expire unread.
var hold: bool = false
var clock: float = 0.0
var _queue: Array[Dictionary] = []
var _ready_at: Dictionary[StringName, float] = {}


func _process(delta: float) -> void:
	advance(delta)


## Queues one line. Returns false when the topic is cooling down, already waiting, or the
## queue is full of equally or more important lines.
func say(topic: StringName, text: String, priority: Priority = Priority.REMARK, duration: float = 0.0, cooldown: float = 0.0) -> bool:
	var clean: String = text.strip_edges().replace("\n", " ").replace("\r", " ")
	if clean.is_empty() or not is_finite(duration) or not is_finite(cooldown):
		return false
	if clean.length() > MAX_CHARACTERS:
		clean = clean.left(MAX_CHARACTERS - 1) + "…"
	if clock < _ready_at.get(topic, -INF) or current.get("topic") == topic:
		return false
	for waiting: Dictionary in _queue:
		if waiting.topic == topic:
			return false
	var seconds: float = duration if duration > 0.0 else reading_seconds(clean)
	var line: Dictionary = {"topic": topic, "text": clean, "priority": priority,
		"duration": seconds, "remaining": seconds}
	if current.is_empty():
		_ready_at[topic] = clock + maxf(0.0, cooldown)
		_begin(line)
		return true
	if priority > int(current.priority):
		# A more urgent line interrupts; guidance returns afterwards, small talk is dropped.
		if int(current.priority) >= Priority.TUTORIAL:
			current.remaining = current.duration
			current.resumed = true
			_queue.push_front(current)
		_ready_at[topic] = clock + maxf(0.0, cooldown)
		_begin(line)
		return true
	if _queue.size() >= MAX_QUEUE:
		var weakest: int = _weakest_index()
		if int(_queue[weakest].priority) >= priority:
			return false
		_queue.remove_at(weakest)
	var index: int = _queue.size()
	for position: int in _queue.size():
		if int(_queue[position].priority) < priority:
			index = position
			break
	_queue.insert(index, line)
	_ready_at[topic] = clock + maxf(0.0, cooldown)
	return true


func advance(delta: float) -> void:
	if not is_finite(delta) or delta < 0.0:
		return
	clock += delta
	if current.is_empty() or hold:
		return
	current.remaining = float(current.remaining) - delta
	if float(current.remaining) <= 0.0:
		_finish()


## Player dismissal: closes the visible line and shows the next one, if any.
func dismiss() -> bool:
	if current.is_empty():
		return false
	_finish()
	return true


func clear() -> void:
	_queue.clear()
	if not current.is_empty():
		current = {}
		line_finished.emit()


func pending_count() -> int:
	return _queue.size()


func is_speaking() -> bool:
	return not current.is_empty()


static func reading_seconds(text: String) -> float:
	return clampf(2.0 + text.length() * 0.055, MIN_SECONDS, MAX_SECONDS)


func _begin(line: Dictionary) -> void:
	current = line
	# An interrupted line that returns is already in the history.
	if not line.get("resumed", false):
		history.append({"text": line.text, "priority": line.priority, "clock": clock})
		if history.size() > MAX_HISTORY:
			history.remove_at(0)
		history_changed.emit()
	line_started.emit(current)


func _finish() -> void:
	current = {}
	line_finished.emit()
	if not _queue.is_empty():
		_begin(_queue.pop_front())


func _weakest_index() -> int:
	var weakest: int = 0
	for index: int in _queue.size():
		if int(_queue[index].priority) <= int(_queue[weakest].priority):
			weakest = index
	return weakest
