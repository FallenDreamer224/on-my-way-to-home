class_name AstronautAnimation
extends AnimatedSprite2D
## Native SpriteFrames are replaceable in the Inspector; movement knows no sheet layout.

@export var foot_anchor: Vector2 = Vector2(32, 56)
@export var art_profile: CharacterArtProfile
var state: StringName = &"idle"
var facing: StringName = &"s"
var _selected: StringName = &""
@onready var _body: Node2D = get_parent() as Node2D


func _ready() -> void:
	if art_profile != null:
		sprite_frames = art_profile.frames
		foot_anchor = art_profile.default_anchor
	if sprite_frames == null:
		sprite_frames = AstronautPlaceholder.frames()
	centered = false
	position = -foot_anchor
	select_state(&"idle", &"s")


func get_frame_anchor() -> Vector2:
	if art_profile != null and art_profile.foot_anchors.has(animation):
		var anchors: PackedVector2Array = art_profile.foot_anchors[animation]
		if frame < anchors.size():
			return anchors[frame]
	return foot_anchor


func select_state(next_state: StringName, next_facing: StringName) -> void:
	if next_state == state and next_facing == facing and _selected != &"":
		return
	var clip: StringName = StringName(String(next_state) + "_" + String(next_facing))
	if clip == _selected:
		return
	_selected = clip
	state = next_state
	facing = next_facing
	if sprite_frames.has_animation(clip) and sprite_frames.get_frame_count(clip) > 0:
		play(clip)
	else:
		push_error("Missing astronaut animation: %s. Review replacement SpriteFrames before integration." % clip)


func _process(_delta: float) -> void:
	# Render-only snapping through the current canvas, independent of camera implementation.
	var canvas: Transform2D = _body.get_canvas_transform()
	var screen_feet: Vector2 = canvas * _body.global_position
	global_position = canvas.affine_inverse() * screen_feet.round() - get_frame_anchor()
