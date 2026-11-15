class_name UiMotion
extends RefCounted
## Shared interface transitions. Every helper lands on its final state at once when
## reduced motion is requested, and each control owns at most one running transition.

const FAST: float = 0.1
const NORMAL: float = 0.18
const SLOW: float = 0.4
const _TWEEN: StringName = &"ui_motion_tween"
const _REST: StringName = &"ui_motion_rest"

static var reduced: bool = false


static func fade_in(item: CanvasItem, duration: float = NORMAL) -> void:
	_stop(item)
	item.show()
	if reduced or not item.is_inside_tree():
		item.modulate.a = 1.0
		return
	item.modulate.a = 0.0
	_start(item).tween_property(item, "modulate:a", 1.0, duration)


static func fade_out(item: CanvasItem, duration: float = FAST, hide_after: bool = true) -> void:
	_stop(item)
	if reduced or not item.is_inside_tree() or not item.visible:
		item.modulate.a = 1.0
		if hide_after:
			item.hide()
		return
	var tween: Tween = _start(item)
	tween.tween_property(item, "modulate:a", 0.0, duration)
	if hide_after:
		tween.tween_callback(func() -> void:
			item.hide()
			item.modulate.a = 1.0)


## Slides a free-positioned control from an offset to its resting position while fading in.
## The control must not be managed by a Container.
static func slide_in(control: Control, offset: Vector2, duration: float = NORMAL) -> void:
	_stop(control)
	control.show()
	if reduced or not control.is_inside_tree():
		control.modulate.a = 1.0
		return
	# Only the offset axes are animated, so layout may still resize the other axis.
	var rest: Dictionary = {}
	control.modulate.a = 0.0
	var tween: Tween = _start(control).set_parallel(true)
	tween.tween_property(control, "modulate:a", 1.0, duration)
	for axis: String in ["x", "y"]:
		var distance: float = offset.x if axis == "x" else offset.y
		if is_zero_approx(distance):
			continue
		var target: float = control.position.x if axis == "x" else control.position.y
		rest[axis] = target
		control.set("position:" + axis, target + distance)
		tween.tween_property(control, "position:" + axis, target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	control.set_meta(_REST, rest)
	tween.chain().tween_callback(func() -> void: control.remove_meta(_REST))


## Brief tint used for objective updates and equipment state changes.
static func flash(item: CanvasItem, tint: Color, duration: float = SLOW) -> void:
	_stop(item)
	if reduced or not item.is_inside_tree():
		item.self_modulate = Color.WHITE
		return
	item.self_modulate = tint
	_start(item).tween_property(item, "self_modulate", Color.WHITE, duration)


## Looping emphasis for a critical indicator. Static under reduced motion.
static func blink(item: CanvasItem, period: float = 1.0) -> void:
	_stop(item)
	item.modulate.a = 1.0
	if reduced or not item.is_inside_tree():
		return
	var tween: Tween = _start(item).set_loops()
	tween.tween_property(item, "modulate:a", 0.35, period * 0.5)
	tween.tween_property(item, "modulate:a", 1.0, period * 0.5)


static func stop(item: CanvasItem) -> void:
	_stop(item)
	item.modulate.a = 1.0
	item.self_modulate = Color.WHITE


static func _start(item: CanvasItem) -> Tween:
	var tween: Tween = item.create_tween()
	item.set_meta(_TWEEN, tween)
	return tween


static func _stop(item: CanvasItem) -> void:
	if item.has_meta(_TWEEN):
		var tween: Variant = item.get_meta(_TWEEN)
		if tween is Tween and tween.is_valid():
			tween.kill()
		item.remove_meta(_TWEEN)
	if item.has_meta(_REST) and item is Control:
		var rest: Dictionary = item.get_meta(_REST)
		for axis: String in rest:
			item.set("position:" + axis, rest[axis])
		item.remove_meta(_REST)
