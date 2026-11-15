class_name DialogueWindow
extends Control
## Companion dialogue card. Mirrors a ChiwisDialogue queue, which owns priority, cooldowns
## and history. The portrait is an existing Chiwis idle frame drawn at native scale.

const FRAMES: SpriteFrames = preload("res://resources/characters/chiwis_frames.tres")
## Head and shoulders of the front-facing idle frame, shown at an exact 2x like the world camera.
const PORTRAIT_REGION: Rect2 = Rect2(15, 8, 30, 30)
const PORTRAIT_SCALE: int = 2
const TAGS: Dictionary[int, String] = {
	ChiwisDialogue.Priority.WARNING: "CAUTION", ChiwisDialogue.Priority.CRITICAL: "ALERT",
}

var dialogue: ChiwisDialogue
var card: PanelContainer
var speaker: Label
var tag: Label
var text: Label
var pending: Label
var dismiss_hint: KeyHint


func _init() -> void:
	name = "Dialogue"
	custom_minimum_size = Vector2(330, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	card = UiKit.panel(&"PromptPanel")
	card.name = "Card"
	# Bottom-anchored: longer lines grow the card upward.
	card.anchor_left = 0.0
	card.anchor_right = 1.0
	card.anchor_top = 1.0
	card.anchor_bottom = 1.0
	card.grow_vertical = Control.GROW_DIRECTION_BEGIN
	card.hide()
	add_child(card)
	var row := UiKit.hbox(8)
	card.add_child(row)
	var portrait: PanelContainer = UiKit.panel(&"PortraitPanel")
	portrait.name = "Portrait"
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(portrait)
	var face: TextureRect = UiKit.texture_rect(_portrait_texture())
	face.name = "Face"
	face.custom_minimum_size = PORTRAIT_REGION.size * PORTRAIT_SCALE
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_SCALE
	portrait.add_child(face)
	var column := UiKit.vbox(2)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(column)
	var header := UiKit.hbox(6)
	column.add_child(header)
	speaker = UiKit.label(ChiwisDialogue.SPEAKER.to_upper(), &"SectionLabel")
	speaker.name = "Speaker"
	header.add_child(speaker)
	tag = UiKit.label("", &"CaptionLabel")
	tag.name = "Tag"
	header.add_child(tag)
	header.add_child(UiKit.spacer())
	pending = UiKit.label("", &"CaptionLabel")
	pending.name = "Pending"
	header.add_child(pending)
	text = UiKit.wrapped("", &"", 230)
	text.name = "Text"
	text.max_lines_visible = 6
	column.add_child(text)
	dismiss_hint = KeyHint.new(&"dialogue_advance", "Dismiss")
	dismiss_hint.size_flags_horizontal = Control.SIZE_SHRINK_END
	column.add_child(dismiss_hint)
	UiKit.make_passive(self)


## A region of the existing sprite sheet; the source artwork is neither copied nor resampled.
static func _portrait_texture() -> Texture2D:
	var frame: Texture2D = FRAMES.get_frame_texture(&"idle_s", 0)
	var sheet := frame as AtlasTexture
	var crop := AtlasTexture.new()
	crop.atlas = sheet.atlas if sheet != null else frame
	crop.region = Rect2((sheet.region.position if sheet != null else Vector2.ZERO) + PORTRAIT_REGION.position, PORTRAIT_REGION.size)
	return crop


func bind(source: ChiwisDialogue) -> void:
	dialogue = source
	if not is_instance_valid(dialogue):
		return
	dialogue.line_started.connect(_line_started)
	dialogue.line_finished.connect(_line_finished)
	if dialogue.is_speaking():
		_line_started(dialogue.current)


func refresh_bindings() -> void:
	dismiss_hint.refresh()


func is_showing() -> bool:
	return card.visible


func _line_started(line: Dictionary) -> void:
	text.text = line.text
	var priority: int = int(line.priority)
	tag.text = TAGS.get(priority, "")
	var state: UiKit.State = UiKit.State.CRITICAL if priority == ChiwisDialogue.Priority.CRITICAL else UiKit.State.WARNING
	tag.add_theme_color_override(&"font_color", UiKit.state_color(self, state))
	var waiting: int = dialogue.pending_count()
	pending.text = "+%d MORE" % waiting if waiting > 0 else ""
	UiMotion.slide_in(card, Vector2(-10, 0))


func _line_finished() -> void:
	if is_instance_valid(dialogue) and dialogue.pending_count() > 0:
		return
	UiMotion.fade_out(card)
